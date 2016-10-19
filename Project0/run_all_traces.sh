#! /bin/bash
# Author: Megan Avery
# Usage: source run_all_traces.sh

FAILS=0
TESTS=0

#runs a single trace
test_trace(){

	echo -n 'Running trace #'$2': '
	make $1 > test.txt
	echo 'YOUR RUN #'$2':' >> full_trace.txt
	cat test.txt >> full_trace.txt
	echo '-------------------------------------------' >> full_trace.txt

	perl -pi -e 's/\([^)]*\)/\(pid\)/g' test.txt
	sed -i -e '1d' test.txt
	
	make $3 > rtest.txt
	echo 'REFERENCE RUN #'$2':' >> full_trace.txt
	cat rtest.txt >> full_trace.txt
	echo '-------------------------------------------' >> full_trace.txt

	perl -pi -e 's/\([^)]*\)/\(pid\)/g' rtest.txt
	sed -i -e '1d' rtest.txt
	
	DIFFERENCES=$(diff test.txt rtest.txt)
	if [[ $DIFFERENCES == "" ]]; then
		echo -e '\e[0;32mPASSED!\e[0m'
	else
		echo -e '\e[0;31mFAILED!!!\e[0m'
		diff -y test.txt rtest.txt > diff.txt
		sed -i -e 's/^/\t\t/' diff.txt
		cat diff.txt
		echo 'DIFFS FOR TRACE #'$2':' >> full_diffs.txt
		cat diff.txt >> full_diffs.txt
		echo '-------------------------------------------' >> full_diffs.txt

		rm diff.txt
		FAILS=`expr $FAILS + 1`
	fi
	
	rm test.txt
	rm rtest.txt
	echo '-------------------------------------------'
	TESTS=`expr $TESTS + 1`
}

test_trace_11(){
	echo -n 'Running trace #11: '
	make test11 > test.txt

	echo 'YOUR RUN #11:' >> full_trace.txt
	cat test.txt >> full_trace.txt
	echo '-------------------------------------------' >> full_trace.txt
	
	if [[ $MY_SPLIT < 8 ]]; then
		echo -e '\e[0;32mPASSED!\e[0m'
	else
		echo -e '\e[0;31mFAILED!!!\e[0m'
		echo -e '\t- mysplit present in output, should be missing'
		FAILS=`expr $FAILS + 1`
	fi
	
	echo '-------------------------------------------'
	TESTS=`expr $TESTS + 1`
	rm test.txt
}

test_trace_12(){
	echo -n 'Running trace #12: '
	make test12 > test.txt

	echo 'YOUR RUN #12:' >> full_trace.txt
	cat test.txt >> full_trace.txt
	echo '-------------------------------------------' >> full_trace.txt
	
	STATUS=$(grep -c "T      0:00 ./mysplit" "test.txt")
	
	if [[ $STATUS > 0 ]]; then
		echo -e '\e[0;32mPASSED!\e[0m'
	else
		echo -e '\e[0;31mFAILED!!!\e[0m'
		echo -e '\t- ./mysplit should be present with a status of T'
		FAILS=`expr $FAILS + 1`
	fi
	
	echo '-------------------------------------------'
	TESTS=`expr $TESTS + 1`
	rm test.txt
}

test_trace_13(){
	echo -n 'Running trace #13: '
	make test13 > test.txt

	COUNT=$(grep -c "mysplit" "test.txt")
	
	echo 'YOUR RUN #13:' >> full_trace.txt
	cat test.txt >> full_trace.txt
	echo '-------------------------------------------' >> full_trace.txt
	
	if [[ $COUNT == 4 ]]; then
		echo -e '\e[0;32mPASSED!\e[0m'
	else
		echo -e '\e[0;31mFAILED!!!\e[0m'
		echo -e '\t- ./mysplit should be there before the fg call and :xgone after it'
		FAILS=`expr $FAILS + 1`
	fi
	echo '-------------------------------------------'
	
	TESTS=`expr $TESTS + 1`
	rm test.txt
}

echo -e '\e[0;34mCOMPILING...\e[0m'
make all > make_output.txt 2>&1

NUM=$(grep -c error make_output.txt)
if [[ $NUM == 0 ]]; then
{
        echo -e '\e[0;32mNO COMPILE ERRORS!\e[0m'
        echo -------------------------------------------
	echo -e '\nYOUR CODE WILL BE ON LEFT, REFERENCE CODE ON RIGHT\n'
	echo '' > full_trace.txt
	echo 'YOUR RUN ON LEFT, REFERENCE RUN ON RIGHT' > full_diffs.txt

	test_trace test01 01 rtest01 
	test_trace test02 02 rtest02 
	test_trace test03 03 rtest03 
	test_trace test04 04 rtest04 
	test_trace test05 05 rtest05 
	test_trace test06 06 rtest06 
	test_trace test07 07 rtest07 
	test_trace test08 08 rtest08 
	test_trace test09 09 rtest09 
	test_trace test10 10 rtest10

	#special cases to deal with
	test_trace_11
	test_trace_12
	test_trace_13

	test_trace test14 14 rtest14
	test_trace test15 15 rtest15
	test_trace test16 16 rtest16

	echo ''
	echo 'FAILED:' $FAILS 'out of' $TESTS
	echo ''
	echo 'DONE'
	echo ''
	echo 'NOTE: full terminal output for traces saved in full_trace.txt'
	echo ''
	echo 'NOTE: all diffs saved in full_diffs.txt'
	echo ''
}
else 
{
        echo -e '\e[0;31mERRORS:\e[0m'
        grep -n error make_output.txt
}
fi

rm make_output.txt
