import ballerina/test;
import ballerina/os;
import problem_3_4.back_ends as _;

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
function testFindTheGiftEval() returns error? {
    Gift expected = {
        "eligible": true,
        "score": 6935,
        "from": "2022-06-01",
        "to": "2022-09-31",
        "details": {
            "type": "SILVER",
            "message": "Congratulations! You have won the SILVER gift!"
        }
    };
    Gift|error response = findTheGift("1", "2022-06-01", "2022-09-31");
    if response is Gift {
        test:assertTrue(response == expected);
    } else {
        test:assertFail();
    }
}
