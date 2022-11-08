import projzone/webhook;

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
configurable string orgName = "gofigure";
configurable string projName = "Connectors";
configurable string secret = ?;
configurable string hub = "http://localhost:9090/hub";

listener webhook:Listener ln = new (port, orgName, projName, secret, hub);

service webhook:BugDiscussionService on ln {
    remote function onDiscussionClosed(webhook:BugDiscussionEvent event) {

    }

    remote function onDiscussionCommented(webhook:BugDiscussionOpenedOrCommentedEvent event) {
         
    }

    remote function onDiscussionLabeled(webhook:BugDiscussionLabeledEvent event) {
            if event.labels.indexOf("documentation") != () {
                int priority = 0;
                    match event.severity {
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
                 
                DiscussionDetails result = {title: event.title, kind: event.kind.toString(), affectedVersion: event.'version, priority: priority};
                discussionDetails.add(result);
                
            }
        
    }

    remote function onDiscussionOpened(webhook:BugDiscussionOpenedOrCommentedEvent event) {
                    if event.labels.indexOf("documentation") != () {
                int priority = 0;
                    match event.severity {
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
                 
                DiscussionDetails result = {title: event.title, kind: event.kind.toString(), affectedVersion: event.'version, priority: priority};
                discussionDetails.add(result);
                
            }
    }
}

service webhook:ImprovementDiscussionService on ln {


    remote function onDiscussionClosed(webhook:ImprovementDiscussionEvent event) {
        return;
    }

    remote function onDiscussionCommented(webhook:ImprovementDiscussionOpenedOrCommentedEvent event) {
        return;
    }

    remote function onDiscussionLabeled(webhook:ImprovementDiscussionLabeledEvent event) {
                    if event.labels.indexOf("documentation") != () {
                int priority = 0;
                    match event.impact {
                        significant => {
                            priority = 2;
                        }
                        low => {
                            priority = 3;
                        }
                    }
                 
                DiscussionDetails result = {title: event.title, kind: event.kind.toString(), affectedVersion: event.'version, priority: priority};
                discussionDetails.add(result);
                
            }
        return;
    }

    remote function onDiscussionOpened(webhook:ImprovementDiscussionOpenedOrCommentedEvent event) {
         if event.labels.indexOf("documentation") != () {
                int priority = 0;
                    match event.impact {
                        significant => {
                            priority = 2;
                        }
                        low => {
                            priority = 3;
                        }
                    }
                 
                DiscussionDetails result = {title: event.title, kind: event.kind.toString(), affectedVersion: event.'version, priority: priority};
                discussionDetails.add(result);
                
            }
        return;
    }
}

