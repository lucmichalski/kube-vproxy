# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.3

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/3.3.2/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/3.3.2/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build

# Utility rule file for template_test_copy.

# Include the progress variables for this target.
include tests/template/CMakeFiles/template_test_copy.dir/progress.make

tests/template/CMakeFiles/template_test_copy: ../tests/template/test.py


tests/template/test.py: ../tests/template/test.py
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating test.py"
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template && /usr/local/Cellar/cmake/3.3.2/bin/cmake -E copy /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/tests/template/test.py /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template/test.py

template_test_copy: tests/template/CMakeFiles/template_test_copy
template_test_copy: tests/template/test.py
template_test_copy: tests/template/CMakeFiles/template_test_copy.dir/build.make

.PHONY : template_test_copy

# Rule to build all files generated by this target.
tests/template/CMakeFiles/template_test_copy.dir/build: template_test_copy

.PHONY : tests/template/CMakeFiles/template_test_copy.dir/build

tests/template/CMakeFiles/template_test_copy.dir/clean:
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template && $(CMAKE_COMMAND) -P CMakeFiles/template_test_copy.dir/cmake_clean.cmake
.PHONY : tests/template/CMakeFiles/template_test_copy.dir/clean

tests/template/CMakeFiles/template_test_copy.dir/depend:
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/tests/template /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/tests/template/CMakeFiles/template_test_copy.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tests/template/CMakeFiles/template_test_copy.dir/depend

