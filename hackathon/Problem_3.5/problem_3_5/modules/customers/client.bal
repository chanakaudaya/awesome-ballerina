import ballerina/http;

public isolated client class Client {
    final http:Client clientEp;
    # Gets invoked to initialize the `connector`.
    #
    # + clientConfig - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(string serviceUrl, http:ClientConfiguration clientConfig =  {}) returns error? {
        http:Client httpEp = check new (serviceUrl, clientConfig);
        self.clientEp = httpEp;
        return;
    }
    # List customers
    #
    # + return - Ok 
    remote isolated function get() returns Customer[]|error {
        string resourcePath = string `/`;
        Customer[] response = check self.clientEp->get(resourcePath);
        return response;
    }
    # Get a customer by ID
    #
    # + return - Ok 
    remote isolated function getBycustomerid(string byCustomerId) returns Customer|error {
        string resourcePath = string `/${getEncodedUri(byCustomerId)}`;
        Customer response = check self.clientEp->get(resourcePath);
        return response;
    }
}
