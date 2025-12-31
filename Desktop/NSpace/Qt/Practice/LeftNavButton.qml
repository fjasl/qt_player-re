import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property alias source: innerImage.source

    Layout.preferredWidth: parent.width * 0.5
    Layout.preferredHeight: parent.height * 0.125
    Layout.alignment: Qt.AlignHCenter
    color: "transparent"

    Image {
        id: innerImage
        anchors.fill: parent
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        // 缩放中心点设为图片中心
        transformOrigin: Item.Center

        // 动画过渡
        Behavior on scale {
            NumberAnimation {
                duration: 200        // 动画时长 200ms
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        // 悬停时缩小，离开时恢复
        onEntered: innerImage.scale = 0.8
        onExited: innerImage.scale = 1.0

        // 点击反馈（可选）
        onPressed: innerImage.scale = 0.7
        onReleased: innerImage.scale = mouseArea.containsMouse ? 0.8 : 1.0
    }
}
