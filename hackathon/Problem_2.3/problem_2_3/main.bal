import ballerina/sql;
import ballerina/io;
import ballerinax/java.jdbc;

type HighPayment record {
    string name;
    string department;
    decimal amount;
    string reason;
};

public function main() {
    HighPayment[]|error result =  getHighPaymentDetails("./db/gofigure", 3000);
    if result is error {
        io:println("no results");
    } else {
        io:println(result);
    }
}

function getHighPaymentDetails(string dbFilePath, decimal  amount) returns HighPayment[]|error {
    //Add your logic here.
    jdbc:Client dbClient =  check new ("jdbc:h2:file:"+dbFilePath,"root", "root");

    sql:ParameterizedQuery query = `SELECT Employee.name, Employee.department, Payment.amount, Payment.reason 
                                    FROM Payment
                                    INNER JOIN Employee ON Payment.employee_id=Employee.employee_id
                                    WHERE Payment.amount > ${amount}`;
    stream<HighPayment, sql:Error?> resultStream = dbClient->query(query);
    HighPayment[] payments = [];
    int i = 0;

    check from HighPayment payment in resultStream
        do {
            payments[i] = payment;
            i += 1;
        };

    return payments;
}
