import ballerina/io;
import ballerina/lang.'int as ints;
//import ballerina/lang.'string as strings;

public function main() returns error? {
    string filePath = "data.csv";
    DataFrame df = check loadCsvData(filePath);
    io:println("DataFrame content: " + df.toString());
    io:println("Median: " + (check computeMedian(df, "Age")).toString());
}

type DataFrame record {
   // Each key is corresponding to a column name.
};


function loadCsvData(string path) returns DataFrame|error {
	string[][] content = check io:fileReadCsv(path, skipHeaders = 0);
    io:println("string[][]: " + content.toString());
    string[] headers = content[0];
    DataFrame df = {};

    int numberOfHeaders = headers.length();
    int numberOfRows = content.length() - 1; // Omit the header row
    int i = 0;

    while i < numberOfHeaders {
        string[] currentColumn = [];
        int j = 0;
        while j < numberOfRows{
            currentColumn[j] = content[j + 1][i];
            j += 1;
        }
        df[headers[i]] = currentColumn;
        i += 1;
    }
    return df;
}


function computeMedian(DataFrame df, string columnName) returns int|error {
    int[] intArray = [];
    string[] inputArray = <string[]>df[columnName];
    int i = 0;
    int arrayLength = inputArray.length();
    while i < arrayLength {
        intArray[i] = check ints:fromString(inputArray[i]);
        i += 1;
    }
    int midPoint = (arrayLength - 1) / 2 + 1;
    return intArray[midPoint - 1];
}
