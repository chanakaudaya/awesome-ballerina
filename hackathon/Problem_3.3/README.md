# 3.3 Fit for Security

## Problem Statement

You are a microservices developer of the company Insure Everyone. Insure Everyone is in the business of providing life insurance for its customers. They want to promote their new campaign focused on healthy living. Every insurance holder is encouraged to live a healthy life by receiving a gift package based on activity. This is done in collaboration with Fitfit. Fitfit provides devices that monitor certain activities of an individual. These include metrics like steps taken, time spent on the elliptical machine, the jogging distance, etc.

### Part A

Insure Everyone is planning to use Fitfit’s REST API to get the number of steps a person has taken during each quarter of the year and then reward their customers based on their performance. Your task is to write a simple function to represent the logic of the microservice. The function must connect to Fitfit’s REST API and then figure out if a given customer is eligible for a quarterly gift and the type of the gift. The definition of the function is given under the section `Definition`.

Following are the conditions for each gift type. Please note that the age range is between 0 - 99. Therefore, you do not need to consider age values less than 0 or greater than 99.

```ballerina
const int SILVER_BAR = 5000;
const int GOLD_BAR = 10000;
const int PLATINUM_BAR = 20000;
 
int score = totalSteps;

Silver category: score >= SILVER_BAR && score < GOLD_BAR
Gold category: score >= GOLD_BAR && score < PLATINUM_BAR
Platinum category: score >= PLATINUM_BAR
```

#### Definition
Following is the definition of the function which can be found in `main.bal`.

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

function findTheGiftSimple(string userID, string 'from, string to) returns Gift|error
```

#### Security

You must use the Refresh Token grant type to configure the `http:Client` to invoke the Fitfit REST API. To keep things simple, an application was registered at the Security Token Service (STS) endpoint, and the refresh token that was retrieved from the STS is provided. The following are the details.

>Refresh Token: `24f19603-8565-4b5f-a036-88a945e1f272`  
>Client Secret: `PJz0UhTJMrHOo68QQNpvnqAY_3Aa`  
>Client ID: `FlfJYKBD2c925h4lkycqNZlC2l4a`  
>Token Endpoint: `https://localhost:9445/oauth2/token`

You must use HTTPS to connect to STS endpoint and the Fitfit REST API. The public certification for SSL/TLS can be found in `./resources/public.crt`.

**Note**: The above details have been included as `configurable` variables in the `config.bal` file in the shared template.

#### Test Environment

The Fitfit REST API is available under the below URL, and the following is a sample response. Please note that this is a mock backend created for this problem. Therefore, it always returns the same values regardless of the date range and the user ID.

The endpoint is automatically started and stopped everytime you do `bal test`.

```http
GET https://localhost:9091/activities/steps/user/1/from/2022-01-01/to/2022-03-31
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

#### Example

#### Input
- User ID: `1`  
- From Date: `2022-01-01`  
- To Date: `2022-03-31`  

#### Output
```json
{
   "eligible": true,
   "score": 29030,
   "from": "2022-01-01",
   "to": "2022-03-31",
   "details": {
      "type": "PLATINUM",
      "message": "Congratulations! You have won the PLATINUM gift!"
   }
}
```

### Part B

Insure Everyone has decided that it is not fair to treat the kids, the young, the old, etc all the same way. Therefore, they have decided to include the age factor into account. Your task is to write a new function by updating the previous function with the below condition. In order to get the age details, you need to connect to the Insure Everyone REST API. The definition of the function is given under the section `Definition`.

Following are the new conditions for each gift type.

```ballerina
int score = totalSteps/((100-age)/10);

Silver category: score >= SILVER_BAR && score < GOLD_BAR
Gold category: score >= GOLD_BAR && score < PLATINUM_BAR
Platinum category: score >= PLATINUM_BAR
```

#### Definition
Following is the definition of the function which can be found in `main.bal`.

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

function findTheGiftComplex(string userID, string 'from, string to) returns Gift|error
```

#### Security

Use basic authentication to connect to the Insure Everyone REST API. Following are the details.

- Username: `alice`  
- Password: `123`

You must use HTTPS to connect to the Insure Everyone REST API. The public certification for SSL/TLS can be found in `./resources/public.crt`.

#### Test Environment

The Insure Everyone REST API is available under the below URL, and the following is a sample response. Please note that this is a mock backend created for this problem. Therefore, it always returns the same values regardless of the user ID.

The endpoint is automatically started and stopped everytime you do `bal run` or `bal test`.

```http
GET https://localhost:9092/insurance/user/1
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

#### Example
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
- [Refer to HTTP Client security examples in Ballerina By Examples (BBE)](https://ballerina.io/learn/by-example/#rest-api-security)
- [OAuth2 API documentation](https://lib.ballerina.io/ballerina/oauth2/2.2.1)
