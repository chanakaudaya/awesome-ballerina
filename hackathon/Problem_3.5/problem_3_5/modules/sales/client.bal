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
    # Get total sales
    #
    # + year - Query param to specify the year   
    # + quarter - Optional query param quarter 
    # + return - Ok 
    remote isolated function get(int year, string? quarter = ()) returns Sales[]|error {
        string resourcePath = string `/`;
        map<anydata> queryParam = {"year": year, "quarter": quarter};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        Sales[] response = check self.clientEp->get(resourcePath);
        return response;
    }
}
