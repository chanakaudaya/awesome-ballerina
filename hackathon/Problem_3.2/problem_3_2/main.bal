import ballerina/io;
import ims/billionairehub;

# Client ID and Client Secret to connect to the billionaire API
configurable string clientId = "V5bhO97JalSWqUMcItOuKzhf1pca";
configurable string clientSecret = "eeXDwSQOfX_WZ2PMaD2rvOjyCTga";

public function main() {
    string[] countries = ["China", "India", "Japan", "Hong Kong"];
    io:println(getTopXBillionaires(countries, 10));
}

public function getTopXBillionaires(string[] countries, int x) returns string[]|error {
    // Create the client connector
    billionairehub:Client cl = check new ({auth: {clientId, clientSecret}});
    billionairehub:Billionaire[] topBs = [];
    int j = 0;

    foreach string country in countries {
        billionairehub:Billionaire[] bills = check cl->getBillionaires(country);
        var topNW = from var b in bills
                    order by b.netWorth descending
                    select b;
        int i = 0;
        if topNW.length() >= x {
            while i < x {
                topBs[j] = topNW[i];
                i += 1;
                j += 1;
            }
        } else {
            while i < topNW.length() {
                topBs[j] = topNW[i];
                i += 1;
                j += 1;
            }
        }
        
    }

    var finalBs = from var b in topBs
                  order by b.netWorth descending
                  select b;
    
    string[] results = [];
    int k = 0;
    if finalBs.length() >= x {
        while k < x {
            results[k] = finalBs[k].name;
            k += 1;
        }
    } else {
        while k < finalBs.length() {
            results[k] = finalBs[k].name;
            k += 1;
        }
    }

    // TODO Write your logic here
    return results;
}
