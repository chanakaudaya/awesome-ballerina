import ballerina/test;

@test:Config {
    dataProvider: dataEval,
    groups: ["evaluation"]
}
function addHighPaymentTestEval(string dbFilePath, decimal amount, HighPayment[] expected) returns error? {
    HighPayment[]|error returnedValues = getHighPaymentDetails(dbFilePath, amount);
    if (returnedValues is HighPayment[]) {
        test:assertTrue(expected == returnedValues);
    } else {
        test:assertFail(returnedValues.message());
    }
}

@test:Config {
    dataProvider: data,
    groups: ["evaluation"]
}
function addHighPaymentTestFullEval(string dbFilePath, decimal amount, HighPayment[] expected) returns error? {
    HighPayment[]|error returnedValues = getHighPaymentDetails(dbFilePath, amount);
    if (returnedValues is HighPayment[]) {
        test:assertTrue(expected == returnedValues);
    } else {
        test:assertFail(returnedValues.message());
    }
}
