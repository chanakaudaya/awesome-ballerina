import ballerina/graphql;
import ballerina/http;

type Sleeps record {
    record {|
        string date;
        int duration;
        Levels levels;
    |}[] sleep;
};

type Levels record {
    record {|
        Category deep;
        Category light;
        Category wake;
    |} summary;
};

type Category record {|
        int minutes;
        int thirtyDayAvgMinutes;
|};


type SleepSummaryEntry record {|
    string date;
    int duration;
    LevelResponse levels;
|};

type LevelResponse record {|
    int deep;
    int wake;
    int light;
|};


enum TimeUnit {
    SECONDS,
    MINUTES    
}

public distinct service class SleepSummary {
    private final readonly & SleepSummaryEntry entryRecord;

    function init(SleepSummaryEntry entryRecord) {
        self.entryRecord = entryRecord.cloneReadOnly();
    }

    resource function get date() returns string {
        return self.entryRecord.date;
    }

    resource function get duration() returns int {
        return self.entryRecord.duration;
    }

    resource function get levels() returns LevelResponse? {
        return self.entryRecord.levels;
    }

    resource function get deep() returns int? {
        return self.entryRecord.levels.deep;
    }

    resource function get wake() returns int? {
        return self.entryRecord.levels.wake;
    }

    resource function get light() returns int? {
        return self.entryRecord.levels.light;
    }
}

// Don't change the port number
service /graphql on new graphql:Listener(9090) {

    // Write your answer here. You must change the input and
    // the output of the below signature along with the logic.
    resource function get sleepSummary(string ID, TimeUnit timeunit) returns SleepSummary[]|error {

        http:Client activitiesEp = check new("http://localhost:9091/activities");
        json insResponse = check activitiesEp->get("/summary/sleep/user/"+ID);
        Sleeps sl = check insResponse.cloneWithType(Sleeps);

        SleepSummaryEntry[] sse = [];
        int i = 0;
        while i < sl.sleep.length() {
            if (timeunit is SECONDS) {
                LevelResponse lr = {deep: sl.sleep[i].levels.summary.deep.minutes * 60, wake: sl.sleep[i].levels.summary.wake.minutes * 60, light: sl.sleep[i].levels.summary.light.minutes * 60};
                SleepSummaryEntry ss = {date: sl.sleep[i].date, duration: sl.sleep[i].duration * 60, levels:lr};
                sse.push(ss);
            } else {
                LevelResponse lr = {deep: sl.sleep[i].levels.summary.deep.minutes, wake: sl.sleep[i].levels.summary.wake.minutes, light: sl.sleep[i].levels.summary.light.minutes};
                SleepSummaryEntry ss = {date: sl.sleep[i].date, duration: sl.sleep[i].duration, levels:lr};
                sse.push(ss);
            }
            i += 1;
        }      
        return sse.'map(entry => new SleepSummary(entry));
    }
}

