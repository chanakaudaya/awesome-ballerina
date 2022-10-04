import ballerina/io;

// Ballerina does not support the notion of exceptions
// Errors are handled as part of the normal control flow

// Define error sub types
type XErr distinct error;
type YErr distinct error;
type Err XErr|YErr;

public function main() {
    io:println("Hello, World!");

    // Standard error handling with conditional
    int|error ret = parse("123");
    if ret is error {
        io:println("Error occurred ", ret.toString());
    } else {
        io:println("The value is ", ret);
    }
    io:println(subTypeFunction());

}

function parse(string s) returns int|error {
    int n = 0;
    int[] cps = s.toCodePointInts();

    foreach int cp in cps {
        int p = cp - 0x30;
        if p < 0 || p > 9 {
            return error("not a digit");
        }
        n = n * 10 + p;
        
    }
    return n;
    
}

function errorFunction(int i) returns error|int {
    // Shorthand error handling with check statement
    int val = check parse("123");
    return  val;
}

function subTypeFunction() returns string {
    Err err = error XErr("X is not working");
    return err is XErr ? "X" : "Y";
    
}
