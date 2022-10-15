import ballerina/test;
import problem_3_1.backend as _;

@test:Config {
    dataProvider: validDataEval,
    groups: ["evaluation"]
}
function testConversionEval(decimal salary, string sourceCurrency, string localCurrency, decimal expected) returns error? {
    decimal convertedSalary = check convertSalary(salary, sourceCurrency, localCurrency);
    test:assertTrue(convertedSalary.toString().startsWith(expected.toString()));
}

@test:Config {
    dataProvider: invalidDataEval,
    groups: ["evaluation"]
}
function testInvalidInputEval(string sourceCurrency, string localCurrency) {
    decimal|error convertedSalary = convertSalary(1000, sourceCurrency, localCurrency);
    test:assertTrue(convertedSalary is error);
}

function validDataEval() returns map<[decimal, string, string, decimal]> {
    return {
        "case1": [1350.25, "USD", "GBP", 1028.50432],
        "case2": [1300, "GBP", "USD", 1706.67730],
        "case3": [500.00, "EUR", "GBP", 421.69990],
        "case4": [1000, "GBP", "SGD", 1779.32793],
        "case5": [2340.01, "SGD", "AUD", 2307.32366],
        "case6": [9834.90889, "AUD", "USD", 7359.21683],
        "case7": [8788.00, "AED", "INR", 181451.41616],
        "case8": [982.01, "JPY", "INR", 607.59288],
        "case9": [4890.99, "GBP", "MXN", 127753.16169],
        "case10": [7845.95, "GBP", "SZL", 149682.41067]
    };
}

function invalidDataEval() returns string[][] {
    return [
        ["ABC", "GBP"],
        ["AUD", "AAA"],
        ["", "USD"],
        ["", ""],
        ["***", "xxx"]
    ];
}
