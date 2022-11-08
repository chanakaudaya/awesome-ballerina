import ballerina/os;
import ballerina/io;
import ballerina/log;
import ballerina/http;

configurable int fitfit_port = 9091;

listener http:Listener fifit_ls = new (fitfit_port, {
    secureSocket: {
        key: {
            certFile: "./resources/public.crt",
            keyFile: "./resources/private.key"
        }
    }
});

@http:ServiceConfig {
    auth: [
        {
            oauth2IntrospectionConfig: {
                url: "https://localhost:9445/oauth2/introspect",
                tokenTypeHint: "access_token",
                clientConfig: {
                    customHeaders: {"Authorization": "Basic YWRtaW46YWRtaW4="},
                    secureSocket: {
                        cert: "./resources/public.crt"
                    }
                }
            }
        }
    ]
}
service /activities on fifit_ls {

    function init() {
        log:printInfo("Fitfit steps API started", host = "0.0.0.0", port = fitfit_port, protocol = "HTTPS");
    }

    resource function get steps/user/[string id]/'from/[string fromDate]/to/[string toDate]() returns json|error {
        string dataSource = os:getEnv("DATA_SOURCE");
        if dataSource == "" {
            dataSource = "resources/data.json";
        }
        json|io:Error data = io:fileReadJson(dataSource);
        if data is io:Error {
            return error("Failed to load data");
        }
        
        return {
            "activities-steps": check data.stepsActivity
        };
    }
}
