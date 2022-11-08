import ballerina/lang.runtime;
import ballerina/mime;
import ballerina/test;
import ballerina/websubhub;
import problem_7_1.hub as _;

function publishUpdatesEval() returns error? {
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

    // Bug labeled with `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "jo",
        "kind": "bug",
        "action": "labeled",
        "time": "2022-03-12T07:15:22",
        "title": "Unclear setup steps",
        "version": "v1",
        "labels": ["documentation"],
        "severity": "medium",
        "new_label": "documentation"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Bug labeled with non-`documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "mary",
        "kind": "bug",
        "action": "labeled",
        "time": "2022-03-20T11:02:14",
        "title": "Filtered count is incorrect",
        "version": "v1",
        "labels": ["filters"],
        "severity": "medium",
        "new_label": "filters"
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

    // Improvement opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "marianne",
        "kind": "improvement",
        "action": "opened",
        "time": "2022-03-21T16:10:31",
        "title": "Improve setup steps",
        "version": "v1",
        "labels": [],
        "impact": "significant",
        "content": "Currently all over the place."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Improvement closed.
    payload = {
        "name": "Connectors",
        "actor": "sunila",
        "kind": "improvement",
        "action": "closed",
        "time": "2022-03-21T04:14:12",
        "title": "Improve authentication steps",
        "version": "v2",
        "labels": ["documentation", "authn"],
        "impact": "low"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Improvement labeled with `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "joy",
        "kind": "improvement",
        "action": "labeled",
        "time": "2022-03-22T07:15:22",
        "title": "Improve setup steps",
        "version": "v1",
        "labels": ["documentation"],
        "impact": "significant",
        "new_label": "documentation"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Improvement labeled with non-`documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "kevin",
        "kind": "improvement",
        "action": "labeled",
        "time": "2022-03-23T11:02:14",
        "title": "Improve error on incorrect config",
        "version": "v1",
        "labels": ["filters"],
        "impact": "low",
        "new_label": "filters"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Feature request opened with `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "manny",
        "kind": "feature request",
        "action": "opened",
        "time": "2022-03-21T22:15:12",
        "title": "Add left navigation for docs",
        "version": "v1",
        "labels": ["filters", "documentation"],
        "content": "Will be easier when getting started."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/featurerequests.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Feature request opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "rosa",
        "kind": "feature request",
        "action": "opened",
        "time": "2022-03-23T14:25:01",
        "title": "Allow specifying timeout for filter",
        "version": "v1",
        "labels": ["filters"],
        "content": "$title"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/featurerequests.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Feature request opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "ryan",
        "kind": "feature request",
        "action": "opened",
        "time": "2022-03-24T16:10:31",
        "title": "Improve links in documentation",
        "version": "v1",
        "labels": [],
        "content": "Not used optimally at the moment."
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/featurerequests.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Feature request closed.
    payload = {
        "name": "Connectors",
        "actor": "anil",
        "kind": "feature request",
        "action": "closed",
        "time": "2022-03-25T04:14:12",
        "title": "Allow viewing docs by operation",
        "version": "v2",
        "labels": ["documentation"]
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/featurerequests.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Feature request labeled with `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "ryan",
        "kind": "feature request",
        "action": "opened",
        "time": "2022-03-25T16:10:31",
        "title": "Improve links in documentation",
        "version": "v1",
        "labels": ["documentation"],
        "new_label": "documentation"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/featurerequests.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    // Feature request labeled with non-`documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "rosy",
        "kind": "feature request",
        "action": "labeled",
        "time": "2022-03-27T11:02:14",
        "title": "Add filtering support for new connectors",
        "version": "v2",
        "labels": ["filters"],
        "new_label": "filters"
    };
    res = pc->publishUpdate("http://projzone.com/gofigure/Connectors/events/featurerequests.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(3);

    lock {
        \$testReadArray = discussionDetails.toArray().clone();
    }
}

@test:Config {
    groups: ["evaluation"]
}
function setupEval() returns error? {
    runtime:sleep(4);
    check publishUpdatesEval();
    runtime:sleep(8);
}

DiscussionDetails[] \$testReadArray = [];

final readonly & DiscussionDetails[] \$testExpectedBugContent = [
    {title: "Filtering config is incorrect in doc", kind: "bug", affectedVersion: "v2", priority: 1},
    {title: "Unclear setup steps", kind: "bug", affectedVersion: "v1", priority: 2}
];

final readonly & DiscussionDetails[] \$testExpectedImprovementContent = [
    {title: "Add a diagram for filtering", kind: "improvement", affectedVersion: "v1", priority: 3},
    {title: "Improve setup steps", kind: "improvement", affectedVersion: "v1", priority: 2}
];

final readonly & DiscussionDetails[] \$testExpectedFeatureRequestContent = [
    {title: "Add left navigation for docs", kind: "feature request", affectedVersion: "v1", priority: 3},
    {title: "Improve links in documentation", kind: "feature request", affectedVersion: "v1", priority: 3}
];

@test:Config {
    groups: ["evaluation"],
    dependsOn: [setupEval]
}
function testNumberOfEntries() returns error? {
    int expectedLength = \$testExpectedBugContent.length() + 
                            \$testExpectedImprovementContent.length() + 
                            \$testExpectedFeatureRequestContent.length();

    lock {
        if discussionDetails.length() == expectedLength {
            return;
        }
    }

    DiscussionDetails[] allExpectedEntries = [];
    allExpectedEntries.push(...\$testExpectedBugContent);
    allExpectedEntries.push(...\$testExpectedImprovementContent);
    allExpectedEntries.push(...\$testExpectedFeatureRequestContent);

    DiscussionDetails[] notFoundEntries = from DiscussionDetails expectedEntry in allExpectedEntries
                                    where \$testReadArray.indexOf(expectedEntry) is ()
                                    select expectedEntry;

    test:assertFail("(some) expected entries not found: " + notFoundEntries.toBalString());
}

@test:Config {
    groups: ["evaluation"],
    dependsOn: [setupEval]
}
function testProcessingBugEventNotifications() returns error? {
    DiscussionDetails[] bugs = from DiscussionDetails details in \$testReadArray 
        where details.kind == "bug"
        select details;

    foreach DiscussionDetails expectedBugEntry in \$testExpectedBugContent {
        test:assertTrue(bugs.indexOf(expectedBugEntry) !is (), 
                        "missing an expected entry: " + expectedBugEntry.toString());
    }
}

@test:Config {
    groups: ["evaluation"],
    dependsOn: [setupEval]
}
function testProcessingImprovementEventNotifications() returns error? {
    DiscussionDetails[] improvements = from DiscussionDetails details in \$testReadArray 
        where details.kind == "improvement"
        select details;

    foreach DiscussionDetails expectedImprovementEntry in \$testExpectedImprovementContent {
        test:assertTrue(improvements.indexOf(expectedImprovementEntry) !is (), 
                        "missing an expected entry: " + expectedImprovementEntry.toString());
    }
}

@test:Config {
    groups: ["evaluation"],
    dependsOn: [setupEval]
}
function testProcessingFeatureRequestEventNotifications() returns error? {
    DiscussionDetails[] featureRequests = from DiscussionDetails details in \$testReadArray 
        where details.kind == "feature request"
        select details;

    foreach DiscussionDetails expectedFeatureRequestEntry in \$testExpectedFeatureRequestContent {
        test:assertTrue(featureRequests.indexOf(expectedFeatureRequestEntry) !is (), 
                        "missing an expected entry: " + expectedFeatureRequestEntry.toString());
    }
}
