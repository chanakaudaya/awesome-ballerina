import problem_3_5.customers;
import problem_3_5.backend as _;
import ballerina/test;

@test:Config {
    dataProvider: dataProviderEval,
    groups: ["evaluation"]
}
function testFindTopCustomersEval(Quarter[] quarters, int x, string[] expectedCustomerIds) {
    customers:Customer[]|error customers = findTopXCustomers(quarters, x);
    if customers is error {
        test:assertFail("Failed to get top customers" + customers.message());
    }

    string[] actualIds = from var customer in customers
        select customer.id;
    test:assertTrue(actualIds == expectedCustomerIds);
}

function dataProviderEval() returns map<[Quarter[], int, string[]]> {
    return {
        "case1": [
            [[2022, "Q1"], [2021, "Q3"]],
            3,
            ["1", "2", "3"]
        ],
        "case2": [
            [[2019, "Q1"], [2019, "Q2"]],
            2,
            ["5", "4"]
        ],
        "case3": [
            [[2018, "Q1"], [2018, "Q2"], [2018, "Q3"], [2018, "Q4"]],
            3,
            ["5"]
        ],
        "case4": [
            [[2020, "Q1"], [2020, "Q2"], [2020, "Q3"], [2020, "Q4"], [2021, "Q1"], [2021, "Q2"], [2021, "Q3"], [2021, "Q4"]],
            10,
            ["2", "1", "3", "5"]
        ],
        "case5": [
            [[2021, "Q1"], [2021, "Q2"], [2021, "Q3"], [2021, "Q4"]],
            5,
            ["2", "1"]
        ]
    };
}
