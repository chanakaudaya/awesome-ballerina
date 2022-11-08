import problem_3_5.customers;
import problem_3_5.backend as _;
import ballerina/test;

@test:Config {
    dataProvider: dataProvider,
    groups: ["sample"]
}
function testFindTopCustomers(Quarter[] quarters, int x, string[] expectedCustomerIds) {
    customers:Customer[]|error customers = findTopXCustomers(quarters, x);
    if customers is error {
        test:assertFail("Failed to get top customers" + customers.message());
    }

    string[] actualIds = from var customer in customers
        select customer.id;
    test:assertEquals(actualIds, expectedCustomerIds);
}

function dataProvider() returns map<[Quarter[], int, string[]]> {
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
        ]
    };
}
