import ballerina/http;
import ballerina/lang.value as value;

function findTheGift(string userID, string 'from, string to) returns Gift|error {

    worker stepWorker returns int|error {
        http:Client fifitEp = check new ("http://localhost:9091/activities",
            {
                retryConfig: {
                    interval: 3,
                    count: 3,
                    backOffFactor: 1.0,
                    maxWaitInterval: 20,
                    statusCodes: [500]
                },
                timeout: 10
            }
        );
        json response = check fifitEp->get("/steps/user/" + userID + "/from/" + 'from + "/to/" + to);
        //json copy = response.cloneReadOnly();
        Activities act = check response.cloneWithType(Activities);

        var topNW = from var b in act.activities\-steps
            select b.value;
        int i = 0;
        int stepCount = 0;
        while i < topNW.length() {
            stepCount += topNW[i];
            i += 1;
        }
        return stepCount;
    }

    worker insureWorker returns int|error {
        http:FailoverClient insureEveryoneEp = check new ({
            timeout: 10,
            failoverCodes: [500],
            interval: 3,
            targets: [
                {url: "http://localhost:9092/insurance1"},
                {url: "http://localhost:9092/insurance2"}
            ]
        });
        json insResponse = check insureEveryoneEp->get("/user/" + userID);
        int age = check value:ensureType(insResponse.user.age, int);
        return age;
    }

    int stepCount = check wait stepWorker;
    int age = check wait insureWorker;

    if age > 0 && age < 100 {
        int score = stepCount / ((100 - age) / 10);

        if score >= SILVER_BAR {
            Gift gift = {
                eligible: true,
                score: score,
                'from: 'from,
                to: to
            };
            if score < GOLD_BAR {
                gift.details = {'type: SILVER, message: "Congratulations! You have won the SILVER gift!"};
            } else if score >= GOLD_BAR && score < PLATINUM_BAR {
                gift.details = {'type: GOLD, message: "Congratulations! You have won the GOLD gift!"};
            } else {
                gift.details = {'type: PLATINUM, message: "Congratulations! You have won the PLATINUM gift!"};
            }
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

type UserResult record {
    record {
        int age;
    } user;
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
        # message string: Congradulations! You have won the ${type} gift!;
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
