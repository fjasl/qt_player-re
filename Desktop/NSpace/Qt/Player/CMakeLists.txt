cmake_minimum_required(VERSION 3.16)

project(Practice VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
set(TagLib_DIR "C:/Users/27576/Desktop/tmp/taglib_output/lib/cmake/taglib")
find_package(TagLib REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Quick Widgets QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appPractice
    main.cpp
)




# source_group("Source Files/LeftPane" FILES ${LEFT_PANE_FILES})
# source_group("Source Files/RightPane" FILES ${RIGHT_PANE_FILES})
# source_group("Source Files/Other" FILES ${OTHER_QML_FILES})

qt_add_qml_module(appPractice
    URI Practice
        QML_FILES
        Main.qml
         RESOURCES res.qrc
         QML_FILES
         qml/LeftPane/LeftNavButton.qml
         qml/LeftPane/LeftPaneContent.qml
         qml/Other/RoundCornorContainer.qml
         qml/RightPane/PlayerView/RightPaneContent.qml
         qml/RightPane/PlayerView/RightPlayerControlButton.qml
         qml/RightPane/PlayerView/RightPlayerFunButton.qml
         qml/RightPane/PlayerView/RightPlayerFunContent.qml
         qml/RightPane/PlayerView/RightPlayerPage.qml
         qml/RightPane/PlayerView/RightPlayerWidgetControlContent.qml
         qml/RightPane/PlayerView/RightPlayerWidgetFuncButton.qml
         qml/RightPane/PlayerView/RightPlayerWidgetFunContent.qml
         qml/RightPane/PlayerView/RightPlayerWidgetProgressBar.qml
         qml/RightPane/PlayerView/RightPlayerWidgetSongInfo.qml
         QML_FILES qml/RightPane/PlayerView/RightPlayerDiscoContent.qml
         qml/RightPane/ListView/RightListFunButton.qml
         qml/RightPane/ListView/RightListFunContent.qml
         qml/RightPane/ListView/RightListItemContent.qml
         qml/RightPane/ListView/RightListItemIcon.qml
         qml/RightPane/ListView/RightListItemSearchBar.qml
         qml/RightPane/ListView/RightListListContent.qml
         qml/RightPane/ListView/RightListPage.qml
         qml/RightPane/LyricView/RightLyricPage.qml
         qml/RightPane/LyricView/RightLyricLineContent.qml
         qml/RightPane/SettingView/RightSettingPage.qml
         SOURCES cpp/Services/PlayerServices.cpp
         SOURCES cpp/Services/Connector.h
         SOURCES cpp/Services/EventBus.h
         SOURCES cpp/Services/LogicManager.h
         SOURCES cpp/Services/PlayerModule.cpp
         SOURCES cpp/Services/AppLogic.cpp
         SOURCES cpp/Services/PlayerModule.h

         SOURCES cpp/Services/Storage.h
         SOURCES cpp/Services/Storage.cpp
         SOURCES cpp/Services/StoreState.h
         SOURCES cpp/Services/StoreState.cpp
         SOURCES cpp/Services/LifeStageModule.h
         SOURCES cpp/Services/LifeStageModule.cpp
         SOURCES cpp/Services/extractMetaData.h
         SOURCES cpp/Services/extractMetaData.cpp
         SOURCES cpp/Services/LrcParser.h
         SOURCES cpp/Services/LrcParser.cpp
         SOURCES cpp/Services/LyricModule.cpp
         SOURCES cpp/Services/LyricModule.h

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
    Qt6::QuickControls2
    Qt6::LabsPlatformplugin
    TagLib::TagLib
)

target_include_directories(appPractice PRIVATE
    cpp/Services
    # 如果还有其他目录，继续加
)

include(GNUInstallDirs)
install(TARGETS appPractice
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

