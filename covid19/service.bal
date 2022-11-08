import ballerina/graphql;

public type CovidEntry record {|
    readonly string isoCode;
    string country;
    decimal cases?;
    decimal deaths?;
    decimal recovered?;
    decimal active?;
|};

table<CovidEntry> key(isoCode) covidEntriesTable = table [
    {isoCode: "AFG", country: "Afghanistan", cases: 159303, deaths: 7386, recovered: 146084, active: 5833},
    {isoCode: "SL", country: "Sri Lanka", cases: 598536, deaths: 15243, recovered: 568637, active: 14656},
    {isoCode: "US", country: "USA", cases: 69808350, deaths: 880976, recovered: 43892277, active: 25035097}
];

public distinct service class CovidData {
    private final readonly & CovidEntry entryRecord;

    function init(CovidEntry entryRecord) {
        self.entryRecord = entryRecord.cloneReadOnly();
    }

    resource function get isoCode() returns string {
        return self.entryRecord.isoCode;
    }

    resource function get country() returns string {
        return self.entryRecord.country;
    }

    resource function get cases() returns decimal? {
        if self.entryRecord.cases is decimal {
            return self.entryRecord.cases / 1000;
        }
        return;
    }

    resource function get deaths() returns decimal? {
        if self.entryRecord.deaths is decimal {
            return self.entryRecord.deaths / 1000;
        }
        return;
    }

    resource function get recovered() returns decimal? {
        if self.entryRecord.recovered is decimal {
            return self.entryRecord.recovered / 1000;
        }
        return;
    }

    resource function get active() returns decimal? {
        if self.entryRecord.active is decimal {
            return self.entryRecord.active / 1000;
        }
        return;
    }
}


service /covid19 on new graphql:Listener(9000) {
    resource function get all() returns CovidData[] {
        CovidEntry[] covidEntries = covidEntriesTable.toArray().cloneReadOnly();
        return covidEntries.map(entry => new CovidData(entry));
    }

    resource function get filter(string isoCode) returns CovidData? {
        CovidEntry? covidEntry = covidEntriesTable[isoCode];
        if covidEntry is CovidEntry {
            return new (covidEntry);
        }
        return;
    }

    remote function add(CovidEntry entry) returns CovidData {
        covidEntriesTable.add(entry);
        return new CovidData(entry);
    }
}
