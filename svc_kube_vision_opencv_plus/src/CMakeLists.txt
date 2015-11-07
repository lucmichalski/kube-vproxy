
SET(SRC_FILES 
   ./QtOpenCV.cpp
   ./Settings.cpp
   ./FindObject.cpp
   ./Vocabulary.cpp
   ./JsonWriter.cpp
   ./utilite/ULogger.cpp
   ./utilite/UPlot.cpp
   ./utilite/UDirectory.cpp
   ./utilite/UFile.cpp
   ./utilite/UConversion.cpp
   ./json/jsoncpp.cpp
)

SET(INCLUDE_DIRS
   ${CMAKE_CURRENT_SOURCE_DIR}/../include
   ${CMAKE_CURRENT_SOURCE_DIR}
   ${OpenCV_INCLUDE_DIRS}
   ${CMAKE_CURRENT_BINARY_DIR} # for qt ui generated in binary dir
)

INCLUDE(${QT_USE_FILE})

SET(LIBRARIES
   ${QT_LIBRARIES} 
   ${OpenCV_LIBS} 
)

#include files
INCLUDE_DIRECTORIES(${INCLUDE_DIRS})

# create a library from the source files
ADD_LIBRARY(find_object ${SRC_FILES})
# Linking with Qt libraries
TARGET_LINK_LIBRARIES(find_object ${LIBRARIES})

IF(NOT CATKIN_BUILD)
   INSTALL(TARGETS find_object
      RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT runtime
      LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT devel
      ARCHIVE DESTINATION "${INSTALL_LIB_DIR}" COMPONENT devel)
      
   install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../include/ DESTINATION "${INSTALL_INCLUDE_DIR}" COMPONENT devel FILES_MATCHING PATTERN "*.h" PATTERN ".svn" EXCLUDE)
ENDIF()
