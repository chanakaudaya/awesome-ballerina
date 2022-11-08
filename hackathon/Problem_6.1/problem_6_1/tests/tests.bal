import ballerina/websocket;
import ballerina/test;
import problem_6_1.shuttle_service as shuttle;

@test:Config {
    groups: ["sample"]
}
function testPickUpNegotiationSuccess() returns error? {
    shuttle:nextShuttleLocation = "T";
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[] res = check negotiatePickUp("ws://localhost:9094/shuttle", "amy", "U");
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertEquals(newKeys.length() - 1, prevKeys.length());
    string name = newKeys.pop();
    test:assertEquals(name, "amy");
    test:assertEquals(res, ["U", "T"]);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertFalse(currentCaller is ());
    test:assertEquals(desiredPickUpLocations.length(), 1);
}

@test:Config {
    groups: ["sample"]
}
function testPickUpNegotiationFailure() {
    shuttle:nextShuttleLocation = "S";
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[]|error res = negotiatePickUp("ws://localhost:9094/shuttle", "jo", "R");
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertEquals(newKeys.length() - 1, prevKeys.length());
    string name = newKeys.pop();
    test:assertEquals(name, "jo");
    test:assertTrue(res is error);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertTrue(currentCaller is ());
    test:assertEquals(desiredPickUpLocations.length(), 1);
}

@test:Config {
    before: clearMap,
    groups: ["sample"]
}
function testPickUpNegotiationSuccessMovingToV() returns error? {
    string empName = "carl";
    Location nextLoc = "R";
    Location reqPickUpLoc = "T";
    shuttle:nextShuttleLocation = nextLoc;
    string[] prevKeys = shuttle:pickUpRequests.keys();
    Location[] res = check negotiatePickUp("ws://localhost:9094/shuttle", empName, reqPickUpLoc);
    string[] newKeys = shuttle:pickUpRequests.keys();
    test:assertEquals(newKeys.length() - 1, prevKeys.length());
    string name = newKeys.pop();
    test:assertEquals(name, empName);
    test:assertEquals(res, ["V", nextLoc]);
    [websocket:Caller?, string[]] [currentCaller, desiredPickUpLocations] = shuttle:pickUpRequests.get(name);
    test:assertFalse(currentCaller is ());
    test:assertEquals(desiredPickUpLocations.length(), 2);
    test:assertEquals(desiredPickUpLocations, [reqPickUpLoc, "V"]);
}

function clearMap() {
    shuttle:pickUpRequests.removeAll();
}
