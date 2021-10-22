import ballerina/io;
import ballerina/lang.'int as ints;

public function main() returns error? {
    string filePath = "data.csv";
    DataFrame df = check loadCsvData(filePath);
    io:println("DataFrame content: " + df.toString() + "\n");
    io:println("DataFrame column \"Name\" content: " + df.data.get("Name").toString() + "\n");
    float[] heights = [5.5, 5.7, 6.01, 5.4, 5.93, 5.85, 6.2];
    addColumn(df, "Heights", heights);
    io:println("DataFrame content after adding the column \"Heights\" content: " + df.data.toString() + "\n");
    deleteColumn(df, "Heights");
    io:println("DataFrame content after deleting the column \"Heights\" content: " + df.data.toString() + "\n");
    io:println("Median: " + (check computeMedian(df, "Age")).toString() + "\n");
    io:println("Mode: " + (check computeMode(df, "Age")).toString() + "\n");
    json newRow = {Name: "Ian Goodfellow", Age:26, Gender:"male"};
    check addRow(df, newRow);
    io:println("DataFrame content after adding the row for \"Ian Goodfellow\" content: " + df.data.toString() + "\n");
    deleteRow(df, 2);
    io:println("DataFrame content after removing the row for \"Jeff Hinton\" content: " + df.data.toString() + "\n");
    updateField(df, "Thomas Edison", "Name", 3);
    io:println("DataFrame content after replacing the row for \"Nicola Tesla\" with \"Thomas Edison\" content: " + df.data.toString() + "\n");
}


type Value int|string|float|boolean;

type DataFrame record {
    map<Value[]> data;
    map<Index> indexes?;
};

type Index record {
    map<int> labelIndex?;
};


function loadCsvData(string path) returns DataFrame|error {
	string[][] content = check io:fileReadCsv(path, skipHeaders = 0);
    io:println("string[][]: " + content.toString() + "\n");
    string[] headers = content[0];
    DataFrame df = {data: {}};

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
        df.data[headers[i]] = currentColumn;
        i += 1;
    }
    return df;
}

function addColumn(DataFrame df, string columnName, Value[] series) {
    df.data[columnName] = series;
}

function deleteColumn(DataFrame df, string columnName) {
    _ = df.data.remove(columnName);
}

function addRow(DataFrame df, json row) returns error? {
    string[] columns = df.data.keys();
    map<json> currRow = <map<json>>row;
    int i = 0;
    while i < columns.length() {
        Value[]? vals = df.data[columns[i]];
        if vals is Value[] {
            Value val = <Value>currRow.get(<string>columns[i]);
            vals.push(val.toString());
        }
        i += 1;
    }
}

function deleteRow(DataFrame df, int index) {
    string[] columns = df.data.keys();
    int i = 0;
    while i < columns.length() {
        Value[]? vals = df.data[columns[i]];
        if vals is Value[] {
            _ = vals.remove(index);
        }
        i += 1;
    }
}

function updateField(DataFrame df, Value newValue, string column, int rowIndex) {
    df.data[column][rowIndex] = newValue;
}


function computeMedian(DataFrame df, string columnName) returns int|error {
    int[] intArray = [];
    string[] inputArray = <string[]>df.data[columnName];
    int i = 0;
    int arrayLength = inputArray.length();
    while i < arrayLength {
        intArray[i] = check ints:fromString(inputArray[i]);
        i += 1;
    }
    bubbleSort(intArray);
    int midPoint = (arrayLength - 1) / 2 + 1;
    return intArray[midPoint - 1];
}

function computeMode(DataFrame df, string columnName) returns int|error {
    int[] intArray = [];
    string[] inputArray = <string[]>df.data[columnName];
    int i = 0;
    int arrayLength = inputArray.length();
    map<int> frequencies = {};
    int max = 0;
    int mode = -1;
    while i < arrayLength {
        intArray[i] = check ints:fromString(inputArray[i]);
        int? existingCount = frequencies[inputArray[i]];
        if existingCount is int {
            existingCount += 1;
            frequencies[inputArray[i]] = <int>existingCount;
            if <int>existingCount > max {
                max = <int>existingCount;
                mode = check ints:fromString(inputArray[i]);
            }
        } else {
            frequencies[inputArray[i]] = 1;
        }
        i += 1;
    }
    return mode;
}

function bubbleSort(int[] arr) {
    int n = arr.length();
    int i = 0;
    while i < n -1 {
        int j = 0;
        while j < n - i - 1 {
            if arr[j] > arr[j+1] {
                // swap arr[j+1] and arr[j]
                int temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
            j += 1;
        }
        i += 1;
    }
 }
