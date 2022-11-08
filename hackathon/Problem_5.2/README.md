# 5.2 GraphQL for Awake

## Problem statement

You are a microservices developer in the company Fitfit. As mentioned earlier, Fitfit is in the business of providing devices that monitor certain activities of an individual. These include metrics like steps taken, time spent on the elliptical machine, the jogging distance, etc. Fitfit has a REST API written to expose these data to their front-end. However, now that they have multiple different front-ends. They have decided to expose the same data via a GraphQL API.  

Your task is to write a GraphQL microservice which adheres to the schema under the `Definition` section. This microservice should connect to the Fitfit REST API and retrieve both steps and heart activity details. The step and activity responses must be aggregated into one GraphQL type using the `date` field. Then these details must be exposed via the GraphQL service using the query `activity`.

## Definition

Following is the GraphQL schema for the expected service. The mapping between the GraphQL fields and the back-end response fields is given as comments. JSON path is used to describe the mapping. If a date is missing in one of the HTTP responses, then activity detail for that particular date is not considered.

```gql
type ActivityDetails {
 date: String! # $.activity[*].date
 steps: Int! # $.activity[*].steps
 heart: Heart!
}
 
type Heart {
 min: Int! # $.activity[*].heart.min
 max: Int! # $.activity[*].heart.max
 caloriesOut: Float! # $.activity[*].heart.caloriesOut
 minutes: Int! # $.activity[*].heart.minutes
 name: String! # $.activity[*].heart.name
}
 
type Query {
 activity(ID: String!): [ActivityDetails!]!
}
```

## Test Environment

The Fitfit REST API is available under the below URL, and the following is a sample response. Please note that this is a mock backend created for this problem. Therefore, it always returns the same values regardless of the user ID.

The endpoints are automatically started and stopped everytime you do `bal test`.

### The Fitfit REST API for Steps activity

```http
GET http://localhost:9091/activities/v2/steps/user/1
```

```http
HTTP/1.1 200 OK
content-type: application/json
connection: close
server: ballerina
date: Wed, 23 Mar 2022 13:26:31 +0530
content-encoding: gzip
content-length: 128

{

  "activity": [

    {

      "date": "2022-03-20",
      "steps": 1698
    },
    {

      "date": "2022-03-15",
      "steps": 4103
    },
    {

      "date": "2022-03-10",
      "steps": 837
    },
    {

      "date": "2022-02-10",
      "steps": 7861
    },
    {

      "date": "2022-02-03",
      "steps": 8304
    },
    {

      "date": "2022-01-07",
      "steps": 3723
    },
    {

      "date": "2022-01-01",
      "steps": 2504
    }
  ]
}
```

#### The Fitfit REST API for Heart activity

```http
GET http://localhost:9091/activities/v2/heart/user/1
```
```http
HTTP/1.1 200 OK
content-type: application/json
connection: close
server: ballerina
date: Wed, 23 Mar 2022 13:27:36 +0530
content-encoding: gzip
content-length: 240

{

  "activity": [

    {

      "date": "2022-03-10",
      "heart": {

        "caloriesOut": 514.16208,
        "max": 110,
        "min": 86,
        "minutes": 185,
        "name": "Fat Burn"
      }
    },
    {

      "date": "2022-02-10",
      "heart": {

        "caloriesOut": 6.984,
        "max": 220,
        "min": 147,
        "minutes": 5,
        "name": "Peak"
      }
    },
    {

      "date": "2022-02-03",
      "heart": {

        "caloriesOut": 197.92656,
        "max": 147,
        "min": 121,
        "minutes": 18,
        "name": "Cardio"
      }
    },
    {

      "date": "2022-01-07",
      "heart": {

        "caloriesOut": 514.16208,
        "max": 121,
        "min": 86,
        "minutes": 185,
        "name": "Fat Burn"
      }
    },
    {

      "date": "2022-01-01",
      "heart": {

        "caloriesOut": 979.43616,
        "max": 86,
        "min": 30,
        "minutes": 626,
        "name": "Out of Range"
      }
    }
  ]
}
```

## Example

Following is the expected output for the below query.

### Input

```gql
{
  activity(ID:"1") {
    date
    steps
    heart {
      min
      max
    }
  }
}
```

### Output

```json
{
  "data": {
    "activity": [
      {
        "date": "2022-03-10",
        "steps": 837,
        "heart": {
          "min": 86,
          "max": 110
        }
      },
      {
        "date": "2022-02-10",
        "steps": 7861,
        "heart": {
          "min": 147,
          "max": 220
        }
      },
      {
        "date": "2022-02-03",
        "steps": 8304,
        "heart": {
          "min": 121,
          "max": 147
        }
      },
      {
        "date": "2022-01-07",
        "steps": 3723,
        "heart": {
          "min": 86,
          "max": 121
        }
      },
      {
        "date": "2022-01-01",
        "steps": 2504,
        "heart": {
          "min": 30,
          "max": 86
        }
      }
    ]
  }
}
```
## Hints
- [Query expressions in Ballerina By Examples (BBEs)](https://ballerina.io/learn/by-example/#query-expressions)
- [Returning records in GraphQL](https://ballerina.io/learn/by-example/graphql-returning-record-values.html)
- [GraphQL API documentation](https://lib.ballerina.io/ballerina/graphql/1.2.1)
- [HTTP Client](https://ballerina.io/learn/by-example/#rest-client)
