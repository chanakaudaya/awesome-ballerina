# 5.1 GraphQL for Sleep

## Problem statement

You are a microservices developer in the company Fitfit. As mentioned in a previous problem, Fitfit is in the business of providing devices that monitor certain activities of an individual. These include metrics like steps taken, time spent on the elliptical machine, the jogging distance, etc. Fitfit has a REST API written to expose these data to their front-end. However, now that they have multiple different front-ends. They have decided to expose the same data via a GraphQL API.  

Your task is to write a GraphQL microservice which adheres to the schema under the `Definition` section. The microservice should connect to the Fitfit REST API and retrieve sleep summary details. Then these details must be exposed via the GraphQL service using the query `sleepSummary`.

## Definition

Following is the GraphQL schema for the expected service. The mapping between the GraphQL fields and the Fitfit REST API response fields is given as comments. JSON path is used to describe the mapping. All the Fitfit REST API response fields use minutes as the timeunit.

```graphql
type Query {
  sleepSummary(ID: String!, timeunit: TimeUnit!): [SleepSummary!]!
}

enum TimeUnit {
  SECONDS
  MINUTES
}

type SleepSummary {
  date: String! # $.sleep[*].date
  duration: Int! # $.sleep[*].duration
  levels: Levels!
}

type Levels {
  deep: Int! # $.sleep[*].levels.summary.deep.minutes
  wake: Int! # $.sleep[*].levels.summary.wake.minutes
  light: Int! # $.sleep[*].levels.summary.light.minutes
}
```

## Test Environment

The Fitfit REST API is available under the below URL, and the following is a sample response. Please note that this is a mock backend created for this problem. Therefore, it always returns the same values regardless of the user ID.

The endpoint is automatically started and stopped everytime you do `bal test`.

```http
GET http://localhost:9091/activities/summary/sleep/user/1
```
```http
HTTP/1.1 200 OK
content-type: application/json
connection: close
server: ballerina
date: Thu, 31 Mar 2022 16:44:33 +0530
content-encoding: gzip
content-length: 256

{
  "sleep": [
    {
      "date": "2022-03-20",
      "duration": 28800,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 19000,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 9000,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 800,
            "thirtyDayAvgMinutes": 700
          }
        }
      }
    },
    {
      "date": "2022-03-15",
      "duration": 28080,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 20900,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 8080,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 180,
            "thirtyDayAvgMinutes": 700
          }
        }
      }
    },
    {
      "date": "2022-03-10",
      "duration": 28080,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 20000,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 8080,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 80,
            "thirtyDayAvgMinutes": 700
          }
        }
      }
    },
    {
      "date": "2022-02-10",
      "duration": 23400,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 20000,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 3000,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 400,
            "thirtyDayAvgMinutes": 700
          }
        }
      }
    },
    {
      "date": "2022-02-03",
      "duration": 27000,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 20000,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 7000,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 0,
            "thirtyDayAvgMinutes": 700
          }
        }
      }
    },
    {
      "date": "2022-01-07",
      "duration": 25200,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 20000,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 5000,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 200,
            "thirtyDayAvgMinutes": 700
          }
        }
      }
    },
    {
      "date": "2022-01-01",
      "duration": 28800,
      "levels": {
        "summary": {
          "deep": {
            "minutes": 20000,
            "thirtyDayAvgMinutes": 23000
          },
          "light": {
            "minutes": 8000,
            "thirtyDayAvgMinutes": 7500
          },
          "wake": {
            "minutes": 800,
            "thirtyDayAvgMinutes": 700
          }
        }
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
 sleepSummary(ID: "1", timeunit:SECONDS) {
   date
   duration
   levels {
     deep
     wake
   }
 }
}
```

### Output

```json
{

  "data": {

    "sleepSummary": [

      {

        "date": "2022-03-20",
        "duration": 1728000,
        "levels": {

          "deep": 1140000,
          "wake": 48000
        }
      },
      {

        "date": "2022-03-15",
        "duration": 1684800,
        "levels": {

          "deep": 1254000,
          "wake": 10800
        }
      },
      {

        "date": "2022-03-10",
        "duration": 1684800,
        "levels": {

          "deep": 1200000,
          "wake": 4800
        }
      },
      {

        "date": "2022-02-10",
        "duration": 1404000,
        "levels": {

          "deep": 1200000,
          "wake": 24000
        }
      },
      {

        "date": "2022-02-03",
        "duration": 1620000,
        "levels": {

          "deep": 1200000,
          "wake": 0
        }
      },
      {

        "date": "2022-01-07",
        "duration": 1512000,
        "levels": {

          "deep": 1200000,
          "wake": 12000
        }
      },
      {

        "date": "2022-01-01",
        "duration": 1728000,
        "levels": {

          "deep": 1200000,
          "wake": 48000
        }
      }
    ]
  }
}
```
## Hints
- [Returning service objects in GraphQL](https://ballerina.io/learn/by-example/graphql-returning-service-objects.html)
- [GraphQL API documentation](https://lib.ballerina.io/ballerina/graphql/1.2.1)
- [HTTP Client](https://ballerina.io/learn/by-example/#rest-client)
