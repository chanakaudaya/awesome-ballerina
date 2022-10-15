function data() returns string[][]|error {
    return [
        //[inputFile, actualOutputFile, expectedOutputFile]
        [
            "tests/resources/example01_input.xml",
            "target/example01_output.xml",
            "tests/resources/example01_output_expected.xml"
        ],
        [
            "tests/resources/example02_input.xml",
            "target/example02_output.xml",
            "tests/resources/example02_output_expected.xml"
        ]
    ];
}
