# 6.2 WebSocket Rider

## Problem Statement

The Go Figure company has `5` main buildings in their large office premises. Different departments of the company are operated in separate buildings. Sometimes employees in one building need to visit other buildings to get something done from another department. Since they are located far from each other, a buggy service is available to transport employees from one building to another.

The company wants to introduce an application to allow employees to get the details of the buggy driver available at a specific building. So your task is to write WebSocket services for riders and drivers. The rider service should allow riders to register to be picked up from the building they are in (pick up location). The driver service should allow drivers to send updates mentioning the current building they are at when they reach a building. The driver service should also send details about the available driver to subscribed riders when a driver reaches a building.

Riders can request to be picked up only from the building they are currently at. So there won't be requests to be picked up from multiple buildings for a single rider at any given time.

Each rider will establish a new connection to request being picked up. Once a rider leaves a building the connection will be closed. Until the connection is closed, riders need to be notified of drivers arriving at the relevant building. Attempts should not be made to notify riders that have already left.

Moreover, the company also wants to maintain records of the usage of the buggy service each day. You are required to populate two in-memory tables `dailyRiders` and `dailyDrivers` with the following information.

1. Daily Riders (`dailyRiders`)

    - `time` - Time at which the **connection was established** to request being picked up. A string value in the `2022-03-31T09:43:23.000534Z` format.
    - `rider` - Name of the rider (string).
    - `buildingId` - The building ID (one of `"Building-1"`, `"Building-2"`, `"Building-3"`, `"Building-4"`, or `"Building-5"`) of the building from which the rider requested to be picked up.

2. Daily Drivers (`dailyDrivers`)

    - `time` - Time at which the driver informed of arrival at a particular building. A string value in the `2022-03-31T09:43:23.000534Z` format.
    - `driver` - Name of the driver (string).
    - `buildingId` - The building ID (one of `"Building-1"`, `"Building-2"`, `"Building-3"`, `"Building-4"`, or `"Building-5"`) of the building at which the driver arrived.

There should be two services as follows. Both services should listen on port `9092`.

1. Rider Service  (connection established on `/rider`) with the following methods.

    - The `onOpen` remote method to record when the connection is established.
    - The `onMessage` remote method with the `websocket:Caller` parameter for the caller and a `string` parameter `buildingId`. `buildingId` represents the pick up location of the rider. Store the rider subscriptions with the pick up locations in a map. 
        - key - building ID string
        - value - array of `websocket:Caller`
    - The `onClose` remote method with the `websocket:Caller` parameter to remove the rider from riders to be notified of drivers arriving at the building.

2. Driver Service  (`/driver`)
    - Should have the `onMessage` remote method with a single `string` parameter `driverLocation`. `driverLocation` is the current location of the driver. It is in the format of `buildingId:driverName`. Look up from the rider subscription map the active riders subscribed for this `buildingId` and send them the name of the driver (`driverName`). 

## Constraints

- Services should listen on port `9092`
- The rider service should use the path `/rider`
- The driver service should use the path `/driver`
- Assume the premises has `5` buildings named as `"Building-1"`, `"Building-2"`, `"Building-3"`, `"Building-4"`, and `"Building-5"`
- The name of each rider should be accepted as a query parameter in the request to `ws://localhost:9092/rider` (e.g., `ws://localhost:9092/rider?name=Amy`). This name can be used when creating the WebSocket service to subsequently record details in the in-memory table.
- Ignore new rider requests on the same connection for the same building. The in-memory table should not be updated for ignored requests.

## Definition

- Module-level map for rider subscriptions

    `map<websocket:Caller[]> riderRequestedLocationMap = {};`

- Parameters of the `onMessage` remote method of the rider service

    `(websocket:Caller caller, string buildingId)`

- Parameter of the `onMessage` remote method of the driver service

    `(string driverLocation)`

- The tables and member record types are defined as follows in the `main.bal` file already

    ```
    type RiderDetails record {|
        string time;
        string rider;
        string buildingId;
    |};

    table<RiderDetails> dailyRiders = table [];

    type DriverDetails record {|
        string time;
        string driver;
        string buildingId;
    |};

    table<DriverDetails> dailyDrivers = table [];
    ```

## Example 1

Riders

- Connection URL - `ws://localhost:9092/rider?name=Amy`
- Message sent to the server - `"Building-2"`
- Message received from the server - `"John"`

## Example 2

Drivers

- Connection URL - `ws://localhost:9092/driver`
- Message sent to the server - `"Building-2:John"`

## Hints

- [Simple WebSocket service](https://ballerina.io/learn/by-example/websocket-basic-sample)
- Separate WebSocket services need to be used for the riders and the drivers.
- [Attaching multiple services to the same listener](https://stackoverflow.com/collectives/wso2/articles/73277198/attaching-multiple-services-to-the-same-listener)
- Query parameters can be used [similar to HTTP](https://ballerina.io/learn/by-example/http-query-parameter).
- The [`ballerina/time` module](https://lib.ballerina.io/ballerina/time/2.2.1) can be used to get the current time.
- [UTC time](https://ballerina.io/learn/by-example/time-utc)
- [Time formatting and parsing](https://ballerina.io/learn/by-example/time-formatting-and-parsing)
- [Adding members to a table](https://lib.ballerina.io/ballerina/lang.table/0.0.0/functions#add)
