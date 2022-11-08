import ballerina/lang.runtime;
import ballerina/test;
import ballerina/time;
import ballerina/websocket;

@test:Config {
    groups: ["evaluation"]
}
function testNotificationOnDriverArrival() returns error? {
    riderConnectionTime = time:utcNow();
    websocket:Client riderClient = check new (string `ws://localhost:9092/rider?name=Amy`, readTimeout = 5, writeTimeout = 5);
    check riderClient->writeTextMessage("Building-2");
    runtime:sleep(6);

    websocket:Client driverClient = check new (string `ws://localhost:9092/driver`, readTimeout = 5, writeTimeout = 5);
    driverArrivalTime = time:utcNow();
    check driverClient->writeTextMessage("Building-2:John");

    string message = check riderClient->readTextMessage();
    test:assertTrue(message == "John");

    error? closeRes = riderClient->close(timeout = 1);
    closeRes = driverClient->close(timeout = 1);
}

@test:Config {
    dependsOn: [testNotificationOnDriverArrival],
    groups: ["evaluation"]
}
function testUpdateOfTableWithNotificationOfDriverArrival() returns error? {
    runtime:sleep(10);
    time:Utc currentTime = time:utcNow();

    time:Utc riderRecordedTime;
    lock {
        test:assertTrue(dailyRiders.length() == 1);
        record {|RiderDetails value;|} riderContent = check dailyRiders.iterator().next().ensureType();
        RiderDetails riderDetails = riderContent.value;      
        riderRecordedTime = check time:utcFromString(riderDetails.time);
        test:assertTrue(<time:Utc> riderConnectionTime < riderRecordedTime);
        test:assertTrue(riderRecordedTime < currentTime);
        assertRiderNameAndBuilding(riderContent, "Amy", "Building-2");
    }

    lock {
        test:assertTrue(dailyDrivers.length() == 1);
        record {|DriverDetails value;|} driverContent = check dailyDrivers.iterator().next().ensureType();
        DriverDetails driverDetails = driverContent.value;
        time:Utc driverRecordedTime = check time:utcFromString(driverDetails.time);
        test:assertTrue(riderRecordedTime < driverRecordedTime);
        test:assertTrue(<time:Utc> driverArrivalTime < driverRecordedTime);
        test:assertTrue(driverRecordedTime < currentTime);
        assertDriverNameAndBuilding(driverContent, "John", "Building-2");
    }
}

@test:Config {
    dependsOn: [testUpdateOfTableWithNotificationOfDriverArrival],
    groups: ["evaluation"]
}
function testUpdateOfTableForMultipleDriverUpdates() returns error? {
    clearTables();

    websocket:Client driverClient = check new (string `ws://localhost:9092/driver`, readTimeout = 5, writeTimeout = 5);
    check driverClient->writeTextMessage("Building-2:John");
    runtime:sleep(3);
    check driverClient->writeTextMessage("Building-1:William");
    runtime:sleep(3);
    check driverClient->writeTextMessage("Building-1:May");
    runtime:sleep(3);
    check driverClient->writeTextMessage("Building-1:May");
    runtime:sleep(3);
    check driverClient->writeTextMessage("Building-1:William");
    runtime:sleep(3);
    check driverClient->writeTextMessage("Building-5:Ruth");
    runtime:sleep(10);

    lock {
        test:assertTrue(dailyDrivers.length() == 6);
        var iterator = dailyDrivers.iterator();
        assertDriverNameAndBuilding(check iterator.next().ensureType(), "John", "Building-2");
        assertDriverNameAndBuilding(check iterator.next().ensureType(), "William", "Building-1");
        assertDriverNameAndBuilding(check iterator.next().ensureType(), "May", "Building-1");
        assertDriverNameAndBuilding(check iterator.next().ensureType(), "May", "Building-1");
        assertDriverNameAndBuilding(check iterator.next().ensureType(), "William", "Building-1");
        assertDriverNameAndBuilding(check iterator.next().ensureType(), "Ruth", "Building-5");
    }

    error? closeRes = driverClient->close(timeout = 1);
}

@test:Config {
    dependsOn: [testUpdateOfTableForMultipleDriverUpdates],
    groups: ["evaluation"]
}
function testUpdateOfTableForMultipleRiderUpdates() returns error? {
    clearTables();

    websocket:Client riderClient1 = check new (string `ws://localhost:9092/rider?name=May`, readTimeout = 5, writeTimeout = 5);
    check riderClient1->writeTextMessage("Building-2");
    runtime:sleep(3);
    websocket:Client riderClient2 = check new (string `ws://localhost:9092/rider?name=Alice`, readTimeout = 5, writeTimeout = 5);
    check riderClient2->writeTextMessage("Building-1");
    runtime:sleep(3);
    check riderClient2->writeTextMessage("Building-1");
    runtime:sleep(3);
    websocket:Client riderClient3 = check new (string `ws://localhost:9092/rider?name=Faith`, readTimeout = 5, writeTimeout = 5);
    check riderClient3->writeTextMessage("Building-4");
    runtime:sleep(3);
    websocket:Client riderClient4 = check new (string `ws://localhost:9092/rider?name=Ron`, readTimeout = 5, writeTimeout = 5);
    check riderClient4->writeTextMessage("Building-4");
    runtime:sleep(10);

    lock {
        test:assertTrue(dailyRiders.length() == 4);
        var iterator = dailyRiders.iterator();
        assertRiderNameAndBuilding(check iterator.next().ensureType(), "May", "Building-2");
        assertRiderNameAndBuilding(check iterator.next().ensureType(), "Alice", "Building-1");
        assertRiderNameAndBuilding(check iterator.next().ensureType(), "Faith", "Building-4");
        assertRiderNameAndBuilding(check iterator.next().ensureType(), "Ron", "Building-4");
    }

    error? closeRes = riderClient1->close(timeout = 1);
    closeRes = riderClient2->close(timeout = 1);
    closeRes = riderClient3->close(timeout = 1);
}

@test:Config {
    dependsOn: [testUpdateOfTableForMultipleRiderUpdates],
    enable: false,
    groups: ["evaluation"]
}
function testNotReceivingNotificationsAfterClose() returns error? {
    clearTables();

    websocket:Client riderClient = check new (string `ws://localhost:9092/rider?name=Mary`, readTimeout = 5, writeTimeout = 5);
    check riderClient->writeTextMessage("Building-3");
    runtime:sleep(6);

    websocket:Client driverClient = check new (string `ws://localhost:9092/driver`, readTimeout = 5, writeTimeout = 5);
    check driverClient->writeTextMessage("Building-3:Oliver");

    string message = check riderClient->readTextMessage();
    test:assertTrue(message == "Oliver");

    error? closeRes = riderClient->close(timeout = 1);
    
    check driverClient->writeTextMessage("Building-3:Chloe");

    worker w1 returns string|error {
        return riderClient->readTextMessage();
    }

    worker w2 {
        runtime:sleep(5);
    }

    future<string|error> fut = w1;

    string|error? res = wait fut | w2;
    test:assertTrue(res == ());
    fut.cancel();

    closeRes = driverClient->close(timeout = 1);
}

@test:Config {
    dependsOn: [testUpdateOfTableForMultipleRiderUpdates],
    groups: ["evaluation"]
}
function testNotReceivingNotificationsAfterCloseViaTotalCallerCount() returns error? {
    clearTables();

    int originalLength = 0;

    lock {
        originalLength = getTotalNumberOfCallers(riderRequestedLocationMap); 
    }

    websocket:Client riderClient = check new (string `ws://localhost:9092/rider?name=Mary`, readTimeout = 5, writeTimeout = 5);
    check riderClient->writeTextMessage("Building-3");
    runtime:sleep(6);
    lock {
        test:assertTrue(getTotalNumberOfCallers(riderRequestedLocationMap) == originalLength + 1); 
    }

    websocket:Client driverClient = check new (string `ws://localhost:9092/driver`, readTimeout = 5, writeTimeout = 5);
    check driverClient->writeTextMessage("Building-3:Oliver");

    string message = check riderClient->readTextMessage();
    test:assertTrue(message == "Oliver");

    lock {
        test:assertTrue(getTotalNumberOfCallers(riderRequestedLocationMap) == originalLength + 1); 
    }

    error? closeRes = riderClient->close(timeout = 1);
    runtime:sleep(6);

    lock {
        // Length needs to be updated after close.
        test:assertTrue(getTotalNumberOfCallers(riderRequestedLocationMap) == originalLength); 
    }
    
    check driverClient->writeTextMessage("Building-3:Chloe");
    closeRes = driverClient->close(timeout = 1);
}

isolated function getTotalNumberOfCallers(map<websocket:Caller[]> callerArrayMap) returns int {
    int sum = 0;

    foreach websocket:Caller[] arr in callerArrayMap {
        sum += arr.length();
    }

    return sum;
}

isolated function assertRiderNameAndBuilding(record {|RiderDetails value;|} riderContent, string expectedName, string expectedBuildingId) {
    RiderDetails riderDetails = riderContent.value;
    test:assertTrue(riderDetails.rider == expectedName);
    test:assertTrue(riderDetails.buildingId == expectedBuildingId);
}

isolated function assertDriverNameAndBuilding(record {|DriverDetails value;|} driverContent, string expectedName, string expectedBuildingId) {
    DriverDetails driverDetails = driverContent.value;
    test:assertTrue(driverDetails.driver == expectedName);
    test:assertTrue(driverDetails.buildingId == expectedBuildingId);
}

function clearTables() {
    lock {
        dailyRiders.removeAll();
    }

    lock {
        dailyDrivers.removeAll();
    }
}
