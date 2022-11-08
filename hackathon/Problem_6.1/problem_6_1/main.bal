import ballerina/websocket;

enum Location {
    Q,
    R,
    S,
    T,
    U,
    V,
    W
}

map<int> route1 = {"Q": 1, "R": 2, "S": 3, "V": 4, "W": 5};
map<int> route2 = {"Q": 1, "T": 2, "U": 3, "V": 4, "W": 5};

function negotiatePickUp(string url, string name, Location location) returns [Location, Location]|error {
    if location is Q || location is W {
        return error("invalid pick-up location");
    }

    websocket:Client echoClient = check new (url + "?name=" + name);
    check echoClient->writeMessage(location);
    string response = check echoClient->readMessage();
    Location nextLocation = <Location>response;

    if route1.hasKey(nextLocation) {
        int nextStop = route1.get(nextLocation);
        // check my location
        if route1.hasKey(location) {
            int myLocation = route1.get(location);
            if nextStop > myLocation {
                check echoClient->close(timeout = 2);
                return error("Shuttle already passed.");
            } else {
                return [location, nextLocation];
            }
        } else {
            int myLocation = route2.get(location);
            if nextStop > myLocation {
                check echoClient->close(timeout = 2);
                return error("Shuttle already passed.");
            } else {
                check echoClient->writeMessage(V);
                string resp = check echoClient->readMessage();
                Location newNextLocation = <Location>resp;
                return [V, newNextLocation];
            }
        }
    }

    if route2.hasKey(nextLocation) {
        int nextStop = route2.get(nextLocation);
        // check my location
        if route2.hasKey(location) {
            int myLocation = route2.get(location);
            if nextStop > myLocation {
                check echoClient->close(timeout = 2);
                return error("Shuttle already passed.");
            } else {
                return [location, nextLocation];
            }
        } else {
            int myLocation = route1.get(location);
            if nextStop > myLocation {
                check echoClient->close(timeout = 2);
                return error("Shuttle already passed.");
            } else {
                check echoClient->writeMessage(V);
                string resp = check echoClient->readMessage();
                Location newNextLocation = <Location>resp;
                return [V, newNextLocation];
            }
        }
    }

    return error("Shuttle already passed.");

}
