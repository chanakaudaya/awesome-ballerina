import ballerina/test;

@test:Config {
    dataProvider: data,
    groups: ["sample"]
}
function addHighPaymentTest(string dbFilePath, decimal amount, HighPayment[] expected) returns error? {
    HighPayment[]|error returnedValues = getHighPaymentDetails(dbFilePath, amount);
    if (returnedValues is HighPayment[]) {
        test:assertEquals(returnedValues, expected);
    } else {
        test:assertFail(returnedValues.message());
    }
}
