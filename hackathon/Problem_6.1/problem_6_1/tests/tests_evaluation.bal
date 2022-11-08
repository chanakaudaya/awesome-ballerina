import ballerina/test;
import ballerina/websocket;
import problem_6_1.shuttle_service as shuttle;

@test:Config {
    groups: ["evaluation"]
}
function testPickUpNegotiationSuccessEval() returns error? {
    shuttle:nextShuttleLocation = "T";
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[] res = check negotiatePickUp("ws://localhost:9094/shuttle", "amy", "U");
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertTrue(newKeys.length() - 1 == prevKeys.length());
    string name = newKeys.pop();
    test:assertTrue(name == "amy");
    test:assertTrue(res == ["U", "T"]);

    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertFalse(currentCaller is ());
    test:assertTrue(desiredPickUpLocations.length() == 1);
    test:assertTrue(desiredPickUpLocations == ["U"]);
}

@test:Config {
    groups: ["evaluation"]
}
function testPickUpNegotiationFailureEval() {
    shuttle:nextShuttleLocation = "S";
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[]|error res = negotiatePickUp("ws://localhost:9094/shuttle", "jo", "R");
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertTrue(newKeys.length() - 1 == prevKeys.length());
    string name = newKeys.pop();
    test:assertTrue(name == "jo");
    test:assertTrue(res is error);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertTrue(currentCaller is ()); // connection has to be closed
    test:assertTrue(desiredPickUpLocations.length() == 1);
    test:assertTrue(desiredPickUpLocations == ["R"]);
}

@test:Config {
    groups: ["evaluation"]
}
function testPickUpNegotiationFailureWhenNextLocationIsDestinationEval() {
    shuttle:nextShuttleLocation = "W";
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[]|error res = negotiatePickUp("ws://localhost:9094/shuttle", "joy", "V");
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertTrue(newKeys.length() - 1 == prevKeys.length());
    string name = newKeys.pop();
    test:assertTrue(name == "joy");
    test:assertTrue(res is error);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertTrue(currentCaller is ()); // connection has to be closed
    test:assertTrue(desiredPickUpLocations.length() == 1);
    test:assertTrue(desiredPickUpLocations == ["V"]);
}

function pickUpNegotiationMovingToVData() returns string[][3] =>
    [
        ["anil", "R", "T"],
        ["sunil", "R", "U"],
        ["nimal", "S", "T"],
        ["ahas", "S", "U"],
        ["sachini", "T", "R"],
        ["ruvini", "T", "S"],
        ["shani", "U", "R"],
        ["kelum", "U", "S"]
    ];

@test:Config {
    dataProvider: pickUpNegotiationMovingToVData,
    before: clearMap,
    groups: ["evaluation"]
}
function testPickUpNegotiationSuccessMovingToVEval(string empName, string nextLoc, string reqPickUpLoc) returns error? {
    shuttle:nextShuttleLocation = nextLoc;
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[] res = check negotiatePickUp("ws://localhost:9094/shuttle", empName, <Location> reqPickUpLoc);
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertTrue(newKeys.length() - 1 == prevKeys.length());
    string name = newKeys.pop();
    test:assertTrue(name == empName);
    test:assertTrue(res == ["V", nextLoc]);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertFalse(currentCaller is ());
    test:assertTrue(desiredPickUpLocations.length() == 2);
    test:assertTrue(desiredPickUpLocations == [reqPickUpLoc, "V"]);
}

@test:Config {
    dataProvider: pickUpNegotiationMovingToVData,
    before: clearMap,
    groups: ["evaluation"]
}
function testPickUpNegotiationFailureWhenNextLocationIsDestinationAfterUpdatingToV(string empName, string nextLoc, string reqPickUpLoc) {
    shuttle:nextShuttleLocation = nextLoc;
    lock {
        shuttle:updateToWAfterChanging = true;
    }
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[]|error res = negotiatePickUp("ws://localhost:9094/shuttle", empName, <Location> reqPickUpLoc);

    lock {
        shuttle:updateToWAfterChanging = false;
    }
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertTrue(newKeys.length() - 1 == prevKeys.length());
    string name = newKeys.pop();

    test:assertTrue(name == empName);
    test:assertTrue(res is error);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertTrue(currentCaller is ()); // connection has to be closed
    test:assertTrue(desiredPickUpLocations.length() == 2);
    test:assertTrue(desiredPickUpLocations == [reqPickUpLoc, "V"]);
}
