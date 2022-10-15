import ballerina/lang.array;
import ballerina/io;

function allocateCubicles(int[] requests) returns int[] {
    // Check the size of the requests array
    int length = requests.length();
    if (length > 97) {
        io:println("Number of requests are higher than the number of employees");
        return [];
    }

    // Assign the valid requests to results array
    int[] results = [];
    foreach int x in requests {
        if (x > 0 && x <66) {
            if (results.indexOf(x) is ()) {
                results.push(x);
            }
        }     
    }

    // Sort the results array
    int[] sortedResults = array:sort(results);

    return sortedResults;
}
