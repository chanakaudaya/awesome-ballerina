import ballerina/io;

type FillUpEntry record {|
    int employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
|};

type EmployeeFillUpSummary record {|
    int employeeId;    
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int totalMilesAccrued;
|};

public function main() {
    // string inFile = "./tests/resources/example02_input.json";
    // string outFile = "./tests/resources/example02_output_expected_2.json";

    // error? processFuelRecordsResult = processFuelRecords(inFile, outFile);
}


function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
     // Write your code here
    json|io:Error content = io:fileReadJson(inputFilePath);
    if content is io:Error {
        return content;
    }
    map <int> startingOdos = {};
    map<EmployeeFillUpSummary> outputs = {};
    FillUpEntry[] emp = check content.cloneWithType();
    int x = 0;
    while x < emp.length() {
        FillUpEntry emp1 = emp[x];
        int empid = emp1.employeeId;
        string empidstr = empid.toString();
        int odo = emp1.odometerReading;
        decimal gall = emp1.gallons;
        decimal unit_cost = emp1.gasPrice;
        decimal fuel_cost = unit_cost * gall;
        int count = 1;
        x +=1;

        // check if the emp_id it already there in the outputs map
        if outputs.hasKey(empidstr) {
            EmployeeFillUpSummary output = outputs.get(empidstr);
            output.gasFillUpCount += 1;
            output.totalFuelCost += fuel_cost;
            output.totalGallons += gall;
            output.totalMilesAccrued = odo - startingOdos.get(empidstr);
        } else {
            EmployeeFillUpSummary output = { employeeId: empid, gasFillUpCount: count, totalFuelCost: fuel_cost, totalGallons: gall, totalMilesAccrued: 0};
            startingOdos[empidstr] = odo;
            outputs[empidstr] = output;
        }

    }

    string[] orderedKeys = outputs.keys().sort();
    EmployeeFillUpSummary[] writableData = [];

    int j = 0;
    while j < orderedKeys.length() {
        EmployeeFillUpSummary outputLine = outputs.get(orderedKeys[j]);
        writableData[j] = outputLine;
        j += 1;
    }

    json jsonWrite = writableData.toJson();

    io:Error? result = io:fileWriteJson(outputFilePath, jsonWrite);
    return result;
    

}
