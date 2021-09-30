import ballerina/io;
import ballerina/lang.'int as ints;

public function main() returns error? {
    string filePath = "data.csv";
    DataFrame df = check loadCsvData(filePath);
    io:println("DataFrame content: " + df.toString());
    io:println();
    io:println("DataFrame column \"Name\" content: " + df["Name"].toString());
    io:println();
    float[] heights = [5.5, 5.7, 6.01, 5.4, 5.93, 5.85, 6.2];
    addOrUpdateColumn(df, "Heights", heights);
    io:println("DataFrame content after adding the column \"Heights\" content: " + df.toString());
    io:println();
    deleteColumn(df, "Heights");
    io:println("DataFrame content after deleting the column \"Heights\" content: " + df.toString());
    io:println();
    io:println("Median: " + (check computeMedian(df, "Age")).toString());
    io:println();
    io:println("Mode: " + (check computeMode(df, "Age")).toString());
}

type DataFrame record {
   // Each key is corresponding to a column name.
};


function loadCsvData(string path) returns DataFrame|error {
	string[][] content = check io:fileReadCsv(path, skipHeaders = 0);
    io:println("string[][]: " + content.toString());
    io:println();
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

function addOrUpdateColumn(DataFrame df, string columnName, string[]|int[]|float[]|boolean[] series) {
    df[columnName] = series;
}

function deleteColumn(DataFrame df, string columnName) {
    _ = df.remove(columnName);
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

function computeMode(DataFrame df, string columnName) returns int|error {
    int[] intArray = [];
    string[] inputArray = <string[]>df[columnName];
    int i = 0;
    int arrayLength = inputArray.length();
    map<int> frequencies = {};
    int max = 0;
    int mode = -1;
    while i < arrayLength {
        intArray[i] = check ints:fromString(inputArray[i]);
        int? existingCount = frequencies[inputArray[i]];
        if !(existingCount is ()) {
            existingCount += 1;
            frequencies[inputArray[i]] = existingCount;
            if existingCount > max {
                max = existingCount;
                mode = check ints:fromString(inputArray[i]);
            }
        } else {
            frequencies[inputArray[i]] = 1;
        }
        i += 1;
    }
    return mode;
}
