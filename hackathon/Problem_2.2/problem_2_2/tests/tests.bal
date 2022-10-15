import ballerina/test;
import ballerina/io;

@test:Config {
    dataProvider: data,
    groups: ["sample"]
}
function addBatchTest(string dbFilePath, string paymentFilePath, int[] expected) returns error? {
    int[]|error returnedValues = addPayments(dbFilePath, paymentFilePath);
    if (returnedValues is int[]) {
        int index = 0;
        foreach int i in returnedValues {
            test:assertTrue(i >= expected[index]);
            index += 1;
        }
        test:assertEquals(returnedValues.length(), expected.length());
    } else {
        io:println("Returned values: ", returnedValues);
        test:assertFail(returnedValues.message());
    }
}
