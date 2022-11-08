import ballerina/test;
import problem_5_1.back_ends as _;
import ballerina/http;

@test:Config {
    groups: ["sample"]
}
function testGqlWithSecondsService() returns error? {
    http:Client gqlEp = check new ("http://localhost:9090");
    json payload = {
        "query": "{\n  sleepSummary(ID: \"1\", timeunit:SECONDS) {\n    date\n    duration\n    levels {\n      deep\n      wake\n    }\n  }\n}"
    };
    json response = check gqlEp->post("/graphql", payload);
    test:assertTrue(response.data == expectedSeconds);
}

@test:Config {
    groups: ["sample"]
}
function testGqlWithMinutesService() returns error? {
    http:Client gqlEp = check new ("http://localhost:9090");
    json payload = {
        "query": "{\n  sleepSummary(ID: \"1\", timeunit:MINUTES) {\n    date\n    duration\n    levels {\n      deep\n      wake\n    }\n  }\n}"
    };
    json response = check gqlEp->post("/graphql", payload);
    test:assertTrue(response.data == expectedMinutes);
}

final json & readonly expectedSeconds = {
    "sleepSummary": [
        {
            "date": "2022-03-20",
            "duration": 1728000,
            "levels": {
                "deep": 1140000,
                "wake": 48000
            }
        },
        {
            "date": "2022-03-15",
            "duration": 1684800,
            "levels": {
                "deep": 1254000,
                "wake": 10800
            }
        },
        {
            "date": "2022-03-10",
            "duration": 1684800,
            "levels": {
                "deep": 1200000,
                "wake": 4800
            }
        },
        {
            "date": "2022-02-10",
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
                "deep": 1200000,
                "wake": 0
            }
        },
        {
            "date": "2022-01-07",
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
                "deep": 1200000,
                "wake": 48000
            }
        }
    ]
};

final json & readonly expectedMinutes = {
    "sleepSummary": [
        {
            "date": "2022-03-20",
            "duration": 28800,
            "levels": {
                "deep": 19000,
                "wake": 800
            }
        },
        {
            "date": "2022-03-15",
            "duration": 28080,
            "levels": {
                "deep": 20900,
                "wake": 180
            }
        },
        {
            "date": "2022-03-10",
            "duration": 28080,
            "levels": {
                "deep": 20000,
                "wake": 80
            }
        },
        {
            "date": "2022-02-10",
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
                "deep": 20000,
                "wake": 0
            }
        },
        {
            "date": "2022-01-07",
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
                "deep": 20000,
                "wake": 800
            }
        }
    ]
};

