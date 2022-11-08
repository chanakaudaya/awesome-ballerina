import ballerina/graphql;
import ballerina/http;

type ActivityDetails record {|
    string date;
    int steps;
    Heart heart;
|};

type Heart record {|
    int min;
    int max;
    float caloriesOut;
    int minutes;
    string name;
|};

type Steps record {
    record {|
        string date;
        int steps;
    |}[] activity;
};

type Hearts record {
    record{|
    string date;
    Heart heart;
    |} [] activity;
};




public distinct service class ActivitySummary {
    private final readonly & ActivityDetails entryRecord;

    function init(ActivityDetails entryRecord) {
        self.entryRecord = entryRecord.cloneReadOnly();
    }

    resource function get date() returns string {
        return self.entryRecord.date;
    }

    resource function get steps() returns int {
        return self.entryRecord.steps;
    }

    resource function get heart() returns Heart? {
        return self.entryRecord.heart;
    }

    resource function get min() returns int? {
        return self.entryRecord.heart.min;
    }

    resource function get max() returns int? {
        return self.entryRecord.heart.max;
    }

    resource function get minutes() returns int? {
        return self.entryRecord.heart.minutes;
    }

    resource function get name() returns string {
        return self.entryRecord.heart.name;
    }

    resource function get caloriesOut() returns float? {
        return self.entryRecord.heart.caloriesOut;
    }
}

// Don't change the port number
service /graphql on new graphql:Listener(9090) {

    // Write your answer here. You must change the input and
    // the output of the below signature along with the logic.
    resource function get activity(string ID) returns ActivitySummary[]|error {

        http:Client activitiesEp = check new ("http://localhost:9091/activities");
        json insResponse = check activitiesEp->get("/v2/steps/user/" + ID);
        Steps sts = check insResponse.cloneWithType(Steps);


        json hrtResponse = check activitiesEp->get("/v2/heart/user/" + ID);
        Hearts hrt = check hrtResponse.cloneWithType(Hearts);

        [string, int, Heart][] result = from var st in sts.activity
                       join var hr in hrt.activity
                       on st.date equals hr.date
                       select [st.date, st.steps, hr.heart];
        
        return result.'map(entry => new ActivitySummary(entryRecord = {date: entry[0], steps: entry[1], heart: entry[2]}));
    }
}

