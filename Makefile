TESTS_DIR=.

GO_FILES = ${shell find ${TESTS_DIR}/*.go}
TEST_NAMES = ${sort ${subst .go,,${notdir ${GO_FILES}}}}
OK_FILES = ${addprefix ${TESTS_DIR}/,${addsuffix .ok, ${TEST_NAMES}}}
TESTS = ${addsuffix .test, ${TEST_NAMES}}
OUTS = ${addsuffix .out, ${TEST_NAMES}}
DIFFS = ${addsuffix .diff, ${TEST_NAMES}}
RESULTS = ${addsuffix .result, ${TEST_NAMES}}
RUNS = ${addsuffix .run, ${TEST_NAMES}}
BUILDS = ${addsuffix .build, ${TEST_NAMES}}

.PHONY : all test clean

all : ${BUILDS};

${BUILDS} : %.build : Makefile ${TESTS_DIR}/%.go
	go build -o $*.build ${TESTS_DIR}/$*.go

${OUTS} : %.out : Makefile %.build
	(./$*.build > $*.out 2> $*.err || true)

${DIFFS} : %.diff : ${TESTS_DIR}/%.ok %.out Makefile
	(diff -wB $*.out ${TESTS_DIR}/$*.ok > $*.diff 2>&1 || true)

${RESULTS} : %.result : %.diff Makefile
	((test -s $*.diff) && (echo "fail" > $*.result)) || (echo "pass" > $*.result)

${TESTS} : %.test : %.result Makefile
	@echo "$* ... `cat $*.result`"

${RUNS} : %.run : Makefile
	@go run ${TESTS_DIR}/$*.go

test: ${TESTS};

clean :
	-rm -rf *.out *.diff *.result *.err *.build

help:
	@echo Targets
	@echo "    test ... run all tests"
	@echo "    <test_name>.test ... run the given test"
	@echo "    <test_name>.run  ... show the output from running the given test"
	@echo "    clean            ... remove all generated files"
	@echo "    format           ... format haskell code"
	@echo "    lint             ... run hlint"
	@echo "Known tests (sourced from TESTS_DIR=${TESTS_DIR}):"
	@echo "    ${TEST_NAMES}"
	@echo "Environment variables"
	@echo "    TESTS_DIR = ${TESTS_DIR} ... changes the source of the tests"
	@echo "Important files"
	@echo "    ${TESTS_DIR}/<test_name>.go ... test source code"
	@echo "    ${TESTS_DIR}/<test_name>.ok  ... expected output"
	@echo "    <test_name>.out    ... actual output"
	@echo "    <test_name>.err    ... stderr from running"
	@echo "    <test_name>.diff   ... difference (empty means identical)"
	@echo "    <test_name>.result ... pass/fail/timeout"
	@echo "    <test_name>.time   ... runtime"

