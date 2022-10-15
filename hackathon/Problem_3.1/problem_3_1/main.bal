import ballerina/http;
import ballerina/io;
# The exchange rate API base URL
configurable string apiUrl = "http://localhost:8090";

type Rates record {|
    string base;
    map<decimal> rates;
|};

public function main() returns error? {
    decimal x = check convertSalary(1000, "USD", "LKR");
    io:println(x);
}

# Convert provided salary to local currency
#
# + salary - Salary in source currency
# + sourceCurrency - Soruce currency
# + localCurrency - Employee's local currency
# + return - Salary in local currency or error
public function convertSalary(decimal salary, string sourceCurrency, string localCurrency) returns decimal|error {
    // TODO: Write your code here
    // Creates a new client with the backend URL.
    final http:Client clientEndpoint = check new (apiUrl);
    int salaryInt = <int>salary;
    if (salaryInt < 500 || salaryInt >10000) {
        return error("invalid salary");
    }
    io:println("Before endpoint call");
    Rates resp = check clientEndpoint->get("/rates/"+sourceCurrency);
    

    if resp.rates.hasKey(localCurrency) {
        return (resp.rates.get(localCurrency) * salary);
    }

    return 0;
}
