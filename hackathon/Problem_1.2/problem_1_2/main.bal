import ballerina/io;

type outputData record {
    int employee_id;
    int gas_fillup_count;
    decimal total_fuel_cost;
    decimal total_galloons;
    int total_miles_accured;
    int starting_odo;
};

public function main() {
    string inFile = "./tests/resources/example05_input.csv";
    string outFile = "./tests/resources/example05_output_expected_2.csv";

    error? processFuelRecordsResult = processFuelRecords(inFile, outFile);
}

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    // Write your code here
    string[][]|io:Error content = io:fileReadCsv(inputFilePath);
    if content is io:Error {
        return content;
    }
    map<outputData> outputs = {};

    foreach string[] row in content {
        string empidstr = row[0].trim();
        int empid =  check int:fromString(empidstr);
        int odo = check int:fromString(row[1].trim());
        decimal gall = check decimal:fromString(row[2].trim());
        decimal unit_cost = check decimal:fromString(row[3].trim());
        decimal fuel_cost = unit_cost * gall;
        int count = 1;

        // check if the emp_id it already there in the outputs map
        if outputs.hasKey(empidstr) {
            outputData output = outputs.get(empidstr);
            output.gas_fillup_count += 1;
            output.total_fuel_cost += fuel_cost;
            output.total_galloons += gall;
            output.total_miles_accured = odo - output.starting_odo;
        } else {
            outputData output = { employee_id : empid, gas_fillup_count: count, total_fuel_cost : fuel_cost, total_galloons: gall, total_miles_accured: 0, starting_odo: odo};
            outputs[empidstr] = output;

        }

    }

    //outputData[] writeData = outputs.toArray();
    string[] orderedKeys = outputs.keys().sort();
    string[][] writableData = [];
    // int i = 0;
    // foreach outputData outputLine in outputs {
    //     string[] output = [];
    //     output[0] = outputLine.employee_id.toString();
    //     output[1] = outputLine.gas_fillup_count.toString();
    //     output[2] = outputLine.total_fuel_cost.toString();
    //     output[3] = outputLine.total_galloons.toString();
    //     output[4] = outputLine.total_miles_accured.toString();
    //     writableData[i] = output;
    //     i += 1;
    // }

    int j = 0;
    while j < orderedKeys.length() {
        outputData outputLine = outputs.get(orderedKeys[j]);
        string[] output = [];
        output[0] = outputLine.employee_id.toString();
        output[1] = outputLine.gas_fillup_count.toString();
        output[2] = outputLine.total_fuel_cost.toString();
        output[3] = outputLine.total_galloons.toString();
        output[4] = outputLine.total_miles_accured.toString();
        writableData[j] = output;
        j += 1;
    }

    io:Error? result = io:fileWriteCsv(outputFilePath, writableData);
    return result;
    
}
