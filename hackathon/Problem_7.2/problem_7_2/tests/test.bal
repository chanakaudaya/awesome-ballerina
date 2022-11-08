import ballerina/lang.runtime;
import ballerina/mime;
import ballerina/test;
import ballerina/websubhub;
import problem_7_2.hub as _;

function publishUpdates() returns error? {
    // `hub` is a configurable variable in the source.
    websubhub:PublisherClient pc = check new (hub);

    // Bug opened with `documentation` label.
    json payload = {
        "name": "Connectors",
        "actor": "amal",
        "kind": "bug",
        "action": "opened",
        "time": "2022-03-01T13:15:12",
        "title": "Filtering config is incorrect in doc",
        "version": "v2",
        "labels": ["filters", "documentation"],
        "severity": "high",
        "content": "$title, in the getting started doc."
    };
    websubhub:Acknowledgement|websubhub:UpdateMessageError res =
            pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Bug opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "mary",
        "kind": "bug",
        "action": "opened",
        "time": "2022-03-01T14:25:01",
        "title": "Unclear error message",
        "version": "v1",
        "labels": ["diagnostics"],
        "severity": "medium",
        "content": "Unclear error message when an invalid config is provided."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Bug opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "mary",
        "kind": "bug",
        "action": "opened",
        "time": "2022-03-01T16:10:31",
        "title": "Unclear setup steps",
        "version": "v1",
        "labels": [],
        "severity": "low",
        "content": "Unclear setup steps in documentation."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Bug closed.
    payload = {
        "name": "Connectors",
        "actor": "sunil",
        "kind": "bug",
        "action": "closed",
        "time": "2022-03-02T04:14:12",
        "title": "Authentication steps are incomplete",
        "version": "v2",
        "labels": ["documentation", "authn"],
        "severity": "high"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Improvement opened with `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "anne",
        "kind": "improvement",
        "action": "opened",
        "time": "2022-03-21T13:15:12",
        "title": "Add a diagram for filtering",
        "version": "v1",
        "labels": ["filters", "documentation"],
        "impact": "low",
        "content": "Will be easier to understand the flow with a diagram."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Improvement opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "avi",
        "kind": "improvement",
        "action": "opened",
        "time": "2022-03-21T14:25:01",
        "title": "Improve error message",
        "version": "v1",
        "labels": ["diagnostics"],
        "impact": "low",
        "content": "Include information about failure IDs."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);
}

@test:Config {
    groups: ["sample"]
}
function setupData() returns error? {
    runtime:sleep(4);
    check publishUpdates();
    runtime:sleep(8);
}

@test:Config {
    groups: ["sample"],
    dependsOn: [setupData]
}
function testProcessingEventNotifications() returns error? {
    DiscussionDetails[] expectedContent = [
        {title: "Filtering config is incorrect in doc", kind: "bug", affectedVersion: "v2", priority: 1},
        {title: "Add a diagram for filtering", kind: "improvement", affectedVersion: "v1", priority: 3}
    ];

    DiscussionDetails[] actualContent;

    lock {
        actualContent = discussionDetails.toArray().clone();
    }

    test:assertEquals(actualContent.length(), expectedContent.length());

    foreach DiscussionDetails expectedEntry in expectedContent {
        test:assertTrue(actualContent.indexOf(expectedEntry) !is (),
                        "missing an expected entry: " + expectedEntry.toString());
    }
}
