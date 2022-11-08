import ballerina/test;
import problem_5_2.back_ends as _;
import ballerina/http;

@test:Config {
    groups: ["sample"]
}
function testGqlService() returns error? {
    http:Client gqlEp = check new ("http://localhost:9090");
    json payload = {
        "query": "{\n  activity(ID:\"1\") {\n    steps\n    heart {\n      min\n      max\n    }\n  }\n}"
    };
    json response = check gqlEp->post("/graphql", payload);
    test:assertTrue(response.data == expected);
}

final json & readonly expected = {
    "activity": [
        {
            "steps": 837,
            "heart": {
                "min": 86,
                "max": 110
            }
        },
        {
            "steps": 7861,
            "heart": {
                "min": 147,
                "max": 220
            }
        },
        {
            "steps": 8304,
            "heart": {
                "min": 121,
                "max": 147
            }
        },
        {
            "steps": 3723,
            "heart": {
                "min": 86,
                "max": 121
            }
        },
        {
            "steps": 2504,
            "heart": {
                "min": 30,
                "max": 86
            }
        }
    ]
};
