import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

// 新增：用于灵活布局
ApplicationWindow {
    id: root
    width: 640
    height: 300
    visible: true
    flags: Qt.FramelessWindowHint
    color: "transparent"
    Rectangle {
        width: parent.width
        height: parent.height
        radius: 24
        color: "#1FFFFFFF"
        Rectangle {
            id: contentArea
            anchors.fill: parent
            anchors.margins: parent.width * 0.025 // 2.5% 的 padding
            color: "transparent"
            Rectangle {
                width: parent.width
                height: parent.height
                anchors.fill: parent
                color: "transparent"
                RowLayout {
                    anchors.fill: parent
                    spacing: parent.width * 0.02 // 两个 gap 总共 4%，每个 2%
                    // 左侧 10%
                    RoundCornorContainer {
                        id: left_pane
                        radius: 16
                        color: "black"
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.10
                        // Layout.fillWidth: true + preferredWidth 也可以，但这里直接用比例更直观
                        LeftPaneContent {}
                    }

                    // 中间 88%
                    RoundCornorContainer {
                        id: right_pane
                        radius: 16
                        color: "black"
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.88 // 明确指定 88%
                    }
                }
            }
        }
    }
    // RoundCornorContainer {
    //     width: parent.width * 0.6
    //     height: parent.height * 0.6
    //     color: "red"
    //     radius: 20
    // }
    Item {
        anchors.fill: parent

        DragHandler {
            onActiveChanged: if (active)
                                 root.startSystemMove()
        }
    }

}
