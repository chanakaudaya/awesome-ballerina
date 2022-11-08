
import ballerina/io;
import ballerina/websocket;

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

enum Building {
    b1 = "Building-1",
    b2 = "Building-2",
    b3 = "Building-3",
    b4 = "Building-4",
    b5 = "Building-5"
}

table<DriverDetails> dailyDrivers = table [];

listener websocket:Listener ln = new (9092);


service /rider on ln {
   resource function get .(string rider) returns websocket:Service|websocket:Error {
       // Accept the WebSocket upgrade by returning a `websocket:Service`.
       return new RiderService();
   }
}

service class RiderService {
    *websocket:Service;
    remote function onOpen(websocket:Caller caller) returns error? {
        io:println("Opened a WebSocket connection");
    }
    remote function onMessage(websocket:Caller caller, string buildingId) returns websocket:Error? {
        return caller->writeMessage("You said: " + buildingId);
    }
    remote function onClose(websocket:Caller caller, int statusCode, string reason) {
        io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
    }
}

service /driver on ln {
   resource function get .() returns websocket:Service|websocket:Error {
       // Accept the WebSocket upgrade by returning a `websocket:Service`.
       return new DriverService();
   }
}

service class DriverService {
    *websocket:Service;
    remote function onMessage(websocket:Caller caller, string driverLocation) returns websocket:Error? {
        return caller->writeMessage("You said: " + driverLocation);
    }
}

