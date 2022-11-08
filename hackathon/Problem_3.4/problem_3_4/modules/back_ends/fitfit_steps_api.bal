import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/os;
import ballerina/lang.runtime;

configurable int steps_port_eval = 9091;

service /activities on new http:Listener(steps_port_eval) {

    private int count;

    function init() {
        log:printInfo("Fitfit steps API started", host = "0.0.0.0", port = steps_port_eval, protocol = "HTTP");
        self.count = 0;
    }

    resource function get steps/user/[string id]/'from/[string fromDate]/to/[string toDate]() returns json|http:InternalServerError|error {
        string dataSource = os:getEnv("DATA_SOURCE");
        if dataSource == "" {
            dataSource = "resources/data.json";
        }
        json|io:Error data = io:fileReadJson(dataSource);
        if data is io:Error {
            return <http:InternalServerError>{
                body: { message: "Failed to load data"}
            };
        }
        
        json response = {
            "activities-steps": check data.stepsActivity
        };
        
        self.count += 1;
        if self.count % 3 == 0 {
            self.count = 0;
            return response;
        } else if self.count % 2 == 0  {
            http:InternalServerError ise = {
                body: { message: "Oops! Something went wrong!"}
            };
            return ise;
        } else {
            runtime:sleep(40);
            return response;
        }
    }
}
