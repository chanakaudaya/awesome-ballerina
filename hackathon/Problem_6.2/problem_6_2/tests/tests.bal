import ballerina/lang.runtime;
import ballerina/test;
import ballerina/time;
import ballerina/websocket;

time:Utc? riderConnectionTime = ();
time:Utc? driverArrivalTime = ();

@test:Config {
    groups: ["sample"]
}
function testNotificationOnDriverArrivalSample() returns error? {
    riderConnectionTime = time:utcNow();
    websocket:Client riderClient = check new (string `ws://localhost:9092/rider?name=Amy`, readTimeout = 5, writeTimeout = 5);
    check riderClient->writeTextMessage("Building-2");
    runtime:sleep(3);

    websocket:Client driverClient = check new (string `ws://localhost:9092/driver`, readTimeout = 5, writeTimeout = 5);
    driverArrivalTime = time:utcNow();
    check driverClient->writeTextMessage("Building-2:John");

    string message = check riderClient->readTextMessage();
    test:assertEquals(message, "John");
}

@test:Config {
    dependsOn: [testNotificationOnDriverArrivalSample],
    groups: ["sample"]
}
function testUpdateOfTable() returns error? {
    runtime:sleep(3);
    time:Utc currentTime = time:utcNow();

    time:Utc riderRecordedTime;
    lock {
        test:assertEquals(dailyRiders.length(), 1);
        record {|RiderDetails value;|} riderContent = check dailyRiders.iterator().next().ensureType();
        RiderDetails riderDetails = riderContent.value;
        riderRecordedTime = check time:utcFromString(riderDetails.time);
        test:assertTrue(<time:Utc> riderConnectionTime < riderRecordedTime);
        test:assertTrue(riderRecordedTime < currentTime);
        test:assertEquals(riderDetails.rider, "Amy");
        test:assertEquals(riderDetails.buildingId, "Building-2");
    }

    lock {
        test:assertEquals(dailyDrivers.length(), 1);
        record {|DriverDetails value;|} driverContent = check dailyDrivers.iterator().next().ensureType();
        DriverDetails driverDetails = driverContent.value;
        time:Utc driverRecordedTime = check time:utcFromString(driverDetails.time);
        test:assertTrue(riderRecordedTime < driverRecordedTime);
        test:assertTrue(<time:Utc> driverArrivalTime < driverRecordedTime);
        test:assertTrue(driverRecordedTime < currentTime);
        test:assertEquals(driverDetails.driver, "John");
        test:assertEquals(driverDetails.buildingId, "Building-2");
    }
}
