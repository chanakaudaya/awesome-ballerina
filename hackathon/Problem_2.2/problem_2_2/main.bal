import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;

type paymentDetails record {|
    int employee_id;
    decimal amount;
    string reason;
    string date;
|};

public function main() returns error? {
    int[] payments = check addPayments("./db/gofigure", "tests/resources/payments.json");
    io:println(payments);
}

function addPayments(string dbFilePath, string paymentFilePath) returns error|int[] {
    //Add your logich here
    json content = check io:fileReadJson(paymentFilePath);
    if content is () {
        return error("no data");
    }
    paymentDetails[] payments = check content.cloneWithType();
    int[] generatedIds = [];

    if payments.length() > 0 {

        jdbc:Client dbClient = check new ("jdbc:h2:file:" + dbFilePath, "root", "root");
        sql:ParameterizedQuery[] insertQueries = from var item in payments
            select `INSERT INTO Payment( date, amount, employee_id, reason)
                                                    VALUES (${item.date}, ${item.amount}, ${item.employee_id}, ${item.reason})`;

        sql:ExecutionResult[] result = check dbClient->batchExecute(insertQueries);
        foreach var summary in result {
            generatedIds.push(<int>summary.lastInsertId);
        }
        // Closes the JDBC client.
        check dbClient.close();
        return generatedIds;

    }

    return error("empty data");
}
