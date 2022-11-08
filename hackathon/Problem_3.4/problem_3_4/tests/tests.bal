import ballerina/test;
import problem_3_4.back_ends as _;

@test:Config {
    groups: ["sample"]
}
function testFindTheGift() returns error? {
    Gift expected = {
        "eligible": true,
        "score": 9676,
        "from": "2022-01-01",
        "to": "2022-03-31",
        "details": {
            "type": "SILVER",
            "message": "Congratulations! You have won the SILVER gift!"
        }
    };
    Gift|error response = findTheGift("1", "2022-01-01", "2022-03-31");
    if response is Gift {
        test:assertTrue(response == expected);
    } else {
        test:assertFail();
    }
}
