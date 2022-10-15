import ballerina/test;
@test:Config {
    dataProvider: dataEval,
    groups: ["evaluation"]
}
function getHighValuesTestEval(string dbFilePath, decimal amount, string[] expected) returns error? {
    string[]|error returnedValues  = getHighPaymentEmployees(dbFilePath, amount);
    if(returnedValues is string[]) {
        test:assertTrue(expected == returnedValues);
    } else {
        test:assertFail(returnedValues.message());
    }
}
