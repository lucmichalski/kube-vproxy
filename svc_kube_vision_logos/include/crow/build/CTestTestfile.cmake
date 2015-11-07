# CMake generated Testfile for 
# Source directory: /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow
# Build directory: /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(crow_test "/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/unittest")
add_test(template_test "/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template/test.py")
set_tests_properties(template_test PROPERTIES  WORKING_DIRECTORY "/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template")
subdirs(examples)
subdirs(tests)
