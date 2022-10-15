function data() returns string[][]|error {
    return [
        //[inputFile, actualOutputFile, expectedOutputFile]
        [
            "tests/resources/example01_input.json",
            "target/example01_output.json",
            "tests/resources/example01_output_expected.json"
        ],
        [
            "tests/resources/example02_input.json",
            "target/example02_output.json",
            "tests/resources/example02_output_expected.json"
        ]
    ];
}
