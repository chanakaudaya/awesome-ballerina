import ballerina/os;
import ballerina/io;
import ballerina/auth;
import ballerina/log;
import ballerina/http;

configurable int insureEveryonePort = 9092;
configurable string USER_SERVICE_USERNAME = "alice";
configurable string USER_SERVICE_PASSWORD = "123";

listener http:Listener insureEveryoneListener = new (insureEveryonePort, {
    secureSocket: {
        key: {
            certFile: "./resources/public.crt",
            keyFile: "./resources/private.key"
        }
    }
});
service /insurance on insureEveryoneListener {

    function init() {
        log:printInfo("Insure everyone user API started", host = "0.0.0.0", port = insureEveryonePort, protocol = "HTTPS");
    }

    resource function get user/[string userId](@http:Header {name: "Authorization"} string header) returns json|http:Unauthorized|error {
        http:Unauthorized? result = authenticateUser(header);
        if result is http:Unauthorized {
            return result;
        }
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

function authenticateUser(string header) returns http:Unauthorized? {
    if header.startsWith(http:AUTH_SCHEME_BASIC + " ") {
        string credential = header.substring(6, header.length());
        [string, string]|auth:Error result = auth:extractUsernameAndPassword(credential);
        if result is [string, string] {
            [string, string] [username, password] = result;
            if username == USER_SERVICE_USERNAME && password == USER_SERVICE_PASSWORD {
                return;
            } else {
                return <http:Unauthorized>{body: "Invalid credentials."};
            }
        } else {
            return <http:Unauthorized>{body: "Invalid Base64 encoded credential."};
        }
    } else {
        return <http:Unauthorized>{body: "Invalid 'Authorization' header."};
    }
}
