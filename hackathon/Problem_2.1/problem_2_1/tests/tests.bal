import ballerina/test;

@test:Config {
    dataProvider: validInsertionTestData,
    groups: ["sample"]
}
function addEmployeeTest(string dbFilePath, string name, string city, string department, int age, int expected) returns error? {
    test:assertTrue(addEmployee(dbFilePath, name, city, department, age) > expected);
}

@test:Config {
    dataProvider: invalidInsertionTestData,
    groups: ["sample"]
}
function addEmployeeTestInvalid(string dbFilePath, string name, string city, string department, int age, int expected) returns error? {
    test:assertEquals(addEmployee(dbFilePath, name, city, department, age), expected);
}
