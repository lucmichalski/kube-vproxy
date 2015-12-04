
cmake_minimum_required(VERSION 2.8)

project(Qt5)

include(GNUInstallDirs)
include(ExternalProject)

if(NOT EXTERNAL_PROJECTS_BASE)
	set(EXTERNAL_PROJECTS_BASE "${CMAKE_BINARY_DIR}/external")
	set_property(DIRECTORY PROPERTY "EP_BASE" ${EXTERNAL_PROJECTS_BASE})
endif()

#http://download.qt-project.org/official_releases/qt/5.2/5.2.1/single/qt-everywhere-opensource-src-5.2.1.tar.gz

set(EXTERNAL_PROJECT "qt5")
set(${EXTERNAL_PROJECT}_VERSION "5.2.1")
set(${EXTERNAL_PROJECT}_NAME "qt-everywhere-opensource-src-${${EXTERNAL_PROJECT}_VERSION}")
set(${EXTERNAL_PROJECT}_EXT ".tar.gz")
set(${EXTERNAL_PROJECT}_FILE "${${EXTERNAL_PROJECT}_NAME}${${EXTERNAL_PROJECT}_EXT}")
set(${EXTERNAL_PROJECT}_URL "http://download.qt-project.org/official_releases/qt/5.2/${${EXTERNAL_PROJECT}_VERSION}/single/${${EXTERNAL_PROJECT}_FILE}")
set(${EXTERNAL_PROJECT}_CONFIGURE "-opensource;-confirm-license;-release;-static;-optimized-qmake;-no-compile-examples;-qt-zlib;-qt-libpng;-qt-libjpeg;-qt-freetype;-qt-pcre;-qt-xcb;-qt-xkbcommon;-no-directfb;-no-linuxfb")
set(${EXTERNAL_PROJECT}_MAKE "")
set(${EXTERNAL_PROJECT}_DEPENDS "")
list(APPEND EXTERNAL_PROJECTS ${EXTERNAL_PROJECT})

foreach(EXTERNAL_PROJECT ${EXTERNAL_PROJECTS})
	message(STATUS "Adding External Project: ${EXTERNAL_PROJECT}")
	
	ExternalProject_Add(${EXTERNAL_PROJECT}
		URL "${${EXTERNAL_PROJECT}_URL}"
		CONFIGURE_COMMAND "${EXTERNAL_PROJECTS_BASE}/Source/${EXTERNAL_PROJECT}/configure" ${${EXTERNAL_PROJECT}_CONFIGURE}
		BUILD_COMMAND "make" ${${EXTERNAL_PROJECT}_MAKE}
		INSTALL_COMMAND "make" install ${${EXTERNAL_PROJECT}_MAKE}
		DEPENDS ${${EXTERNAL_PROJECT}_DEPENDS}
		BUILD_IN_SOURCE 1
		LOG_BUILD 1
		LOG_INSTALL 1)
endforeach()

set(MAKE_ALL "make")

foreach(EXTERNAL_PROJECT ${EXTERNAL_PROJECTS})
	set(MAKE_ALL "${MAKE_ALL} ${EXTERNAL_PROJECT}")
endforeach()

message(STATUS "${MAKE_ALL}")

