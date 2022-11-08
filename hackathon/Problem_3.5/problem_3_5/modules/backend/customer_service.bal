import ballerina/http;
import ballerina/io;

# Represents a customer's address
type Address record {|
    string street;
    string city;
    string country;
    string postalCode;
|};

# Represents a customer
type Customer record {|
    readonly string id;
    string firstName;
    string lastName;

    Address address;
|};

# Customer service
isolated service /customers on httpEP {

    private final table<Customer> key(id) customers = table [];

    function init() returns error? {
        json data = check io:fileReadJson("tests/resources/customers.json");
        Customer[] customers = [];
        if data is json[] {
            foreach var item in data {
                Customer c = check item.fromJsonWithType(Customer);
                customers.push(c);
                self.customers.add(c);
            }
        }
    }

    # List customers
    # + return - List of customers
    isolated resource function get .() returns Customer[] {
        lock {
            return self.customers.toArray().cloneReadOnly();
        }
    }

    # Get a customer by ID
    #
    # + customerId - Customer ID to get
    # + return - Customer or Not Found
    isolated resource function get [string byCustomerId]() returns Customer|http:NotFound {
        lock {
            if !self.customers.hasKey(byCustomerId) {
                return {body: "Invalid customer ID"};
            }

            return self.customers.get(byCustomerId).cloneReadOnly();
        }
    }
}
