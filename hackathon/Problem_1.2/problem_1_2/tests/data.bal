function data() returns string[][]|error {
    return [
        //[inputFile, actualOutputFile, expectedOutputFile]
        [
            "tests/resources/example01_input.csv",
            "target/example01_output.csv",
            "tests/resources/example01_output_expected.csv"
        ],
        [
            "tests/resources/example02_input.csv",
            "target/example02_output.csv",
            "tests/resources/example02_output_expected.csv"
        ]
    ];
}
