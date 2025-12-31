cmake_minimum_required(VERSION 3.16)

project(Practice VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)
qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appPractice
    main.cpp
)

qt_add_qml_module(appPractice
    URI Practice
    QML_FILES
        Main.qml
        QML_FILES RoundCornorContainer.qml
        QML_FILES LeftPaneContent.qml
        RESOURCES font/segoesc.ttf
        RESOURCES svgIcons/light/list/file-music_white.svg svgIcons/light/list/locate-fixed_white.svg svgIcons/light/list/music-2_white.svg svgIcons/light/list/music_white.svg svgIcons/light/list/search_white.svg svgIcons/light/player/chevron-left_white.svg svgIcons/light/player/heart_white.svg svgIcons/light/player/pause_white.svg svgIcons/light/player/play_white.svg svgIcons/light/player/skip-back_white.svg svgIcons/light/player/skip-forward_white.svg svgIcons/light/player/volume-1_white.svg svgIcons/light/player/volume-2_white.svg svgIcons/light/player/volume-x_white.svg svgIcons/light/player/volume_white.svg svgIcons/light/setting/blocks_white.svg svgIcons/light/setting/book_white.svg svgIcons/light/setting/info_white.svg svgIcons/light/setting/message-square-warning_white.svg svgIcons/light/setting/wrench_white.svg svgIcons/light/list-music_white.svg svgIcons/light/play_white.svg svgIcons/light/scroll-text_white.svg svgIcons/light/settings_white.svg
        RESOURCES res.qrc
       )

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appPractice PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appPractice
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appPractice
    PRIVATE Qt6::Quick
    Qt6::Widgets
    Qt6::LabsPlatformplugin
)

include(GNUInstallDirs)
install(TARGETS appPractice
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
