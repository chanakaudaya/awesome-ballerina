public type CustomerArr Customer[];

# Represents a customer's address
public type Address record {
    string street;
    string city;
    string country;
    string postalCode;
};

# Represents a customer
public type Customer record {
    string id;
    string firstName;
    string lastName;
    # Represents a customer's address
    Address address;
};
