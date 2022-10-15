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
    xml outputActual = check io:fileReadXml(outputFileActual);
    xml outputExpected = check io:fileReadXml(outputFileExpected);
    test:assertTrue(outputActual == outputExpected);
}
