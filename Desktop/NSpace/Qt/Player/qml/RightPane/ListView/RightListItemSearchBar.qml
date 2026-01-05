import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    signal trashBtnClick(int itemIndex)
    signal inputTextChanged(string text)
    property alias text:inputField.text
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
                source: "qrc:/icon/icons/awefont/list/magnifying-glass-solid.svg"
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 42
            TextField {
                id : inputField
                width: parent.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                // 水平靠左
                anchors.left: parent.left
                placeholderText: "search by name..."
                placeholderTextColor: "gray"
                color: "white"
                font.pixelSize: parent.height * 0.4
                background: Rectangle {
                        color: "transparent" // 背景透明
                        border.color: "transparent" // 彻底去除边框
                    }
                onTextChanged: root.inputTextChanged(text)
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
    SequentialAnimation {
        id: removeAnimation

        // 关键步骤：阻止立即销毁
        PropertyAction {
            target: root
            property: "ListView.delayRemove"
            value: true
        }

        // 执行动画
        NumberAnimation {
            target: root
            property: "x"
            to: -root.width
            duration: 300
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root
            property: "height"
            to: 0
            duration: 200
        }

        // 动画结束，允许销毁
        PropertyAction {
            target: root
            property: "ListView.delayRemove"
            value: false
        }
    }

    // 2. 信号处理器里通过脚本调用 start()
    ListView.onRemove: {
        removeAnimation.start()
    }
}
