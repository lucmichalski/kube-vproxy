# Install script for directory: /Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy/svc_kuve_vision_logos/app

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "runtime")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy/svc_kuve_vision_logos/bin/kubevision_logos")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/kubevision_logos" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/kubevision_logos")
    execute_process(COMMAND "/usr/bin/install_name_tool"
      -change "/Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy/svc_kuve_vision_logos/bin/libfind_objectd.dylib" "libfind_objectd.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/kubevision_logos")
    execute_process(COMMAND /usr/bin/install_name_tool
      -add_rpath "/usr/local/lib/kubevision_logos-0.6"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/kubevision_logos")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/kubevision_logos")
    endif()
  endif()
endif()

