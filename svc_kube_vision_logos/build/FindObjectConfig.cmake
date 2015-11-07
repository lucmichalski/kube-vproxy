# - Config file for the FindObject package
# It defines the following variables
#  FindObject_INCLUDE_DIRS - include directories for FindObject
#  FindObject_LIBRARIES    - libraries to link against

# Compute paths
get_filename_component(FindObject_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
set(FindObject_INCLUDE_DIRS "/Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy/svc_kuve_vision_logos/include")

find_library(FindObject_LIBRARIES NAMES find_object NO_DEFAULT_PATH HINTS "/Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy/svc_kuve_vision_logos/lib")
