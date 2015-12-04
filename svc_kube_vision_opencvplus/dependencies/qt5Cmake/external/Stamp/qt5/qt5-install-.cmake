

set(command "make;install")
execute_process(
  COMMAND ${command}
  RESULT_VARIABLE result
  OUTPUT_FILE "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/qt5Cmake/external/Stamp/qt5/qt5-install-out.log"
  ERROR_FILE "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/qt5Cmake/external/Stamp/qt5/qt5-install-err.log"
  )
if(result)
  set(msg "Command failed: ${result}\n")
  foreach(arg IN LISTS command)
    set(msg "${msg} '${arg}'")
  endforeach()
  set(msg "${msg}\nSee also\n  /Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/qt5Cmake/external/Stamp/qt5/qt5-install-*.log")
  message(FATAL_ERROR "${msg}")
else()
  set(msg "qt5 install command succeeded.  See also /Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/qt5Cmake/external/Stamp/qt5/qt5-install-*.log")
  message(STATUS "${msg}")
endif()
