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

# Include any dependencies generated for this target.
include examples/CMakeFiles/helloworld.dir/depend.make

# Include the progress variables for this target.
include examples/CMakeFiles/helloworld.dir/progress.make

# Include the compile flags for this target's objects.
include examples/CMakeFiles/helloworld.dir/flags.make

examples/CMakeFiles/helloworld.dir/helloworld.cpp.o: examples/CMakeFiles/helloworld.dir/flags.make
examples/CMakeFiles/helloworld.dir/helloworld.cpp.o: ../examples/helloworld.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object examples/CMakeFiles/helloworld.dir/helloworld.cpp.o"
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/helloworld.dir/helloworld.cpp.o -c /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/examples/helloworld.cpp

examples/CMakeFiles/helloworld.dir/helloworld.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/helloworld.dir/helloworld.cpp.i"
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/examples/helloworld.cpp > CMakeFiles/helloworld.dir/helloworld.cpp.i

examples/CMakeFiles/helloworld.dir/helloworld.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/helloworld.dir/helloworld.cpp.s"
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/examples/helloworld.cpp -o CMakeFiles/helloworld.dir/helloworld.cpp.s

examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.requires:

.PHONY : examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.requires

examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.provides: examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.requires
	$(MAKE) -f examples/CMakeFiles/helloworld.dir/build.make examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.provides.build
.PHONY : examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.provides

examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.provides.build: examples/CMakeFiles/helloworld.dir/helloworld.cpp.o


# Object files for target helloworld
helloworld_OBJECTS = \
"CMakeFiles/helloworld.dir/helloworld.cpp.o"

# External object files for target helloworld
helloworld_EXTERNAL_OBJECTS =

examples/helloworld: examples/CMakeFiles/helloworld.dir/helloworld.cpp.o
examples/helloworld: examples/CMakeFiles/helloworld.dir/build.make
examples/helloworld: /usr/local/lib/libboost_date_time-mt.dylib
examples/helloworld: /usr/local/lib/libboost_filesystem-mt.dylib
examples/helloworld: /usr/local/lib/libboost_system-mt.dylib
examples/helloworld: /usr/local/lib/libboost_thread-mt.dylib
examples/helloworld: examples/CMakeFiles/helloworld.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable helloworld"
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/helloworld.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
examples/CMakeFiles/helloworld.dir/build: examples/helloworld

.PHONY : examples/CMakeFiles/helloworld.dir/build

examples/CMakeFiles/helloworld.dir/requires: examples/CMakeFiles/helloworld.dir/helloworld.cpp.o.requires

.PHONY : examples/CMakeFiles/helloworld.dir/requires

examples/CMakeFiles/helloworld.dir/clean:
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples && $(CMAKE_COMMAND) -P CMakeFiles/helloworld.dir/cmake_clean.cmake
.PHONY : examples/CMakeFiles/helloworld.dir/clean

examples/CMakeFiles/helloworld.dir/depend:
	cd /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/examples /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples /Users/lucmichalski/.go/src/github.com/blippar/find-object/include/crow/build/examples/CMakeFiles/helloworld.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : examples/CMakeFiles/helloworld.dir/depend

