import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;

public function main() {
    int x = addEmployee("./db/invaliddb", "John Doe", "Omaha", "Sales", 24);
    io:println(x);
}

function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {
    //Add your logic here
    jdbc:Client|sql:Error dbClient =  new ("jdbc:h2:file:"+dbFilePath,"root", "root");
    if dbClient is sql:Error {
        return -1;
    }
    
    sql:ExecutionResult|sql:Error result = dbClient->execute(`INSERT INTO Employee(name, city, department, age)
                                                        VALUES (${name}, ${city}, ${department}, ${age})`);
    if result is sql:Error {
        return -1;
    }
    int returnVal = <int>result.lastInsertId;
    
    sql:Error? x = dbClient.close();
    if x is sql:Error {
        return -1;
    }
    
    if returnVal == 0 {
        return -1;
    } else {
        return returnVal;
    }
}
