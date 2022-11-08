
import ballerina/websub;
import ballerina/io;

type DiscussionDetails record {|
    string title;
    string kind;
    string affectedVersion;
    int priority;
|};

table<DiscussionDetails> discussionDetails = table [];

type EventData record {|
    string name;
    Kind kind;
    string title;
    Action action;
    string actor;
    string time;
    string[] labels;
    Version verion;
    Severity severity?;
    Impact impact?;
    string new_label?;
    string content?;
|};

enum Severity {
    low,
    medium,
    high
}

enum Impact {
    low,
    significant
}

enum Kind {
    bug = "bug",
    improvement = "improvement",
    feature_request = "feature request"
}

enum Action {
    opened,
    closed,
    commented,
    labeled
}

enum Version {
    v1,
    v2
}

configurable int port = 8080;
configurable string hub = "http://localhost:9090/hub";
configurable string topic = "http://projzone.com/gofigure/Connectors/events/all.json";
configurable string secret = ?;

// Annotation-based configurations specifying the subscription parameters.
@websub:SubscriberServiceConfig {
    target: [
        hub, 
        topic
    ],
    secret: secret
}
service /discussions on new websub:Listener(port) {
    // Defines the remote function that accepts the event notification request for the WebHook.
    remote function onEventNotification(websub:ContentDistributionMessage event) returns error? {
        var retrievedContent = event.content;
        if retrievedContent is json {
            EventData data = check retrievedContent.cloneWithType(EventData);
            if data.labels.indexOf("documentation") != () {
                if data.action is opened || data.action is labeled {
                int priority = 0;
                if data.kind is bug {
                    match data.severity {
                        high => {
                            priority = 1;
                        }
                        medium => {
                            priority = 2;
                        }
                        low => {
                            priority = 3;
                        }
                    }
                } else if data.kind is improvement {
                    match data.impact {
                        significant => {
                            priority = 2;
                        }
                        low => {
                            priority = 3;
                        }
                    }

                } else {
                    priority = 3;
                }
                DiscussionDetails result = {title: data.title, kind: data.kind.toString(), affectedVersion: data.verion, priority: priority};
                discussionDetails.add(result);
                }
            }

        } else {
            io:println("Unrecognized content type, hence ignoring");
            return error("Invalid content type");
        }
    }
}