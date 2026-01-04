import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    signal trashBtnClick(int itemIndex)
    width: scrollableList.width
    height: scrollableList.height * 0.2
    color: "transparent"
    // 2. 缩放中心默认是中心
    scale: hoverArea.pressed ? 0.9 : (hoverArea.containsMouse ? 0.95 : 1.0)

    // 1. 定义动画状态：使用 MouseArea 检测悬停
    // 3. 动画：同时处理颜色和缩放
    Behavior on scale {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true // 必须开启
        onEntered: color = Qt.rgba(255, 255, 255, 0.2) // 悬停变色
        onExited: color = "transparent" // 离开恢复
        cursorShape: Qt.PointingHandCursor
    }
    // 上边框
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1 // 边框粗细
        color: Qt.rgba(255, 255, 255, 0.2) // 灰色，不透明
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 6
            RightListItemIcon {
                source: "qrc:/icon/icons/awefont/list/music-solid.svg"
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 32
            Text {
                text: "这里是一个演示"
                anchors.verticalCenter: parent.verticalCenter
                // 水平靠左
                anchors.left: parent.left
                font.pixelSize: parent.height * 0.4
                color: "white"
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 5
            RightListItemIcon {
                source: "qrc:/icon/icons/awefont/list/file-contract-solid.svg"
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 5
            RightListItemIcon {
                source: "qrc:/icon/icons/awefont/list/trash-solid.svg"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.trashBtnClick(index)
                }
            }
        }
    }
    // 下边框
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1 // 边框粗细
        color: Qt.rgba(255, 255, 255, 0.2) // 灰色，不透明
    }
    // 使用 ListView 附加属性监听移除动作
        ListView.onRemove: SequentialAnimation {
            // 1. 开启延迟移除，此时 ListView 不会立即回收此项
            PropertyAction { target: root; property: "ListView.delayRemove"; value: true }

            // 2. 执行你的滑出动画
            NumberAnimation { target: root; property: "x"; to: -root.width; duration: 300 }

            // 3. 【核心】让高度也变为 0，这样下方的项就会随高度变化平滑上移
            NumberAnimation { target: root; property: "height"; to: 0; duration: 200 }

            // 4. 关闭延迟移除，此时该项才会被真正销毁
            PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
        }
}
