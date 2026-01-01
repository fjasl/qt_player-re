import QtQuick
import QtQuick.Layouts

Item {
    FontLoader {
        id: hanSanSCFont
        // 指向你的字体文件路径
        source: "qrc:/font/font/segoesc.ttf"
    }
    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: 0
    Item {
        id: rightPlayerPageContainer
        width: parent.width
        height: parent.height
        anchors.fill: parent
        anchors.topMargin: parent.width * 0.05
        anchors.bottomMargin: parent.width * 0.05
        Item {
            width: parent.width
            height: parent.height
            anchors.fill: parent
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    ColumnLayout {
                        anchors.fill: parent
                        // 间距为父容器高度的 10%
                        spacing: parent.height * 0.05
                        RightNavButton {
                            source: "qrc:/icon/icons/awefont/player/chevron-left-solid.svg"
                        }
                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 5
                    ColumnLayout {
                        anchors.fill: parent
                        // 间距为父容器高度的 10%
                        spacing: parent.height * 0.1
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                Text {
                                    text: "This is title"
                                    color: "white"
                                    font.pixelSize: 20
                                    //font.family: hanSanSCFont.name
                                    antialiasing: true

                                    Layout.fillWidth: true // 让文本横向撑满布局
                                    // 左对齐
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Text {
                                    text: "Artist"
                                    color: "gray"
                                    font.pixelSize: 15
                                    //font.family: hanSanSCFont.name
                                    antialiasing: true

                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                RightPlayerWidgetFuncButton {
                                    source: "qrc:/icon/icons/awefont/player/heart-solid.svg"
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                RightPlayerWidgetFuncButton {
                                    source: "qrc:/icon/icons/awefont/player/shuffle-solid.svg"
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                RightPlayerWidgetFuncButton {
                                    source: "qrc:/icon/icons/awefont/file-lines-solid.svg"
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                RightPlayerWidgetFuncButton {
                                    source: "qrc:/icon/icons/awefont/player/volume-low-solid.svg"
                                }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    id: progressBarTrack
                                    color: "#14FFFFFF"
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 2
                                    radius: height / 2
                                    Rectangle {
                                        id: progressBarFill
                                        color: "white"
                                        width: parent.width / 2
                                        radius: parent.height / 2
                                        height: parent.height
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 7
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0
                                        Text {
                                            text: "00:00"
                                            color: "gray"
                                            font.pixelSize: 15
                                            //font.family: hanSanSCFont.name
                                            horizontalAlignment: Text.AlignLeft
                                            Layout.alignment: Qt.AlignLeft // RowLayout 子项对齐
                                        }
                                        Text {
                                            text: "00:00"
                                            color: "gray"
                                            font.pixelSize: 15
                                            //font.family: hanSanSCFont.name
                                            horizontalAlignment: Text.AlignRight
                                            Layout.alignment: Qt.AlignRight // RowLayout 子项对齐
                                        }
                                    }
                                }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RowLayout {
                                anchors.fill: parent
                                spacing: parent.height
                                RightPlayerControlButton {
                                    Layout.preferredWidth: parent.width * 0.05
                                    Layout.preferredHeight: parent.height * 0.8
                                    source: "qrc:/icon/icons/awefont/player/backward-step-solid.svg"
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                RightPlayerControlButton {
                                    Layout.preferredWidth: parent.width * 0.2
                                    Layout.preferredHeight: parent.height * 0.8
                                    source: "qrc:/icon/icons/awefont/play-solid.svg"
                                }
                                Item {
                                    Layout.fillWidth: true
                                }

                                RightPlayerControlButton {
                                    Layout.preferredWidth: parent.width * 0.05
                                    Layout.preferredHeight: parent.height * 0.8
                                    source: "qrc:/icon/icons/awefont/player/forward-step-solid.svg"
                                }
                            }
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 4
                }
            }
        }
    }
}
