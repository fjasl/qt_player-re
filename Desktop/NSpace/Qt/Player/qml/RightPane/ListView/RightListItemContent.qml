import QtQuick

Item {
    width: scrollableList.width
    height: scrollableList.height * 0.2

    // 上边框
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1 // 边框粗细
        color: Qt.rgba(255, 255, 255, 0.2) // 灰色，不透明
    }

    // 下边框
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1 // 边框粗细
        color: Qt.rgba(255, 255, 255, 0.2) // 灰色，不透明
    }
}
