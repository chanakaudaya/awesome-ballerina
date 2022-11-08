import ballerina/test;
import problem_3_3.back_ends as _;

@test:Config {
    groups: ["sample"]
}
function testFindTheGiftSimple() returns error? {
    json expected = {
        "eligible": true,
        "score": 29030,
        "from": "2022-01-01",
        "to": "2022-03-31",
        "details": {
            "type": "PLATINUM",
            "message": "Congratulations! You have won the PLATINUM gift!"
        }
    };
    Gift|error response = findTheGiftSimple("1", "2022-01-01", "2022-03-31");
    if response is Gift {
        test:assertTrue(response == expected);
    } else {
        test:assertFail();
    }
}

@test:Config {
    groups: ["sample"]
}
function testFindTheGiftComplex() returns error? {
    json expected = {
        "eligible": true,
        "score": 9676,
        "from": "2022-01-01",
        "to": "2022-03-31",
        "details": {
            "type": "SILVER",
            "message": "Congratulations! You have won the SILVER gift!"
        }
    };
    Gift|error response = findTheGiftComplex("1", "2022-01-01", "2022-03-31");
    if response is Gift {
        test:assertTrue(response == expected);
    } else {
        test:assertFail();
    }
}
