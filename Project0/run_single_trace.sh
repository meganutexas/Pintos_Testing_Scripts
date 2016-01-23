test_single_trace(){
	echo '-------------------------------------------' >> single_trace.txt
	echo '-------------------------------------------'
	echo -n 'Running trace #'$1': '
	make test$1 > test.txt
	echo 'YOUR RUN #'$1':' >> single_trace.txt
	cat test.txt >> single_trace.txt
	echo '-------------------------------------------' >> single_trace.txt
	
	perl -pi -e 's/\([^)]*\)/\(pid\)/g' test.txt
	sed -i -e '1d' test.txt
	
	make rtest$1 > rtest.txt
	echo 'REFERENCE RUN #'$1':' >> single_trace.txt
	cat rtest.txt >> single_trace.txt
	echo '-------------------------------------------' >> single_trace.txt
	
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
		echo 'DIFFS FOR TRACE #'$2':' >> single_diff.txt
		cat diff.txt >> single_diff.txt
	
		rm diff.txt
	fi
	
	rm test.txt
	rm rtest.txt
	echo '-------------------------------------------'
}

test_trace_11(){
	echo '-------------------------------------------' >> single_trace.txt
	echo '-------------------------------------------'
	echo -n 'Running trace #11: '
	make test11 > test.txt

	echo 'YOUR RUN #11:' >> single_trace.txt
	cat test.txt >> single_trace.txt
	echo '-------------------------------------------' >> single_trace.txt
	
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
	echo '-------------------------------------------' >> single_trace.txt
	echo '-------------------------------------------'
	echo -n 'Running trace #12: '
	make test12 > test.txt

	echo 'YOUR RUN #12:' >> single_trace.txt
	cat test.txt >> single_trace.txt
	echo '-------------------------------------------' >> single_trace.txt
	
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
	echo '-------------------------------------------' >> single_trace.txt
	echo '-------------------------------------------'
	echo -n 'Running trace #13: '
	make test13 > test.txt

	COUNT=$(grep -c "mysplit" "test.txt")
	
	echo 'YOUR RUN #13:' >> single_trace.txt
	cat test.txt >> single_trace.txt
	echo '-------------------------------------------' >> single_trace.txt
	
	if [[ $COUNT == 4 ]]; then
		echo -e '\e[0;32mPASSED!\e[0m'
	else
		echo -e '\e[0;31mFAILED!!!\e[0m'
		echo -e '\t- ./mysplit should be there before the fg call and gone after it'
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
	if [[ $# == 1 ]]; then 
	{
		echo '' > single_trace.txt
		echo '' > single_diff.txt

		TEST_NUM=$1

		if [[ $TEST_NUM == 11 ]]; then
			test_trace_11
		elif [[ $TEST_NUM == 12 ]]; then
			test_trace_12
		elif [[ $TEST_NUM == 13 ]]; then
			test_trace_13
		else
			test_single_trace $TEST_NUM
		fi

		echo ''
		echo 'DONE'
		echo ''
		echo 'NOTE:  terminal output for trace saved in single_trace.txt'
		echo ''
		echo 'NOTE: diff saved in single_diff.txt'
		echo ''
	}
	else
	{
		echo -e '\e[0;31mUSAGE ERROR!\e[0m'
		echo usage: bash run_single_trace [trace number]
		echo example: bash run_single_trace 01
	}
	fi
}
else 
{
        echo -e '\e[0;31mERRORS:\e[0m'
        grep -n error make_output.txt
}
fi

rm make_output.txt
