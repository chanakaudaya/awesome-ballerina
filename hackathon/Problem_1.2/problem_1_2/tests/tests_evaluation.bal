import ballerina/io;
import ballerina/test;

@test:Config {
    dataProvider: dataEval,
    groups: ["evaluation"]
}
function processFuelRecordsTestEval(string inputFile, string outputFileActual, string outputFileExpected) returns error? {
    error? e = processFuelRecords(inputFile, outputFileActual);
    if e is error {
        io:println(e);
        test:assertFail(e.message());
    }
    check checkIfFileExists(outputFileActual);
    string[][] outputActual = check io:fileReadCsv(outputFileActual);
    string[][] outputExpected = check io:fileReadCsv(outputFileExpected);
    test:assertTrue(outputActual == outputExpected);
}
