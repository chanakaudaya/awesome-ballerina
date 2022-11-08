import ballerina/io;
import ballerina/http;
import ballerina/lang.value as value;


configurable string refreshToken = "24f19603-8565-4b5f-a036-88a945e1f272";
configurable string clientSecret = "PJz0UhTJMrHOo68QQNpvnqAY_3Aa";
configurable string clientId = "FlfJYKBD2c925h4lkycqNZlC2l4a";
configurable string tokenEndpoint = "https://localhost:9445/oauth2/token";

configurable string username = "alice";
configurable string password = "123";

public function main() returns error? {
    Gift gift = check findTheGiftSimple("1", "2022-01-01", "2022-03-31");
    io:println(gift.eligible);
}

function findTheGiftSimple(string userID, string 'from, string to) returns Gift|error {
    http:Client fifitEp = check new("https://localhost:9091/activities",
    auth = {
        refreshUrl: tokenEndpoint,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret,
        scopes: ["admin"],
        clientConfig: {
            secureSocket: {
                cert: "./resources/public.crt"
            }
        }
    },
    secureSocket = {
        cert: "./resources/public.crt"
    }
);
    json response = check fifitEp->get("/steps/user/"+userID+"/from/"+'from+"/to/"+to);
    //json copy = response.cloneReadOnly();
    Activities act = check response.cloneWithType(Activities);
   // io:println(act);

    var topNW = from var b in act.activities\-steps
                    select b.value;
   // io:println(topNW);
    int i = 0;
    int stepCount = 0;
    while i < topNW.length() {
        stepCount += topNW[i];
        i += 1;
    }
   // io:println(stepCount);

    if stepCount >= SILVER_BAR {
        Gift gift = {
            eligible: true,
            score: stepCount,
            'from: 'from,
            to: to       
            };
        if stepCount < GOLD_BAR {
            gift.details = {'type:SILVER, message: "Congratulations! You have won the SILVER gift!" };
        } else if stepCount >= GOLD_BAR && stepCount < PLATINUM_BAR {
            gift.details = {'type:GOLD, message: "Congratulations! You have won the GOLD gift!" };
        } else {
            gift.details = {'type:PLATINUM, message: "Congratulations! You have won the PLATINUM gift!" };
        }
      //  io:println(gift);
        return gift;

    }

    return error("Sorry, you have not won the award");
}

function findTheGiftComplex(string userID, string 'from, string to) returns Gift|error {

    http:Client fifitEp = check new("https://localhost:9091/activities",
    auth = {
        refreshUrl: tokenEndpoint,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret,
        scopes: ["admin"],
        clientConfig: {
            secureSocket: {
                cert: "./resources/public.crt"
            }
        }
    },
    secureSocket = {
        cert: "./resources/public.crt"
    }
);
    json response = check fifitEp->get("/steps/user/"+userID+"/from/"+'from+"/to/"+to);
    //json copy = response.cloneReadOnly();
    Activities act = check response.cloneWithType(Activities);
    io:println(act);

    var topNW = from var b in act.activities\-steps
                    select b.value;
    io:println(topNW);
    int i = 0;
    int stepCount = 0;
    while i < topNW.length() {
        stepCount += topNW[i];
        i += 1;
    }
    io:println(stepCount);
    io:println(stepCount);
    http:Client insureEveryoneEp = check new("https://localhost:9092/insurance",
        auth = {
            username: username,
            password: password
        },
        secureSocket = {
            cert: "./resources/public.crt"
        }
    );

    json insResponse = check insureEveryoneEp->get("/user/"+userID);
    io:println(insResponse);
    int age = check value:ensureType(insResponse.user.age, int);
    io:println(age);

    if age > 0 && age < 100 {
        int score = stepCount/((100-age)/10); 
        io:println(score);

        if score >= SILVER_BAR {
        Gift gift = {
            eligible: true,
            score: stepCount,
            'from: 'from,
            to: to       
            };
        if score < GOLD_BAR {
            gift.details = {'type:SILVER, message: "Congratulations! You have won the SILVER gift!" };
        } else if score >= GOLD_BAR && score < PLATINUM_BAR {
            gift.details = {'type:GOLD, message: "Congratulations! You have won the GOLD gift!" };
        } else {
            gift.details = {'type:PLATINUM, message: "Congratulations! You have won the PLATINUM gift!" };
        }
        io:println(gift);
        return gift;

    }
    }

    return error("Sorry, you have not won the award");


}

type Activities record {
    record {|
        string date;
        int value;
    |}[] activities\-steps;
};

type Gift record {
    boolean eligible;
    int score;
    # format yyyy-mm-dd
    string 'from;
    # format yyyy-mm-dd
    string to;
    record {|
        Types 'type;
        # message string: Congratulations! You have won the ${type} gift!;
        string message;
    |} details?;
};

enum Types {
    SILVER,
    GOLD,
    PLATINUM
}

const int SILVER_BAR = 5000;
const int GOLD_BAR = 10000;
const int PLATINUM_BAR = 20000;
