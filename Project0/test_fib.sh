#! /bin/bash

FAILS=0
TESTS=12
test_fib() {
	echo -n $1': '
	ANSWER=$(./fib $1)
	if [[ $ANSWER -ne $2 ]]; then {
		echo -e '\e[0;31mFAILED!!!\e[0m'
		echo -e '\tactual: '$ANSWER
		echo -e '\texpected: ' $2
	}
	else {
		echo -e '\e[0;32mPASSED!\e[0m'
	}
	fi
	
	echo ------------------------------
}

echo -e '\e[0;34mCOMPILING...\e[0m'
make all > make_output.txt 2>&1

NUM=$(grep -c error make_output.txt)
if [[ $NUM == 0 ]]; then
{
        echo -e '\e[0;32mNO COMPILE ERRORS!\e[0m'
        echo ------------------------------
	echo TESTING FIB FOR INPUTS 0 - 12

	echo ------------------------------

	test_fib 0 0
	test_fib 1 1
	test_fib 2 1
	test_fib 3 2
	test_fib 4 3
	test_fib 5 5
	test_fib 6 8
	test_fib 7 13
	test_fib 8 21
	test_fib 9 34
	test_fib 10 55
	test_fib 11 89
	test_fib 12 144
}
else 
{
        echo -e '\e[0;31mERRORS:\e[0m'
        grep -n error make_output.txt
}
fi

rm make_output.txt

