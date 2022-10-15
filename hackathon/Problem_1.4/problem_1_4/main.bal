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

public function main() returns error? {

    string inFile = "./tests/resources/example05_input.xml";
    string outFile = "./tests/resources/example05_output_expected_2.xml";

    error? processFuelRecordsResult = processFuelRecords(inFile, outFile);
//     xml x = xml
//             `<s:FuelEvents xmlns:s="http://www.so2w.org">
//     <s:FuelEvent employeeId="2312">
//         <s:odometerReading>230</s:odometerReading>
//         <s:gallons>18.561</s:gallons>
//         <s:gasPrice>4.56</s:gasPrice>
//     </s:FuelEvent>
//     <s:FuelEvent employeeId="2312">
//         <s:odometerReading>500</s:odometerReading>
//         <s:gallons>19.345</s:gallons>
//         <s:gasPrice>4.89</s:gasPrice>
//     </s:FuelEvent>
// </s:FuelEvents>`;

//     xmlns "http://www.so2w.org" as s;
//     xml fe = x.<s:FuelEvents>;
//     xml fes = fe/<s:FuelEvent>;
//     // xml xx = fes.children();
//     int j = 0;
//     map<int> startingOdos = {};
//     map<EmployeeFillUpSummary> outputs = {};
//     while j < fes.length() {
//         xml fuelEvent = fes[j];
//         j += 1;
//         string empidstr =  check fuelEvent.employeeId;
//         io:println(empidstr);
//         int empid = check int:fromString(empidstr);
//         io:println(empid);
//         int odo = check int:fromString((fuelEvent/<s:odometerReading>).data());
//         decimal gall = check decimal:fromString((fuelEvent/<s:gallons>).data());
//         decimal unit_cost = check decimal:fromString((fuelEvent/<s:gasPrice>).data()); 
//         decimal fuel_cost = unit_cost * gall;
//         int count = 1;

//         // check if the emp_id it already there in the outputs map
//         if outputs.hasKey(empidstr) {
//             EmployeeFillUpSummary output = outputs.get(empidstr);
//             output.gasFillUpCount += 1;
//             output.totalFuelCost += fuel_cost;
//             output.totalGallons += gall;
//             output.totalMilesAccrued = odo - startingOdos.get(empidstr);
//         } else {
//             EmployeeFillUpSummary output = {employeeId: empid, gasFillUpCount: count, totalFuelCost: fuel_cost, totalGallons: gall, totalMilesAccrued: 0};
//             startingOdos[empidstr] = odo;
//             outputs[empidstr] = output;
//         }

//     }

//     xml writeData = xml `<s:employeeFuelRecords xmlns:s="http://www.so2w.org">${from var {employeeId, gasFillUpCount, totalFuelCost, totalGallons, totalMilesAccrued} in outputs
//                     select xml`<s:employeeFuelRecord employeeId="${employeeId}">
//                                 <s:gasFillUpCount>${gasFillUpCount}</s:gasFillUpCount>
//                                 <s:totalFuelCost>${totalFuelCost}</s:totalFuelCost>
//                                 <s:totalGallons>${totalGallons}</s:totalGallons>
//                                 <s:totalMilesAccrued>${totalMilesAccrued}</s:totalMilesAccrued>
//                             </s:employeeFuelRecord>`}
//                         </s:employeeFuelRecords>`;
//     io:println(writeData);

//     return;
}

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    // Write your code here
    xml|io:Error x = io:fileReadXml(inputFilePath);
    if x is io:Error {
        return x;
    }

    xmlns "http://www.so2w.org" as s;
    xml fe = x.<s:FuelEvents>;
    xml fes = fe/<s:FuelEvent>;
    int j = 0;
    map<int> startingOdos = {};
    map<EmployeeFillUpSummary> outputs = {};
    while j < fes.length() {
        xml fuelEvent = fes[j];
        j += 1;
        string empidstr =  check fuelEvent.employeeId;
        int empid = check int:fromString(empidstr);
        int odo = check int:fromString((fuelEvent/<s:odometerReading>).data());
        decimal gall = check decimal:fromString((fuelEvent/<s:gallons>).data());
        decimal unit_cost = check decimal:fromString((fuelEvent/<s:gasPrice>).data()); 
        decimal fuel_cost = unit_cost * gall;
        int count = 1;

        // check if the emp_id it already there in the outputs map
        if outputs.hasKey(empidstr) {
            EmployeeFillUpSummary output = outputs.get(empidstr);
            output.gasFillUpCount += 1;
            output.totalFuelCost += fuel_cost;
            output.totalGallons += gall;
            output.totalMilesAccrued = odo - startingOdos.get(empidstr);
        } else {
            EmployeeFillUpSummary output = {employeeId: empid, gasFillUpCount: count, totalFuelCost: fuel_cost, totalGallons: gall, totalMilesAccrued: 0};
            startingOdos[empidstr] = odo;
            outputs[empidstr] = output;
        }

    }

    string[] orderedKeys = outputs.keys().sort();
    EmployeeFillUpSummary[] writableData = [];
    int k = 0;
    while k < orderedKeys.length() {
        EmployeeFillUpSummary outputLine = outputs.get(orderedKeys[k]);
        writableData[k] = outputLine;
        k += 1;
    }

    xml writeData = xml `<s:employeeFuelRecords xmlns:s="http://www.so2w.org">${from var {employeeId, gasFillUpCount, totalFuelCost, totalGallons, totalMilesAccrued} in writableData
                    select xml`<s:employeeFuelRecord employeeId="${employeeId}"><s:gasFillUpCount>${gasFillUpCount}</s:gasFillUpCount><s:totalFuelCost>${totalFuelCost}</s:totalFuelCost><s:totalGallons>${totalGallons}</s:totalGallons><s:totalMilesAccrued>${totalMilesAccrued}</s:totalMilesAccrued></s:employeeFuelRecord>`}</s:employeeFuelRecords>`;

    io:Error? result = io:fileWriteXml(outputFilePath, writeData);
    return result;

}
