cmake_minimum_required(VERSION 3.16)

project(MicroTODO VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_PREFIX_PATH "C:/Qt/6.7.0/mingw_64")

set(CMAKE_PREFIX_PATH ${QT_PREFIX_PATH}/lib/cmake)

MESSAGE( STATUS "this var key = ${CMAKE_BUILD_TYPE}.")
if (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick HttpServer Gui Widgets)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appMicroTODO
    main.cpp
)

qt_add_qml_module(appMicroTODO
    URI MicroTODO
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES
        QML_FILES Auther.qml
        SOURCES authserver.h authserver.cpp
        QML_FILES Storage.qml
        QML_FILES http.js
        QML_FILES UI.qml
        QML_FILES Settings.qml
        QML_FILES
        QML_FILES BackgroundRectangle.qml
        QML_FILES ColoredText.qml
        QML_FILES ToDoList.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMicroTODO PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMicroTODO
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMicroTODO
    PRIVATE Qt6::Quick Qt6::HttpServer Qt6::Gui Qt6::Widgets
)

include(GNUInstallDirs)

# 添加include目录
target_include_directories(appMicroTODO
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${QT_PREFIX_PATH}/include/QtGui
)

install(TARGETS appMicroTODO
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
