import ballerina/websocket;

public string nextShuttleLocation = "T";

public map<[websocket:Caller?, string[]]> pickUpRequests = {};

service /shuttle on new websocket:Listener(9094) {
    resource function get . (string name) returns websocket:Service|websocket:UpgradeError {
        return <ShuttleService|websocket:UpgradeError> trap new ShuttleService(name);
    }
}

public boolean updateToWAfterChanging = false;

service class ShuttleService {
    *websocket:Service;
    private final string name;

    public function init(string name) {
        if pickUpRequests.hasKey(name) {
            panic error websocket:UpgradeError(string `User ${name} is already registered`);
        }

        self.name = name;
    }

    remote function onOpen(websocket:Caller caller) {
        pickUpRequests[self.name] = [caller, []];
    }

    remote function onMessage(websocket:Caller caller, string location) returns error? {
        pickUpRequests.get(self.name)[1].push(location);
        string currentNextShuttleLocation = <string>nextShuttleLocation;
        lock {
            if updateToWAfterChanging {
                nextShuttleLocation = "W";
            }
        }
        check caller->writeTextMessage(currentNextShuttleLocation);
    }

    remote function onClose(websocket:Caller caller) returns error? {
        [websocket:Caller?, string[]] entry = pickUpRequests.get(self.name);
        entry[0] = ();
        check caller->close(timeout = 2);
    }
}

