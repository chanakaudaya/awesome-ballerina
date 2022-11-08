import ballerina/http;
import ballerina/io;
import ballerina/log;

# Type to represent a quarter
type Q "Q1"|"Q2"|"Q3"|"Q4";

# Represents total sales per customer
type Sales record {|
    # Customer's ID
    readonly string customerId;
    # Total amount of sales for the customer
    readonly decimal amount;
    # Quarter in which these sales were reported
    readonly Q quarter;
    # Year for which these sales values belong
    readonly int year;
|};

type SalesResponse record {|
    *http:Ok;

    map<string> headers = {
        "content-type": "application/json"
    };
    Sales[] body;
|};

isolated service /sales on httpEP {

    private final table<Sales> key(customerId, year, quarter) sales = table [];

    function init() returns error? {
        json data = check io:fileReadJson("tests/resources/sales.json");
        if data is json[] {
            foreach json item in data {
                Sales sales = check item.fromJsonWithType(Sales);
                self.sales.add(sales);
            }
        }
    }

    # Get total sales
    #
    # + year - Query param to specify the year  
    # + quarter - Optional query param quarter
    # + return - List of sales
    isolated resource function get .(int year, string? quarter) returns SalesResponse|http:BadRequest {
        Q? q = ();
        if quarter is string {
            Q|error val = quarter.ensureType(Q);
            if val is error {
                log:printWarn("Invalid quarter", q = quarter);
                return {body: "Invalid quarter provided"};
            }

            q = val;
        }

        lock {
            Sales[] filteredSales = from var sales in self.sales
                where sales.year == year
                where quarterMatches(q, sales.quarter)
                select sales;
            return <SalesResponse>{
                body: filteredSales.cloneReadOnly()
            };
        }
    }
}

isolated function quarterMatches(Q? q1, Q q2) returns boolean {
    return q1 == () || q1 == q2;
}
