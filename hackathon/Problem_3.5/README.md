# 3.5 Client Stubs for Customer Success

## Problem Statement

The customer success team of your company, Insure Everyone, is planning on improving customer satisfaction by providing a priority service to its top customers. They plan to decide who are the priority customers based on accumulated sales in a selected set of quarters (ex: `2021Q1`, `2020Q3`, etc).  A _quarter_ is represented by a year (**y**) and one of `Q1, Q2, Q3, Q4` (**q**).

Given a set of quarters (i.e, a set of **y**, **q** combinations), you have been asked to write a program to find the top **'x'** customers in the provided quarters based on the sum of sales during those quarters.

You have been given access to your company's _customer service_ and _sales service_. And you have been provided with the _OpenAPI specifications_ to connnect to those 2 microservices. Your task is to write the Ballerina program to find the top **x** customers in the provided quarters.

>**Note**: that the provided microservices were not originally developed to query the exact data you will require. Therefore, you will have to do some processing yourself to come up with the solution.

## Constraints

* 2 <= x <=10
* 2018 <= y <= 2022
* `q` is one of `Q1, Q2, Q3, Q4`
* 2 <= len(quarters) < 18

## Definition

You have to use the following skeleton to implement your logic. Modules `customers` and `sales` will be added with generated clients as in instructions provided in the following section.

```ballerina
import Problem_3_5.customers;
import Problem_3_5.sales;

type Q "Q1"|"Q2"|"Q3"|"Q4";

type Quarter [int, Q];

function findTopXCustomers(Quarter[] quarters, int x) returns customers:Customer[]|error {
    // TODO Implement your logic here
    return [];
}
```

> Here, `Customer` type will be auto generated when you generate the client from OpenAPI specification.

## Test Environment

* You can run the tests with `bal test` and corresponding backend (sales and customer services) will start along with the tests.

### Generate Clients

You can use the following commands to generate clients for both services. Generated clients will be put into `customers` and `sales` modules.

* `bal openapi -i sales_openapi.yaml --mode client -o modules/sales`
* `bal openapi -i customers_openapi.yaml --mode client -o modules/customers`

> Note: Compilation errors will be no longer appear once you generate the clients under the correct modules as in the above commands.

### Service URLs

```
Customer Service: http://localhost:8080/customers
Sales Service: http://localhost:8080/sales
```

## Examples

### Example 1

Sample Input:

```
Quarters: [ [2022, "Q1"], [2021, "Q3"] ]
Limit: 3
```

Sample Output:
```
["1","2","3"]
```

### Example 2

Sample Input:

```
Quarters: [ [2019, "Q1"], [2019, "Q2"] ]
Limit: 2
```

Sample Output:

```
["4"]
```

> Explanation: During Q1 and Q2 of 2019, only 1 customer has made purchases.

## Hints

* Have a look at the [table syntax](https://ballerina.io/learn/by-example/table-syntax/) and [query expressions](https://ballerina.io/learn/by-example/query-expressions/)
