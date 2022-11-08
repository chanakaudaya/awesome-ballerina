import ballerina/test;
import ballerina/os;
import problem_5_1.back_ends as _;
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
function testGqlSecondsServiceEval() returns error? {
    http:Client gqlEp = check new ("http://localhost:9090");
    json payload = {
        "query": "{\n  sleepSummary(ID: \"1\", timeunit:SECONDS) {\n    date\n    duration\n    levels {\n      deep\n      wake\n    }\n  }\n}"
    };
    json response = check gqlEp->post("/graphql", payload);
    test:assertTrue(response.data == expectedSecondsEval);
}

@test:Config {
    groups: ["evaluation"]
}
function testGqlMinutesServiceEval() returns error? {
    http:Client gqlEp = check new ("http://localhost:9090");
    json payload = {
        "query": "{\n  sleepSummary(ID: \"1\", timeunit:MINUTES) {\n    date\n    duration\n    levels {\n      deep\n      wake\n    }\n  }\n}"
    };
    json response = check gqlEp->post("/graphql", payload);
    test:assertTrue(response.data == expectedMinutesEval);
}

final json & readonly expectedSecondsEval = {
    "sleepSummary": [
        {
            "date": "2022-03-21",
            "duration": 1728000,
            "levels": {
                "deep": 48000,
                "wake": 540000
            }
        },
        {
            "date": "2022-03-16",
            "duration": 1684800,
            "levels": {
                "deep": 484800,
                "wake": 10800
            }
        },
        {
            "date": "2022-03-09",
            "duration": 1684800,
            "levels": {
                "deep": 4800,
                "wake": 484800
            }
        },
        {
            "date": "2022-02-08",
            "duration": 1404000,
            "levels": {
                "deep": 1200000,
                "wake": 24000
            }
        },
        {
            "date": "2022-02-03",
            "duration": 1620000,
            "levels": {
                "deep": 0,
                "wake": 1200000
            }
        },
        {
            "date": "2022-01-20",
            "duration": 1512000,
            "levels": {
                "deep": 1200000,
                "wake": 12000
            }
        },
        {
            "date": "2022-01-01",
            "duration": 1728000,
            "levels": {
                "deep": 480000,
                "wake": 1200000
            }
        }
    ]
};

final json & readonly expectedMinutesEval = {
    "sleepSummary": [
        {
            "date": "2022-03-21",
            "duration": 28800,
            "levels": {
                "deep": 800,
                "wake": 9000
            }
        },
        {
            "date": "2022-03-16",
            "duration": 28080,
            "levels": {
                "deep": 8080,
                "wake": 180
            }
        },
        {
            "date": "2022-03-09",
            "duration": 28080,
            "levels": {
                "deep": 80,
                "wake": 8080
            }
        },
        {
            "date": "2022-02-08",
            "duration": 23400,
            "levels": {
                "deep": 20000,
                "wake": 400
            }
        },
        {
            "date": "2022-02-03",
            "duration": 27000,
            "levels": {
                "deep": 0,
                "wake": 20000
            }
        },
        {
            "date": "2022-01-20",
            "duration": 25200,
            "levels": {
                "deep": 20000,
                "wake": 200
            }
        },
        {
            "date": "2022-01-01",
            "duration": 28800,
            "levels": {
                "deep": 8000,
                "wake": 20000
            }
        }
    ]
};
