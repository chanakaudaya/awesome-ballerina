# 3.4 Fit for Resiliency

## Problem statement

This problem is the same as problem 3.3 but security requirements are replaced with resiliency requirements. Therefore, none of the endpoints are secured. In other words you don’t need any security configuration as in the previous question (3.3) to connect to the endpoints. Insure Everyone has been quite successful with its collaboration with Fitfit company. Their user base increased a lot resulting in high load on the systems. However, it seems both endpoints are struggling to handle the new load.

Your task is to write a function to implement the same logic as in problem 3.3 Part B but replace security requirements with resiliency requirements. The definition of the expected function is given under the section `Definition`.

## Definition

Following is the definition of the function defined in `main.bal`.

```ballerina
enum Types {
    SILVER,
    GOLD,
    PLATINUM
}

type Gift record {
    boolean eligible;
    int score;
    # format yyyy-mm-dd
    string 'from;
    # format yyyy-mm-dd
    string to;
    record {|
        Types 'type;
        # message string: Congratulations! You have won the ${type} gift!;
        string message;
    |} details?;
};

function findTheGift(string userID, string 'from, string to) returns Gift|error
```

## Resiliency

### Fitfit REST API

The client connecting to this endpoint should be resilient enough to handle long latencies and 500 internal server error responses. Your `http:Client` should timeout in 10s and retry at least `3` times with the interval of 3 seconds.

### Insure Everyone REST API

The client connecting to this endpoint should be resilient enough to failover to the second endpoint if there is a 500 internal server error response or high latencies. Your `http:Client` should timeout in `10s` and failover to the next endpoint with the interval of `3s`.

## Test Environment

The back-ends are automatically started and stopped every time you do `bal test`. As mentioned above, none of the back-ends are secured and use HTTP as the transport protocol.

### Fitfit REST API

The Fitfit REST API is available under the below URL, and the following is a sample response. Please note that this is a mock backend created for this problem. Therefore, it always returns the same values regardless of the date range.

```http
GET http://localhost:9091/activities/steps/user/1/from/2022-01-01/to/2022-03-31
```

```http
HTTP/1.1 200 OK
content-type: application/json
connection: close
server: ballerina
date: Wed, 16 Mar 2022 22:30:04 +0530
content-encoding: gzip
content-length: 138

{

  "activities-steps": [

    {

      "date": "2022-01-01",
      "value": 2504
    },
    {

      "date": "2022-01-07",
      "value": 3723
    },
    {

      "date": "2022-02-03",
      "value": 8304
    },
    {

      "date": "2022-02-10",
      "value": 7861
    },
    {

      "date": "2022-03-10",
      "value": 837
    },
    {

      "date": "2022-03-15",
      "value": 4103
    },
    {

      "date": "2022-03-20",
      "value": 1698
    }
  ]
}
```

### Insure Everyone REST API

The Insure Everyone REST API is available under the below URL, and the following is a sample response. Please note that this is a mock backend created for this problem. Therefore, it always returns the same values regardless of the user ID. Both endpoints return the same response. Therefore, in case one fails the other can be used as the failover endpoint to get the response.

```http
GET http://localhost:9092/insurance1/user/1
GET http://localhost:9092/insurance2/user/1
```

```http
HTTP/1.1 200 OK
content-type: application/json
connection: close
server: ballerina
date: Sun, 20 Mar 2022 11:18:57 +0530
content-encoding: gzip
content-length: 164

{

  "user": {

    "name": "Joe Miden",
    "display-name": "Joe",
    "age": 70,
    "email": "joe.miden@zmail.com",
    "state": "California",
    "city": "SF",
    "address": "450 R StLincoln, California(CA), 95648"
  }
}
```

## Constraints

Requests to each endpoint must be performed in parallel to achieve a response time below 30 seconds.

## Example
#### Input
- User ID: `1`  
- From Date: `2022-01-01`  
- To Date: `2022-03-31`  

#### Output

```json
{
   "eligible": true,
   "score": 9676,
   "from": "2022-01-01",
   "to": "2022-03-31",
   "details": {
      "type": "SILVER",
      "message": "Congratulations! You have won the SILVER gift!"
   }
}
```
## Hints
- [Refer to the HTTP client resiliency examples in Ballerina By Examples (BBEs)](https://ballerina.io/learn/by-example/#resiliency)
- [HTTP client retry configuration](https://lib.ballerina.io/ballerina/http/2.2.1/records/RetryConfig) 
- [HTTP failover client documentation](https://lib.ballerina.io/ballerina/http/2.2.1/clients/FailoverClient)
- [Refer to the concurrency examples in BBEs](https://ballerina.io/learn/by-example/#concurrency)
