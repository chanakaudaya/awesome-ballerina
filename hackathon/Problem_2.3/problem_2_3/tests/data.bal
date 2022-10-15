function data() returns map<[string, decimal, HighPayment[]]>|error {
    map<[string,  decimal, HighPayment[]]> dataSet = {
        "Test1": ["./db/gofigure", 3000, [{"name":"Anita Bath","department":"Marketing", "amount":3400, "reason": "Stationary"},
                    {"name":"Amanda Hug","department":"Engineering", "amount":4400, "reason": "Travel expenses"}]]
    };
    return dataSet;
}

