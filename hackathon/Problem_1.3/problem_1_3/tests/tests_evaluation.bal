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
    json outputActual = check io:fileReadJson(outputFileActual);
    json outputExpected = check io:fileReadJson(outputFileExpected);
    test:assertTrue(outputActual == outputExpected);
}
