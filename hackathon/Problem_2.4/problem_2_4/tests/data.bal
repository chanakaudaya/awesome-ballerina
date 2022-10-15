function data() returns map<[string, decimal, string[]]>|error {
    map<[string,  decimal, string[]]> dataSet = {
        "Test1": ["./db/gofigure", 3000, ["Amanda Hug", "Anita Bath"]],
        "Test2": ["./db/gofigure", 1100, ["Amanda Hug", "Anita Bath", "Perry Scope"]]
    };
    return dataSet;
}

