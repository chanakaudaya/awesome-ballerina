import ballerina/http;
import ballerina/os;
import ballerina/io;
import ballerina/log;

configurable int user_port_eval = 9092;

service / on new http:Listener(user_port_eval) {

    boolean errorState = true;

    function init() {
        log:printInfo("Insure everyone user API started", host = "0.0.0.0", port = user_port_eval, protocol = "HTTP");
    }

    resource function get insurance1/user/[string userId]() returns json|http:InternalServerError|error {
        if self.errorState {
            http:InternalServerError ise = {
                body: { message: "Oops! Something went wrong!"}
            };
            return ise;
        } else {
            self.errorState = true;
            return check self.getUserResponse();
        }
    }

    resource function get insurance2/user/[string userId]() returns json|http:InternalServerError|error {
        if !self.errorState {
            http:InternalServerError ise = {
                body: { message: "Oops! Something went wrong!"}
            };
            return ise;
        } else {
            self.errorState = false;
            return check self.getUserResponse();
        }
    }

    function getUserResponse() returns json|error {
        string dataSource = os:getEnv("DATA_SOURCE");
        if dataSource == "" {
            dataSource = "resources/data.json";
        }
        json|io:Error data = io:fileReadJson(dataSource);
        if data is io:Error {
            return error("Failed to load data");
        }
        
        return {
            "user": check data.user
        };
    }
}
