import ballerina/http;

http:Client cl = check new (string `http://localhost:${port}`);