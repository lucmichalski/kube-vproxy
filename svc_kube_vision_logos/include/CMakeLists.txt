# Dependencies
cmake_minimum_required(VERSION 2.8)
find_package(Qt4 4.7 REQUIRED QtCore QtNetwork)

# Configure options
option(GENERATE_DOC
    "Use Doxygen to generate the project documentation" OFF
)

option(ENABLE_TESTS
    "Generate and run tests" OFF
)

set(BUFFER_SIZE 128 CACHE STRING
    "The default buffer size (in bytes) used by Tufão")
add_definitions(-DBUFFER_SIZE=${BUFFER_SIZE})

# Install info
set(libdir lib)

# Targets
add_subdirectory(src)
add_subdirectory(include)
add_subdirectory(pkg)

if (GENERATE_DOC)
    add_subdirectory(doc)
endif()

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# CPack installer
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${TUFAO_BRIEF}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING.LESSER")
include(CPack)

# Testing
if(ENABLE_TESTS)
    include(CTest)
endif()
