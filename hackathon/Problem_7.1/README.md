# 7.1 ProjZone Discussion Tracker

## Problem Statement

Go Figure uses **ProjZone**, an online project management service provider, that allows users to initiate "discussions" to report bugs, suggest improvements, or raise feature requests.
Each discussion records the author and the time of creation. The organization has also made it mandatory to pick the affected version when creating the discussion (possible values `v1` or `v2`).
It is also mandatory to pick the severity (`low`, `medium`, or `high`) when creating a discussion for a bug and the impact (`low` or `significant`) for an improvement.

Additionally, each discussion can be tagged with labels either at the time of creation or after.

In addition to adding labels, other possible updates to discussions are adding comments and closing the discussion.

**ProjZone** also allows users to register webhooks to receive event notifications in JSON format whenever a discussion is initiated or updated.

As part of an effort to improve documentation for your project, you have been asked to update an in-memory table with the following information, for each discussion tagged with the `documentation` label.

- The title of the discussion (`title`)
- The kind of the discussion (`kind`)
- The affection version (`affectedVersion`)
- The priority (`priority`) computed to be 1, 2, or 3 as follows

    | kind (string) | priority (int) |
    | -------- | ------------ |
    | Bug | 1 if **severity** is high, 2 if **severity** is medium, 3 if **severity** is low |
    | Improvement | 2 if **impact** is significant, 3 if **impact** is low |
    | Feature Request | 3 |

>**Note**: a discussion may be tagged with `documentation` label either at the point of creation or at some point after creation.

You've decided to use a webhook to avoid having to periodically poll ProjZone, and to all make sure the data is always up to date.

## Constraints

- The event notification payload will always be a JSON object containing the following mandatory fields.
    - a `name` field indicating the name of the project (a unique string value)
    - a `kind` field indicating the kind of discussion (one of `"bug"`, `"improvement"`, or `"feature request"`)
    - a `title` field indicating the title of the discussion (a string value)
    - an `action` field indicating the action that was performed (one of `"opened"`, `"closed"`, `"commented"`, or`"labeled"`)
    - an `actor` field indicating who initiated the action. The value will be the username of the user (a string value).
    - a `time` field indicating the time at which the action occurred (a string value)
    - a `labels` field with an array of strings representing the current labels 
    - a `version` field containing the affected version (`v1` or `v2`) specified when creating the discussion
    
    ```json
    {
        "type": "object",
        "properties": {
            "name": {
                "type": "string"
            },
            "kind": {
                "type": "string"
            },
            "title": {
                "type": "string"
            },
            "action": {
                "type": "string"
            },
            "actor": {
                "type": "string"
            },
            "time": {
                "type": "string"
            },
            "labels": {
                "type": "array",
                "items": {
                    "type": "string"
                }
            },
            "version": {
                "type": "string"
            }
        },
        "required": [
            "name",
            "kind",
            "title",
            "action",
            "actor",
            "time",
            "labels",
            "version"
        ]
    }
    ```

- The payload may contain the following mandatory fields depending on the kind or the action.
    - when the kind is `"bug"`, a `severity` field containing severity (`low`, `medium`, or `high`) specified when creating the discussion
    - when the kind is `"improvement"`, an `impact` field containing impact (`low` or `significant`) specified when creating the discussion
    - when the action is `"labeled"`, the payload will contain a `new_label` representing the new label. The `labels` field will also include this new label.
    - when the action is `"opened"` or `"commented"`, a `content` field containing the content specified when creating the discussion or adding the comment

## Definition

- Introduce a WebSub subscriber service as a webhook to receive event notifications from **ProjZone**.

- Specify a `secret` value in the annotation for authenticated content distribution.

- Use `configurable` variables named `port`, hub`, `topic`, and `secret` to specify the port, hub, topic, and secret respectively. Use the following values as the default values for the port, hub, and topic.
    - `port` - `8080`
    - `hub` - `"http://localhost:9090/hub"`
    - `topic` - `"http://projzone.com/gofigure/Connectors/events/all.json"`

- Discussions need to be filtered based on whether they have the `documentation` label.

- Since `commented` and `closed` actions do not result in a label change, only `opened` and `labeled` actions need to be taken into consideration.

- The table and member record type are defined as follows in the `main.bal` file already

    ```
    type DiscussionDetails record {|
        string title;
        string kind;
        string affectedVersion;
        int priority;
    |};

    table<DiscussionDetails> discussionDetails = table [];
    ```

## Example 1

**Input**

The following three notifications.

1. A bug discussion is opened with the documentation label.

```json
{
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
}
```

1. A bug discussion is opened without the documentation label.

```json
{
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
}
```

1. A feature request discussion is opened with the documentation label.

```json
{
    "name": "Connectors",
    "actor": "manny",
    "kind": "feature request",
    "action": "opened",
    "time": "2022-03-21T22:15:12",
    "title": "Add left navigation for docs",
    "version": "v1",
    "labels": ["filters", "documentation"],
    "content": "Will be easier when getting started."
}
```

**Output**

The table should contain the following (entries for discussions don't have to be in the same order as the notifications).

```cmd
{title: "Filtering config is incorrect in doc", kind: "bug", affectedVersion: "v2", priority: 1}
{title: "Add left navigation for docs", kind: "feature request", affectedVersion: "v1", priority: 3}
```

## Test Environment

A WebSub hub that accepts subscription requests for `ProjZone` is expected to be up and running.

An implementation of a simple hub service is provided in the `hub` module. The default URL is `http://localhost:9090/hub`.

Running `bal test` will handle starting up the hub service before the subscriber service starts up.

## Hints

- [Simple WebSub service](https://ballerina.io/learn/by-example/websub-webhook-sample)
- [Working with JSON directly](https://ballerina.io/learn/by-example/working-directly-with-json)
- [Converting from JSON to user-defined type](https://ballerina.io/learn/by-example/converting-to-user-defined-type)
- [Adding members to a table](https://lib.ballerina.io/ballerina/lang.table/0.0.0/functions#add)
