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

# Utility rule file for amalgamation.

# Include the progress variables for this target.
include CMakeFiles/amalgamation.dir/progress.make

CMakeFiles/amalgamation: amalgamate/crow_all.h


amalgamate/crow_all.h: ../include/*.h
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating amalgamate/crow_all.h"
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/amalgamate && python /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/amalgamate/merge_all.py /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/include
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/amalgamate && /usr/local/Cellar/cmake/3.3.2/bin/cmake -E copy /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/amalgamate/crow_all.h /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/amalgamate

amalgamation: CMakeFiles/amalgamation
amalgamation: amalgamate/crow_all.h
amalgamation: CMakeFiles/amalgamation.dir/build.make

.PHONY : amalgamation

# Rule to build all files generated by this target.
CMakeFiles/amalgamation.dir/build: amalgamation

.PHONY : CMakeFiles/amalgamation.dir/build

CMakeFiles/amalgamation.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/amalgamation.dir/cmake_clean.cmake
.PHONY : CMakeFiles/amalgamation.dir/clean

CMakeFiles/amalgamation.dir/depend:
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/CMakeFiles/amalgamation.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/amalgamation.dir/depend
