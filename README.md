#Pintos Testing Scripts

Scripts for testing the PintOS projects with nice colorful PASS/FAIL output

###DON'T FORGET
You still need to know how to use the basic Pintos testing commands yourself
- test everything: **make check**
- determine what your grade is: **make grade**
- run a single test: **make tests/[project]/[test].result**
  - use the -VERBOSE=1 flag to see the output from the test as it is being run

###How to use the scripts
All scripts need to go in the [project]/build directory to be run properly. 
- all scripts will save off test outputs in a separate file that you can check later

Can run with command: 

**source [test script name].**
- it might be helpful to run chmod 755 [test script name] on all the scripts

The create_custom_test_runner can be run with: 

**source create_custom_test_runner [name of script] [list of test categories separated by spaces]**
- need to make sure that create_helpers.zip has been unzipped within the [project]/build directory
- will create a custom test script that only runs the tests associated with the categories you gave it
- list of categories for each project in the test_categories.txt file

clean, compile, and show_test can be run for any of the projects in Pintos
- if run compile with the -w flag then can see all the warnings, otherwise will only show you errors
- clean runs **make clean** but without throwing up all over your terminal
- show_test will cat a test onto your screen, you will be prompted for a project (eg threads) and test name (eg args-none)

*PS: if the tests seem to run really fast it's because they are all already up to date and you need to touch a file so they can actually rerun the tests*
