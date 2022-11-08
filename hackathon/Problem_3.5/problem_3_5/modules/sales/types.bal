public type SalesArr Sales[];

# Represents total sales per customer
public type Sales record {
    # Customer's ID
    string customerId;
    # Total amount of sales for the customer
    float amount;
    # Quarter in which these sales were reported
    string quarter;
    # Year for which these sales values belong
    int year;
};
