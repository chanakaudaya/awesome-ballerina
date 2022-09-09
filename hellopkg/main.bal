import ballerina/io;

// This is a global variable
string greeting = "Hello";

public function main() {
    // This is a local variable
    string name = "Ballerina";

    // Calling the built in functions
    io:println("Hello, World!");
    io:println(greeting, " ", name);

    // Declaring variables here
    int x = 5;
    int y = 10;

    // String concatenation with comma separated values
    io:println("sum of ", x, " and ", y, " is ", add(x,y));

    // call function
    dataTypes();
    stringTypes();
    arrayTypes();
    mapTypes();
}

// This is a local function
function add(int x, int y) returns int {
    int sum = x + y;
    return sum;
}

function dataTypes() {
    int n = 3;
    float m = 1.23;

    // explicit conversion is required from int to float
    float o = m + <float>n;
    io:println("The sum is ", o);

    // boolean data type
    boolean flag = false;
    int x = flag ? 1 : 2;
    io:println("The value is ", x);
}

function stringTypes() {
    string ss = "hello world";
    int nn = ss.length();
    string s = ss.substring(0,nn);
    int n = s.length();
    io:println("The substring is ", s, " and it has ", n, " characters");
}

function arrayTypes() {
    int[] v = [1,3,5];
    int x = v[1];
    io:println("The second member of array is ", x);
    int total = 0;

    // usage of foreach operator
    foreach int i in v {
        total += i;
    }
    io:println("Total value of the elements in the array is ", total);
    
}

function mapTypes() {
    map<int> m = {
        "x": 1,
        "y": 2
    };
    m["x"] = 24;
    io:println("The new value of x is ", m["x"]);
    
}
