{pkgs, ...}: let
  /*
    return type: derivation
    $drv/output.json exists and the json satisfies schema below
    schema: {
      type: object,
      properties: {
        status: {
          type: string,
          enum: ["CE", "RE", "WA", "AC"]
        },
        testname: {
          type: string
        },
        source: {
          type: string
        },
        stdin: {
          type: string
        },
        actual_stdout: {
          type: string
        },
        expected_stdout: {
          type: string
        }
      }
    }
  */
  single-test-drv = {
    language-name, # type: string, example: "python3"
    testcase-name, # type: string, example: "test1"
    compile-cmd, # type: string, example: "cp -r src/* $out"
    run-cmd, # type: string, example: "python3 src/main.py"
    source, # type: string, example: "a = int(input())\nprint(a*2)"
    stdin, # type: string, example: "5"
    expected-stdout, # type: string, example: "10"  
  }:
  let
    stdin-file = pkgs.writeTextFile {
      name = "stdin";
      text = stdin;
    };
    expected-stdout-file = pkgs.writeTextFile {
      name = "expected-stdout";
      text = expected-stdout;
    };
  in pkgs.stdenv.mkDerivation {
    name = "test-${language-name}-${testcase-name}";
    src = pkgs.writeTextFile {
      name = "test-${language-name}-${testcase-name}-source";
      text = source;
      destination = "/main";
    };
    buildPhase = ''
        export TRAOJUDGE_BUILD_SOURCE=$src/main
        export TRAOJUDGE_BUILD_OUTPUT=/tmp/output
        export TRAOJUDGE_BUILD_TEMPDIR=/tmp/tempdir
        STATUS="AC"
        mkdir -p $out
        mkdir -p $TRAOJUDGE_BUILD_OUTPUT
        mkdir -p $TRAOJUDGE_BUILD_TEMPDIR
        touch /tmp/stdout.txt
        touch /tmp/stderr.txt
        if ! ${compile-cmd}; then
          echo "Compilation error for ${language-name} ${testcase-name}"
          STATUS="CE"
        elif ! ${run-cmd} < ${stdin-file} > /tmp/stdout.txt 2> /tmp/stderr.txt; then
          echo "Runtime error for ${language-name} ${testcase-name}"
          STATUS="RE"
        else
          echo "Running tests for ${language-name} ${testcase-name}"
          if diff -bB /tmp/stdout.txt ${expected-stdout-file}; then
            echo "Test passed for ${language-name} ${testcase-name}"
          else
            echo "Test failed for ${language-name} ${testcase-name}"
            STATUS="WA"
          fi
        fi
        echo "{
          \"status\": \"$STATUS\",
          \"testname\": \"${testcase-name}\",
          \"source\": \"${source}\",
          \"stdin\": \"${stdin}\",
          \"actual_stdout\": \"$(cat /tmp/stdout.txt)\",
          \"expected_stdout\": \"${expected-stdout}\"
        }" > $out/output.json
      '';
  };
  /*
    return type: derivation
    $drv/lang-report.json exists and the json satisfies schema below
    schema: {
      type: object,
      properties: {
        language-name: {
          type: string
        },
        compile-cmd: {
          type: string
        },
        run-cmd: {
          type: string
        },
        tests: {
          type: array,
          items: <SINGLE_TEST_DRV/output.json>
        }
      }
    }
  */
in single-test-drv