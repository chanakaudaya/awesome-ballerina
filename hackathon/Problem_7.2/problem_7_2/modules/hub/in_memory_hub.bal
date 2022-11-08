import ballerina/http;
import ballerina/time;
import ballerina/log;
import ballerina/websubhub;
import ballerina/task;

isolated map<websubhub:Subscription[]> subscriptions = {};

type ClientDetails [string, websubhub:HubClient];

isolated map<ClientDetails[]> dispatcherClients = {
    [BUGS_TOPIC] : [],
    [IMPROVEMENTS_TOPIC] : [],
    [FEATURE_REQUESTS_TOPIC] : [],
    [ALL_TOPIC] : []
};

const ALL_TOPIC = "http://projzone.com/gofigure/Connectors/events/all.json";
const BUGS_TOPIC = "http://projzone.com/gofigure/Connectors/events/bugs.json";
const IMPROVEMENTS_TOPIC = "http://projzone.com/gofigure/Connectors/events/improvements.json";
const FEATURE_REQUESTS_TOPIC = "http://projzone.com/gofigure/Connectors/events/featurerequests.json";

final string[] & readonly individualTopics = [BUGS_TOPIC, IMPROVEMENTS_TOPIC, FEATURE_REQUESTS_TOPIC];

public function startMessageConsumption() {
    foreach string topic in individualTopics {
        _ = @strand {thread: "any"} start consumeMessages(topic);
    }
}

public function syncDispatcherState() returns error? {
    while true {
        foreach string topic in individualTopics {
            readonly & websubhub:Subscription[]? subscribers = retrieveAvailableSubscriptions(topic);
            if subscribers is () {
                lock {
                    dispatcherClients[topic] = [];
                }
                continue;
            }

            lock {
                ClientDetails[] clientDetails = retrieveValidClientDetails(subscribers, dispatcherClients.get(topic));
                readonly & websubhub:Subscription[] newSubscribers = retrieveNewSubscribers(subscribers, clientDetails);
                foreach var subscriber in newSubscribers {
                    websubhub:HubClient clientEp = check new (subscriber);
                    clientDetails.push([subscriber.hubCallback, clientEp]);
                }
                dispatcherClients[topic] = clientDetails;
            }
        }
    }
}

isolated function retrieveValidClientDetails(websubhub:Subscription[] activeSubscriptions, ClientDetails[] currentClientDetails) returns ClientDetails[] {
    string[] availableCallbacks = from websubhub:Subscription subscription in activeSubscriptions
        select subscription.hubCallback;

    return from ClientDetails clientDetails in currentClientDetails
        where availableCallbacks.indexOf(clientDetails[0]) is int
        select clientDetails;
}

isolated function retrieveNewSubscribers(websubhub:Subscription[] activeSubscriptions, ClientDetails[] currentClientDetails)
        returns readonly & websubhub:Subscription[] {
    string[] currentCallbacks = from [string, websubhub:HubClient] [callback, _] in currentClientDetails
        select callback;

    websubhub:Subscription[] newSubscriptions = from websubhub:Subscription subscription in activeSubscriptions
        where currentCallbacks.indexOf(subscription.hubCallback) is ()
        select subscription;
    return newSubscriptions.cloneReadOnly();
}

// TODO: check how we can improve this while also maintaining message order to an acceptable extent.
// Currently seems to lock dispatcherClients.
function consumeMessages(string topic) {
    while true {
        readonly & websubhub:UpdateMessage? message = poll(topic);
        if message is () {
            continue;
        }
        readonly & websubhub:ContentDistributionMessage payload = {
            contentType: message.contentType,
            content: message.content
        };

        lock {
            foreach ClientDetails clientDetails in dispatcherClients.get(topic) {
                string callback = clientDetails[0];

                if !isSubscriptionAvailable(topic, callback) {
                    continue;
                }

                websubhub:HubClient clientEp = clientDetails[1];
                websubhub:ContentDistributionSuccess|error response = clientEp->notifyContentDistribution(payload);
                if response is websubhub:SubscriptionDeletedError {
                    removeSubscription(topic, callback);
                }
            }
        }
    }
}

isolated websubhub:UpdateMessage[] queue = [];

public isolated function enqueue(readonly & websubhub:UpdateMessage message) {
    lock {
        queue.push(message);
    }
}

public function dequeue(string topic) returns readonly & websubhub:UpdateMessage? {
    lock {
        int? index = ();
        foreach [int, websubhub:UpdateMessage] [messageIndex, message] in queue.enumerate() {
            if message.hubTopic != topic {
                continue;
            }

            index = messageIndex;
        }
        if index is () {
            return;
        }
        return queue.remove(index).cloneReadOnly();
    }
}

public function poll(string topic, decimal timeout = 10.0) returns readonly & websubhub:UpdateMessage? {
    readonly & websubhub:UpdateMessage? message = dequeue(topic);
    if message is websubhub:UpdateMessage {
        return message;
    }

    time:Utc expiryTime = time:utcAddSeconds(time:utcNow(), timeout);

    // https://github.com/ballerina-platform/ballerina-lang/issues/33535
    while message is () && time:utcDiffSeconds(expiryTime, time:utcNow()) > 0D {
        message = dequeue(topic);

        lock {
            if queue.length() == 0 {
                break;
            }
        }
    }
    return message;
}

public isolated function isTopicAvailable(string topic) returns boolean {
    return topic == ALL_TOPIC || individualTopics.indexOf(topic) !is ();
}

public isolated function isSubscriptionAvailable(string topic, string hubCallback) returns boolean {
    lock {
        if !subscriptions.hasKey(topic) {
            return false;
        }

        websubhub:Subscription[] topicSubscriptions = subscriptions.get(topic);

        foreach websubhub:Subscription subscription in topicSubscriptions {
            if subscription.hubCallback == hubCallback {
                return true;
            }
        }

        return false;
    }
}

public isolated function addSubscription(readonly & websubhub:Subscription subscriber) {
    log:printInfo("Adding subscription", topic = subscriber.hubTopic, callback = subscriber.hubCallback);
    string topic = subscriber.hubTopic;
    lock {
        string[] topics;

        if topic == ALL_TOPIC {
            topics = [];
            topics.push(...individualTopics);
        } else {
            topics = [topic];
        }

        foreach string relevantTopic in topics {
            if subscriptions.hasKey(relevantTopic) {
                subscriptions.get(relevantTopic).push(subscriber);
                continue;
            }

            subscriptions[relevantTopic] = [subscriber];
        }
    }
}

public isolated function removeSubscription(string topic, string hubCallback) {
    lock {
        if !subscriptions.hasKey(topic) {
            return;
        }

        websubhub:Subscription[] topicSubscriptions = subscriptions.get(topic);
        int? index = ();

        foreach [int, websubhub:Subscription] [subscriptionIndex, subscription] in topicSubscriptions.enumerate() {
            if subscription.hubCallback == hubCallback {
                index = subscriptionIndex;
                break;
            }
        }

        if index is () {
            return;
        }

        _ = topicSubscriptions.remove(index);
    }
}

public function retrieveAvailableSubscriptions(string topic) returns readonly & websubhub:Subscription[]? {
    lock {
        return subscriptions[topic].cloneReadOnly();
    }
}

function init() returns error? {
    task:Job job = object {
        public function execute() {
            startMessageConsumption();
            _ = @strand {thread: "any"} start syncDispatcherState();
        }
    };

    _ = check task:scheduleOneTimeJob(job, time:utcToCivil(time:utcAddSeconds(time:utcNow(), 3)));

}

configurable int hubPort = 9090;

isolated service "hub" on new websubhub:Listener(hubPort) {
    remote function onRegisterTopic(readonly & websubhub:TopicRegistration message)
                                returns websubhub:TopicRegistrationSuccess|websubhub:TopicRegistrationError {
        return error("Topics are fixed.", statusCode = http:STATUS_BAD_REQUEST);
    }

    remote function onDeregisterTopic(readonly & websubhub:TopicDeregistration message)
                                returns websubhub:TopicDeregistrationSuccess|websubhub:TopicDeregistrationError {
        return error("Topics are fixed.", statusCode = http:STATUS_BAD_REQUEST);
    }

    isolated remote function onUpdateMessage(readonly & websubhub:UpdateMessage message) returns websubhub:Acknowledgement|websubhub:UpdateMessageError {
        if !isTopicAvailable(message.hubTopic) {
            return websubhub:UPDATE_MESSAGE_ERROR;
        }
        enqueue(message);
        return websubhub:ACKNOWLEDGEMENT;
    }

    isolated remote function onSubscriptionValidation(readonly & websubhub:Subscription message) returns websubhub:SubscriptionDeniedError? {
        if !isTopicAvailable(message.hubTopic) || isSubscriptionAvailable(message.hubTopic, message.hubCallback) {
            return websubhub:SUBSCRIPTION_DENIED_ERROR;
        }
    }

    isolated remote function onSubscriptionIntentVerified(readonly & websubhub:VerifiedSubscription message) returns error? {
        addSubscription(message);
    }

    isolated remote function onUnsubscriptionValidation(readonly & websubhub:Unsubscription message) returns websubhub:UnsubscriptionDeniedError? {
        if !isTopicAvailable(message.hubTopic) || !isSubscriptionAvailable(message.hubTopic, message.hubCallback) {
            return websubhub:UNSUBSCRIPTION_DENIED_ERROR;
        }
    }

    isolated remote function onUnsubscriptionIntentVerified(readonly & websubhub:VerifiedUnsubscription message) returns error? {
        removeSubscription(message.hubTopic, message.hubCallback);
    }
}
