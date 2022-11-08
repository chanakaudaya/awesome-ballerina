import ballerina/log;
import ballerina/io;
import ballerina/http;
import ballerina/os;

configurable int sleep_summary_port = 9091;

service /activities/summary on new http:Listener(sleep_summary_port) {

    function init() {
        log:printInfo("Fitfit sleep summary API started", host = "0.0.0.0", port = sleep_summary_port, protocol = "HTTP");
    }

    resource function get sleep/user/[string id]() returns json|error {
        string dataSource = os:getEnv("DATA_SOURCE");
        if dataSource == "" {
            dataSource = "tests/resources/data.json";
        }
        json|io:Error data = io:fileReadJson(dataSource);
        if data is io:Error {
            return error("Failed to load data");
        }
        return data;
    }
}
