import ballerina/http;

configurable int port = 8080;

listener http:Listener httpEP = check new (port);
