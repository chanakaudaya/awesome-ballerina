import ballerina/test;
import problem_5_2.back_ends as _;
import ballerina/os;
import ballerina/http;

@test:BeforeGroups {value: ["evaluation"]}
function setUp() {
    os:Error? env = os:setEnv("DATA_SOURCE", "tests/resources/data_evaluation.json");
    if env is os:Error {
        test:assertFail("Failed to inialize tests");
    }
}

@test:AfterGroups {value: ["evaluation"]}
function tearDown() {
    os:Error? env = os:unsetEnv("DATA_SOURCE");
    if env is os:Error {
        test:assertFail("Failed to inialize tests");
    }
}

@test:Config {
    groups: ["evaluation"]
}
function testGqlServiceEval() returns error? {
    http:Client gqlEp = check new ("http://localhost:9090");
    json payload = {
        "query": "{\n  activity(ID:\"1\") {\n    steps\n    heart {\n      min\n      max\n    }\n  }\n}"
    };
    json response = check gqlEp->post("/graphql", payload);
    test:assertTrue(response.data == expectedEval);
}

final json & readonly expectedEval = {
    "activity": [
        {
            "steps": 837,
            "heart": {
                "min": 87,
                "max": 111
            }
        },
        {
            "steps": 7777,
            "heart": {
                "min": 145,
                "max": 218
            }
        },
        {
            "steps": 8567,
            "heart": {
                "min": 121,
                "max": 147
            }
        },
        {
            "steps": 3723,
            "heart": {
                "min": 83,
                "max": 111
            }
        },
        {
            "steps": 2565,
            "heart": {
                "min": 30,
                "max": 86
            }
        }
    ]
};
