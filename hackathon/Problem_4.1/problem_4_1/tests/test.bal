import ballerina/http;
import ballerina/test;

@test:Config {
    groups: ["sample"]
}
function testMenu1() returns error? {
    json menu = check cl->get("/menu");
    test:assertEquals(menu, {"Butter Cake": 15, "Chocolate Cake": 20, "Tres Leches": 25});
}

string? orderId1 = ();

@test:Config {
    groups: ["sample"]
}
function testOrderPlacementSuccess1() returns error? {
    record {|
        string order_id;
        int total;
    |} res = check cl->post("/order", {
        "username": "mary",
        "order_items": [
            {"item": "Tres Leches", "quantity": 1},
            {"item": "Chocolate Cake", "quantity": 2}
        ]
    });
    orderId1 = res.order_id;
    test:assertEquals(res.total, 65);
}

@test:Config {
    groups: ["sample"]
}
function testOrderPlacementFailureForInvalidJsonPayloadStructure1() returns error? {
    http:Response res = check cl->post("/order", {
        "username": "mary",
        "order_items": [
            {"Tres Leches": 1},
            {"Chocolate Cake": 2}
        ]
    });
    test:assertEquals(res.statusCode, http:STATUS_BAD_REQUEST);
}
@test:Config {
    dependsOn: [testOrderPlacementSuccess1],
    groups: ["sample"]
}
function testRetrievingOrderStatusWithAValidOrderId1() returns error? {
    string orderIdString = check orderId1.ensureType();

    // https://github.com/ballerina-platform/ballerina-orderId-library/issues/2813
    // record {|
    //     string order_id;
    //     string status;
    // |} orderStatusJson = check cl->get(string `/order/${orderIdString}`);

    json orderStatusJson = check cl->get(string `/order/${orderIdString}`);
    test:assertEquals(orderStatusJson.order_id, orderIdString);
    test:assertEquals(orderStatusJson.status, "pending");
}

@test:Config {
    groups: ["sample"]
}
function testRetrievingOrderStatusWithAnInvalidOrderId1() returns error? {
    http:Response res = check cl->get("/order/invalid");
    test:assertEquals(res.statusCode, http:STATUS_NOT_FOUND);
}

@test:Config {
    groups: ["sample"]
}
function testRetrievingOrderStatusForOrderIdWithUpdatedStatus1() returns error? {
    record {|
        string order_id;
        int total;
    |} res = check cl->post("/order", {
        "username": "jo",
        "order_items": [
            {"item": "Tres Leches", "quantity": 2},
            {"item": "Chocolate Cake", "quantity": 1},
            {"item": "Butter Cake", "quantity": 1}
        ]
    });

    string orderIdString = res.order_id;

    json orderStatusJson = check cl->get(string `/order/${orderIdString}`);
    test:assertEquals(orderStatusJson.order_id, orderIdString);
    test:assertEquals(orderStatusJson.status, "pending");

    lock {
        orderStatus[orderIdString] = "in progress";
    }

    orderStatusJson = check cl->get(string `/order/${orderIdString}`);
    test:assertEquals(orderStatusJson.order_id, orderIdString);
    test:assertEquals(orderStatusJson.status, "in progress");

    lock {
        orderStatus[orderIdString] = "completed";
    }

    orderStatusJson = check cl->get(string `/order/${orderIdString}`);
    test:assertEquals(orderStatusJson.order_id, orderIdString);
    test:assertEquals(orderStatusJson.status, "completed");
}

@test:Config {
    dependsOn: [testOrderPlacementSuccess1],
    groups: ["sample"]
}
function testUpdatingAnOrderSuccessfully1() returns error? {
    string orderIdString = check orderId1.ensureType();

    record {|
        string order_id;
        int total;
    |} res = check cl->put(string `/order/${orderIdString}`, {
        "order_items": [
            {"item": "Tres Leches", "quantity": 2},
            {"item": "Chocolate Cake", "quantity": 1},
            {"item": "Butter Cake", "quantity": 1}
        ]
    });

    test:assertEquals(res.order_id, orderIdString);
    test:assertEquals(res.total, 85);

    json orderStatusJson = check cl->get(string `/order/${orderIdString}`);
    test:assertEquals(orderStatusJson.order_id, orderIdString);
    test:assertEquals(orderStatusJson.status, "pending");
}

@test:Config {
    groups: ["sample"]
}
function testDeletingAnOrderSuccessfully1() returns error? {
    record {|
        string order_id;
        int total;
    |} res = check cl->post("/order", {
        "username": "amani",
        "order_items": [
            {"item": "Butter Cake", "quantity": 2}
        ]
    });

    http:Response deleteRes = check cl->delete(string `/order/${res.order_id}`);
    test:assertEquals(deleteRes.statusCode, http:STATUS_OK);
}
