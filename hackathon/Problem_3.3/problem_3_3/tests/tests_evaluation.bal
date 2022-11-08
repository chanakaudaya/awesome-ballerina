import ballerina/test;
import ballerina/os;
import problem_3_3.back_ends as _;

@test:BeforeGroups {value: ["evaluation"]}
function setUp() {
    os:Error? env = os:setEnv("DATA_SOURCE", "resources/data_evaluation.json");
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
function testFindTheGiftSimpleEval() returns error? {
    json expected = {
        "eligible": true,
        "score": 28800,
        "from": "2022-03-01",
        "to": "2022-06-31",
        "details": {
            "type": "PLATINUM",
            "message": "Congratulations! You have won the PLATINUM gift!"
        }
    };
    Gift|error response = findTheGiftSimple("1", "2022-03-01", "2022-06-31");
    if response is Gift {
        test:assertTrue(response == expected);
    } else {
        test:assertFail();
    }
}

@test:Config {
    groups: ["evaluation"]
}
function testFindTheGiftComplexEval() returns error? {
    json expected = {
        "eligible": true,
        "score": 5760,
        "from": "2022-03-01",
        "to": "2022-06-31",
        "details": {
            "type": "SILVER",
            "message": "Congratulations! You have won the SILVER gift!"
        }
    };
    Gift|error response = findTheGiftComplex("1", "2022-03-01", "2022-06-31");
    if response is Gift {
        test:assertTrue(response == expected);
    } else {
        test:assertFail();
    }
}
