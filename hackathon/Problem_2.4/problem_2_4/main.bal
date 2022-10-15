import ballerina/sql;
import ballerina/io;
import ballerinax/java.jdbc;

type Payments record {
    readonly int payment_id;
    decimal amount;
    string employee_name;
};

public function main() {
    string[]|error result =  getHighPaymentEmployees("./db/gofigure", 3000);
    if result is error {
        io:println("no results");
    } else {
        io:println(result);
    }
}

function getHighPaymentEmployees(string dbFilePath, decimal amount) returns string[]|error {
    //Add your logic here
        //Add your logic here.
    jdbc:Client dbClient =  check new ("jdbc:h2:file:"+dbFilePath,"root", "root");

    sql:ParameterizedQuery query = `SELECT Payment.payment_id, Payment.amount, Employee.name as employee_name 
                                    FROM Payment
                                    INNER JOIN Employee ON Payment.employee_id=Employee.employee_id`;
    stream<Payments, sql:Error?> resultStream = dbClient->query(query);
    table<Payments> key(payment_id) t = table [];

    int i = 0;

    check from Payments payment in resultStream
        do {
            t.add(payment);
            i += 1;
        };

    Payments[] highPayments = from var e in t
                        where e.amount > amount
                        order by e.employee_name
                        select e;
                       
    string[] names = [];
    foreach Payments p in highPayments {
        if names.indexOf(p.employee_name) is () {
            names.push(p.employee_name);
        }
    }
    return names;
}
