import ballerina/test;

@test:Config {
    dataProvider: validData,
    groups: ["sample"]
}
function testGetTopXBillionaires(string[] countries, int 'limit, string[] expected) {
    string[]|error actual = getTopXBillionaires(countries, 'limit);
    if actual is error {
        test:assertFail("Failed to fetch top billionaires");
    }
    test:assertEquals(actual, expected);
}

function validData() returns map<[string[], int, string[]]> {
    return {
        "case1": [
            ["United States"],
            3,
            ["Elon Musk", "Jeff Bezos", "Bill Gates"]
        ],
        "case2": [
            ["China", "India"],
            5,
            ["Mukesh Ambani", "Gautam Adani & family", "Zhong Shanshan", "Zhang Yiming", "Ma Huateng"]
        ]
    };
}
