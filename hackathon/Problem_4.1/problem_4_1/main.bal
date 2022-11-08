import ballerina/http;
import ballerina/random;

configurable int port = 8080;
map<int> cakesAvailable = {"Butter Cake": 15, "Chocolate Cake": 20, "Tres Leches": 25};

public map<string> orderStatus = {};

public map<OrderItem[]> orderInfo = {};

enum Types {
    pending,
    in_progress,
    completed
}

type OrderDetails record {|
    string username;
    OrderItem[] order_items;
|};

type OrderUpdates record {|
    OrderItem[] order_items;
|};

public type OrderItem record {|
    string item;
    int quantity;
|};

type OrderResponse record {|
    string order_id;
    int total;
|};

// The `absolute resource path` represents the absolute path to the service. When bound to a listener
// endpoint, the service will be accessible at the specified path. If the path is omitted, then it defaults to `/`.
// A string literal also can represent the absolute path. E.g., `"/foo"`.
// The `type descriptor` represents the respective type of the service. E.g., `http:Service`.
service / on new http:Listener(port) {

    resource function get menu() returns json {
        json msg = cakesAvailable.toJson();
        return msg;
    }

    resource function get 'order/[string orderId]() returns http:NotFound|http:Ok {
        if orderStatus.hasKey(orderId) {
            http:Ok resp = {body:  {"order_id": orderId, "status": orderStatus.get(orderId)}};
            return resp;
        } else {
            http:NotFound resp = {body:  "not found"};
            return resp;
        }
    }

    resource function post 'order(@http:Payload OrderDetails ord) returns http:BadRequest|http:Created|error {
        if ord.username is "" || ord.order_items.length() == 0 {
            http:BadRequest resp = {body: "no username or empty order"};
            return resp;
        }

        map<string> uniqueNames = {};
        int totalCost = 0;
        foreach OrderItem cake in ord.order_items {
            if uniqueNames.hasKey(cake.item) {
                http:BadRequest resp = {body: "wrong order with repeated items"};
                return resp;
            } else {
                if (cakesAvailable.hasKey(cake.item)) {
                    if cake.quantity < 1 {
                        http:BadRequest resp = {body: "wrong order with invalid quantity"};
                        return resp;
                    } else {
                        uniqueNames[cake.item] = cake.item;
                        totalCost += cakesAvailable.get(cake.item) * cake.quantity;
                    }
                } else {
                    http:BadRequest resp = {body: "cake not on the menu"};
                    return resp;
                }
            }
        }

        // Order is correct. Create the order
        int orderId = check random:createIntInRange(1, 10000);

        // Update the order status map
        orderStatus[orderId.toString()] = pending;
        orderInfo[orderId.toString()] = ord.order_items;
        OrderResponse ordRes = {order_id: orderId.toString(), total: totalCost};
        http:Created resp = {body:  ordRes.toJson()};
        return resp;
    }

    resource function put 'order/[string orderId](@http:Payload OrderUpdates orderUpdates) returns http:NotFound|http:Forbidden|http:Ok|http:BadRequest|error {
        if !(orderInfo.hasKey(orderId)) {
            http:NotFound resp = {body:  "no order with the given ID"};
            return resp;
        }

        if !(orderStatus.get(orderId) is pending){
            http:Forbidden resp = {body:  "Order cannot be changed"};
            return resp;
        }

        if orderUpdates.order_items.length() == 0 {
            http:BadRequest resp = {body: "empty order"};
            return resp;
        }

        map<string> uniqueNames = {};
        int totalCost = 0;
        foreach OrderItem cake in orderUpdates.order_items {
            if uniqueNames.hasKey(cake.item) {
                http:BadRequest resp = {body: "wrong order with repeated items"};
                return resp;
            } else {
                if (cakesAvailable.hasKey(cake.item)) {
                    if cake.quantity < 1 {
                        http:BadRequest resp = {body: "wrong order with invalid quantity"};
                        return resp;
                    } else {
                        uniqueNames[cake.item] = cake.item;
                        totalCost += cakesAvailable.get(cake.item) * cake.quantity;
                    }
                } else {
                    http:BadRequest resp = {body: "cake not on the menu"};
                    return resp;
                }
            }
        }

        orderInfo[orderId.toString()] = orderUpdates.order_items;
        OrderResponse ordRes = {order_id: orderId.toString(), total: totalCost};
        http:Ok resp = {body:  ordRes.toJson()};
        return resp;

    }

    resource function delete 'order/[string orderId] () returns http:NotFound|http:Forbidden|http:Ok {
        if !(orderInfo.hasKey(orderId)) {
            http:NotFound resp = {body:  "no order with the given ID"};
            return resp;
        }

        if !(orderStatus.get(orderId) is pending){
            http:Forbidden resp = {body:  "Order cannot be deleted"};
            return resp;
        }

        _ = orderInfo.remove(orderId);
        _ = orderStatus.remove(orderId);
        http:Ok resp = {body:  "order with ID " +orderId+ " removed"};
        return resp;
    }
}
