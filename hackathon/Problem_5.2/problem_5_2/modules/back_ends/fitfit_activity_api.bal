import ballerina/log;
import ballerina/os;
import ballerina/io;
import ballerina/http;

configurable int activity_port = 9091;

service /activities/v2 on new http:Listener(activity_port) {

    function init() {
        log:printInfo("Started Fifit activity API", host = "0.0.0.0", port = activity_port);
    }
    
    resource function get steps/user/[string id]() returns json|error {
        string dataSource = os:getEnv("DATA_SOURCE");
        if dataSource == "" {
            dataSource = "tests/resources/data.json";
        }
        json|io:Error data = io:fileReadJson(dataSource);
        if data is io:Error {
            return error("Failed to load data");
        }
        
        return {
            "activity": check data.stepsActivity
        };
    }

    resource function get heart/user/[string id]() returns json|error {
        string dataSource = os:getEnv("DATA_SOURCE");
        if dataSource == "" {
            dataSource = "tests/resources/data.json";
        }
        json|io:Error data = io:fileReadJson(dataSource);
        if data is io:Error {
            return error("Failed to load data");
        }
        
        return {
            "activity": check data.heartActivity
        };
    }
}
