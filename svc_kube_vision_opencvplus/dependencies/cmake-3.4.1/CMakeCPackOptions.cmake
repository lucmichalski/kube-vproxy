# This file is configured at cmake time, and loaded at cpack time.
# To pass variables to cpack from cmake, they must be configured
# in this file.

if(CPACK_GENERATOR MATCHES "NSIS")
  set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")

  # set the install/unistall icon used for the installer itself
  # There is a bug in NSI that does not handle full unix paths properly.
  set(CPACK_NSIS_MUI_ICON "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Utilities/Release\\CMakeLogo.ico")
  set(CPACK_NSIS_MUI_UNIICON "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Utilities/Release\\CMakeLogo.ico")
  # set the package header icon for MUI
  set(CPACK_PACKAGE_ICON "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Utilities/Release\\CMakeInstall.bmp")
  # tell cpack to create links to the doc files
  set(CPACK_NSIS_MENU_LINKS
    "doc/cmake-3.4/html/index.html" "CMake Documentation"
    "https://cmake.org" "CMake Web Site"
    )
  # Use the icon from cmake-gui for add-remove programs
  set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\cmake-gui.exe")

  set(CPACK_NSIS_PACKAGE_NAME "CMake 3.4.1")
  set(CPACK_NSIS_DISPLAY_NAME "CMake 3.4.1, a cross-platform, open-source build system")
  set(CPACK_NSIS_HELP_LINK "https://cmake.org")
  set(CPACK_NSIS_URL_INFO_ABOUT "http://www.kitware.com")
  set(CPACK_NSIS_CONTACT cmake@cmake.org)
  set(CPACK_NSIS_MODIFY_PATH ON)
endif()

# include the cpack options for qt dialog if they exist
# they might not if qt was not enabled for the build
include("/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Source/QtDialog/QtDialogCPack.cmake" OPTIONAL)

if(CPACK_GENERATOR MATCHES "IFW")

  # Installer configuration
  set(CPACK_IFW_PACKAGE_TITLE "CMake Build Tool")
  set(CPACK_IFW_PRODUCT_URL "https://cmake.org")
  
  set(CPACK_IFW_PACKAGE_WINDOW_ICON
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Source/QtDialog/CMakeSetup128.png")
  set(CPACK_IFW_PACKAGE_CONTROL_SCRIPT
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Source/QtIFW/controlscript.qs")

  # Uninstaller configuration
  set(CPACK_IFW_PACKAGE_MAINTENANCE_TOOL_NAME "cmake-maintenance")
  
  # Unspecified
  set(CPACK_IFW_COMPONENT__VERSION
    "3.4.1")

  # Package configuration group
  set(CPACK_IFW_PACKAGE_GROUP CMake)

  # Group configuration

  # CMake
  set(CPACK_COMPONENT_GROUP_CMAKE_DISPLAY_NAME
    "CMake")
  set(CPACK_COMPONENT_GROUP_CMAKE_DESCRIPTION
    "CMake is a build tool")
  set(CPACK_IFW_COMPONENT_GROUP_CMAKE_VERSION
    "3.4.1")
  set(CPACK_IFW_COMPONENT_GROUP_CMAKE_LICENSES
    "CMake Copyright" "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Copyright.txt"
    )
  set(CPACK_IFW_COMPONENT_GROUP_CMAKE_SCRIPT "")
  set(CPACK_IFW_COMPONENT_GROUP_CMAKE_PRIORITY 100)

  # Tools
  set(CPACK_COMPONENT_GROUP_TOOLS_DISPLAY_NAME "Command-Line Tools")
  set(CPACK_COMPONENT_GROUP_TOOLS_DESCRIPTION
    "Command-Line Tools: cmake, ctest and cpack")
  set(CPACK_COMPONENT_GROUP_TOOLS_PARENT_GROUP CMake)
  set(CPACK_IFW_COMPONENT_GROUP_TOOLS_PRIORITY 90)
  set(CPACK_IFW_COMPONENT_GROUP_TOOLS_VERSION "3.4.1")

  set(CPACK_COMPONENT_CMAKE_DISPLAY_NAME "cmake")
  set(CPACK_COMPONENT_CMAKE_DESCRIPTION
    "The \"cmake\" executable is the CMake command-line interface")
  set(CPACK_COMPONENT_CMAKE_REQUIRED TRUE)
  set(CPACK_COMPONENT_CMAKE_GROUP Tools)
  set(CPACK_IFW_COMPONENT_CMAKE_NAME "CMake")
  set(CPACK_IFW_COMPONENT_CMAKE_PRIORITY 89)
  set(CPACK_IFW_COMPONENT_CMAKE_VERSION "3.4.1")

  set(CPACK_COMPONENT_CTEST_DISPLAY_NAME "ctest")
  set(CPACK_COMPONENT_CTEST_DESCRIPTION
    "The \"ctest\" executable is the CMake test driver program")
  set(CPACK_COMPONENT_CTEST_REQUIRED TRUE)
  set(CPACK_COMPONENT_CTEST_GROUP Tools)
  set(CPACK_IFW_COMPONENT_CTEST_NAME "CTest")
  set(CPACK_IFW_COMPONENT_CTEST_PRIORITY 88)
  set(CPACK_IFW_COMPONENT_CTEST_VERSION "3.4.1")

  set(CPACK_COMPONENT_CPACK_DISPLAY_NAME "cpack")
  set(CPACK_COMPONENT_CPACK_DESCRIPTION
    "The \"cpack\" executable is the CMake packaging program")
  set(CPACK_COMPONENT_CPACK_REQUIRED TRUE)
  set(CPACK_COMPONENT_CPACK_GROUP Tools)
  set(CPACK_IFW_COMPONENT_CPACK_NAME "CPack")
  set(CPACK_IFW_COMPONENT_CPACK_PRIORITY 87)
  set(CPACK_IFW_COMPONENT_CPACK_VERSION "3.4.1")

  set(CPACK_COMPONENT_CMAKEXBUILD_DISPLAY_NAME "cmakexbuild")
  set(CPACK_COMPONENT_CMAKEXBUILD_DESCRIPTION
    "The \"cmakexbuild\" executable is a wrapper program for \"xcodebuild\"")
  set(CPACK_COMPONENT_CMAKEXBUILD_REQUIRED TRUE)
  set(CPACK_COMPONENT_CMAKEXBUILD_GROUP Tools)
  set(CPACK_IFW_COMPONENT_CMAKEXBUILD_NAME "CMakeXBuild")
  set(CPACK_IFW_COMPONENT_CMAKEXBUILD_PRIORITY 86)
  set(CPACK_IFW_COMPONENT_CMAKEXBUILD_VERSION "3.4.1")

  # Dialogs
  set(CPACK_COMPONENT_GROUP_DIALOGS_DISPLAY_NAME "Interactive Dialogs")
  set(CPACK_COMPONENT_GROUP_DIALOGS_DESCRIPTION
    "Interactive Dialogs with Console and GUI interfaces")
  set(CPACK_COMPONENT_GROUP_DIALOGS_PARENT_GROUP CMake)
  set(CPACK_IFW_COMPONENT_GROUP_DIALOGS_PRIORITY 80)
  set(CPACK_IFW_COMPONENT_GROUP_DIALOGS_VERSION "3.4.1")

  set(CPACK_COMPONENT_CMAKE-GUI_DISPLAY_NAME "cmake-gui")
  set(CPACK_COMPONENT_CMAKE-GUI_GROUP Dialogs)
  set(CPACK_IFW_COMPONENT_CMAKE-GUI_NAME "QtGUI")
  set(CPACK_IFW_COMPONENT_CMAKE-GUI_SCRIPT
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Source/QtIFW/CMake.Dialogs.QtGUI.qs")
  set(CPACK_IFW_COMPONENT_CMAKE-GUI_VERSION "3.4.1")
  

  set(CPACK_COMPONENT_CCMAKE_DISPLAY_NAME "ccmake")
  set(CPACK_COMPONENT_CCMAKE_GROUP Dialogs)
  set(CPACK_IFW_COMPONENT_CCMAKE_NAME "CursesGUI")
  set(CPACK_IFW_COMPONENT_CCMAKE_VERSION "3.4.1")

  # Documentation
  set(CPACK_COMPONENT_GROUP_DOCUMENTATION_DISPLAY_NAME "Documentation")
  set(CPACK_COMPONENT_GROUP_DOCUMENTATION_DESCRIPTION
    "CMake Documentation in different formats (html, man, qch)")
  set(CPACK_COMPONENT_GROUP_DOCUMENTATION_PARENT_GROUP CMake)
  set(CPACK_IFW_COMPONENT_GROUP_DOCUMENTATION_PRIORITY 60)
  set(CPACK_IFW_COMPONENT_GROUP_DOCUMENTATION_VERSION
    "3.4.1")

  set(CPACK_COMPONENT_SPHINX-MAN_DISPLAY_NAME "man")
  set(CPACK_COMPONENT_SPHINX-MAN_GROUP Documentation)
  set(CPACK_COMPONENT_SPHINX-MAN_DISABLED TRUE)
  set(CPACK_IFW_COMPONENT_SPHINX-MAN_NAME "SphinxMan")
  set(CPACK_IFW_COMPONENT_SPHINX-MAN_VERSION "3.4.1")

  set(CPACK_COMPONENT_SPHINX-HTML_DISPLAY_NAME "HTML")
  set(CPACK_COMPONENT_SPHINX-HTML_GROUP Documentation)
  set(CPACK_IFW_COMPONENT_SPHINX-HTML_NAME "SphinxHTML")
  set(CPACK_IFW_COMPONENT_SPHINX-HTML_SCRIPT
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/CMake.Documentation.SphinxHTML.qs")
  set(CPACK_IFW_COMPONENT_SPHINX-HTML_VERSION "3.4.1")

  set(CPACK_COMPONENT_SPHINX-SINGLEHTML_DISPLAY_NAME "Single HTML")
  set(CPACK_COMPONENT_SPHINX-SINGLEHTML_GROUP Documentation)
  set(CPACK_COMPONENT_SPHINX-SINGLEHTML_DISABLED TRUE)
  set(CPACK_IFW_COMPONENT_SPHINX-SINGLEHTML_NAME "SphinxSingleHTML")
  set(CPACK_IFW_COMPONENT_SPHINX-SINGLEHTML_VERSION
    "3.4.1")

  set(CPACK_COMPONENT_SPHINX-QTHELP_DISPLAY_NAME "Qt Compressed Help")
  set(CPACK_COMPONENT_SPHINX-QTHELP_GROUP Documentation)
  set(CPACK_COMPONENT_SPHINX-QTHELP_DISABLED TRUE)
  set(CPACK_IFW_COMPONENT_SPHINX-QTHELP_NAME "SphinxQtHelp")
  set(CPACK_IFW_COMPONENT_SPHINX-QTHELP_VERSION "3.4.1")

endif()

if(CPACK_GENERATOR MATCHES "CygwinSource")
  # when packaging source make sure the .build directory is not included
    set(CPACK_SOURCE_IGNORE_FILES
      "/CVS/" "/\\.build/" "/\\.svn/" "\\.swp$" "\\.#" "/#" "~$")
endif()

if("${CPACK_GENERATOR}" STREQUAL "PackageMaker")
  if(CMAKE_PACKAGE_QTGUI)
    set(CPACK_PACKAGE_DEFAULT_LOCATION "/Applications")
  else()
    set(CPACK_PACKAGE_DEFAULT_LOCATION "/usr")
  endif()
endif()

if("${CPACK_GENERATOR}" STREQUAL "WIX")
  # Reset CPACK_PACKAGE_VERSION to deal with WiX restriction.
  # But the file names still use the full CMake_VERSION value:
  set(CPACK_PACKAGE_FILE_NAME
    "${CPACK_PACKAGE_NAME}-3.4.1-${CPACK_SYSTEM_NAME}")
  set(CPACK_SOURCE_PACKAGE_FILE_NAME
    "${CPACK_PACKAGE_NAME}-3.4.1-Source")

  if(NOT CPACK_WIX_SIZEOF_VOID_P)
    set(CPACK_WIX_SIZEOF_VOID_P "8")
  endif()

  set(CPACK_PACKAGE_VERSION
    "3.4")
  # WIX installers require at most a 4 component version number, where
  # each component is an integer between 0 and 65534 inclusive
  set(patch "1")
  if(patch MATCHES "^[0-9]+$" AND patch LESS 65535)
    set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}.${patch}")
  endif()

  set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "https://cmake.org")

  set(CPACK_WIX_PROPERTY_ARPCONTACT "cmake@cmake.org")

  set(CPACK_WIX_PROPERTY_ARPCOMMENTS
    "CMake is a cross-platform, open-source build system."
  )

  set(CPACK_WIX_PRODUCT_ICON
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Utilities/Release/CMakeLogo.ico"
  )

  set_property(INSTALL "doc/cmake-3.4/html/index.html" PROPERTY
    CPACK_START_MENU_SHORTCUTS "CMake Documentation"
  )

  set_property(INSTALL "cmake.org.html" PROPERTY
    CPACK_START_MENU_SHORTCUTS "CMake Web Site"
  )

  set(CPACK_WIX_LIGHT_EXTRA_FLAGS "-dcl:high")

  set(CPACK_WIX_UI_BANNER
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Utilities/Release/cpack_wix_ui_banner.jpg"
  )

  set(CPACK_WIX_UI_DIALOG
    "/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/cmake-3.4.1/Utilities/Release/cpack_wix_ui_dialog.jpg"
  )
endif()
