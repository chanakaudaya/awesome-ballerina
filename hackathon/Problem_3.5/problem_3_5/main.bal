import problem_3_5.customers;
import problem_3_5.sales;
import ballerina/http;
import ballerina/io;

type Q "Q1"|"Q2"|"Q3"|"Q4";

type Quarter [int, Q];

type SalesResponse record {
    record {|
    string customerId;
    decimal amount;
    Q quarter;
    int year;
    |} [] salesData;
    }; 

type TopCustomer record {
    readonly string customerId;
    float amount;
};

function findTopXCustomers(Quarter[] quarters, int x) returns customers:Customer[]|error {
    // TODO Implement your logic here
    final http:Client custEndpoint = check new ("http://localhost:8080/customers");
    final http:Client salEndpoint = check new ("http://localhost:8080/sales");

// Creates a `table` with members of the `Employee` type, where each
// member is uniquely identified using their `name` field.
table<TopCustomer> key(customerId) topCustomers = table [];

    foreach Quarter q in quarters {
        string year = q[0].toString();
        Q quarter = q[1];
        json sale = check salEndpoint->get("/?year="+year+"&quarter="+quarter.toString());
        sales:SalesArr ss = check sale.cloneWithType(sales:SalesArr);

        int c = 0;
        while c < ss.length() {
            if(topCustomers.hasKey(ss[c].customerId)) {
                TopCustomer tc = topCustomers.get(ss[c].customerId);
                tc.amount = tc.amount + ss[c].amount;
            } else {
            TopCustomer tc = {customerId: ss[c].customerId, amount: ss[c].amount};
            topCustomers.add(tc);
            }
            c += 1;
        }
       // SalesResponse ss = check sale.cloneWithType(SalesResponse);

        // int c = 0;
        // while c < ss.salesData.length() {
        //     TopCustomer tc = {customerId: ss.salesData[c].customerId, amount: ss.salesData[c].amount};
        //     topCustomers.add(tc);
        //     c += 1;
        // }
    }

    TopCustomer[] sorted = from var t in topCustomers
                            order by t.amount descending
                            limit x
                            select t;
    io:println(sorted);

    customers:Customer[] results = [];

    foreach TopCustomer cust in sorted {
        json resp = check custEndpoint->get("/"+cust.customerId);
        io:println(resp);
        customers:Customer res = check resp.cloneWithType(customers:Customer);
        results.push(res);
    }
    
    return results;
}
