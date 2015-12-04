message(STATUS "downloading...
     src='http://download.qt-project.org/official_releases/qt/5.2/5.2.1/single/qt-everywhere-opensource-src-5.2.1.tar.gz'
     dst='/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/qt5Cmake/external/Download/qt5/qt-everywhere-opensource-src-5.2.1.tar.gz'
     timeout='none'")




file(DOWNLOAD
  "http://download.qt-project.org/official_releases/qt/5.2/5.2.1/single/qt-everywhere-opensource-src-5.2.1.tar.gz"
  "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/qt5Cmake/external/Download/qt5/qt-everywhere-opensource-src-5.2.1.tar.gz"
  SHOW_PROGRESS
  # no TIMEOUT
  STATUS status
  LOG log)

list(GET status 0 status_code)
list(GET status 1 status_string)

if(NOT status_code EQUAL 0)
  message(FATAL_ERROR "error: downloading 'http://download.qt-project.org/official_releases/qt/5.2/5.2.1/single/qt-everywhere-opensource-src-5.2.1.tar.gz' failed
  status_code: ${status_code}
  status_string: ${status_string}
  log: ${log}
")
endif()

message(STATUS "downloading... done")
