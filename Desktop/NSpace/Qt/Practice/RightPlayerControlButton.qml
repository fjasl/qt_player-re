import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    property alias source: innerImage.source

    Layout.alignment: Qt.AlignHCenter
    //Layout.alignment: Qt.AlignVCenter
    Image {
        id: innerImage
        anchors.fill: parent
        sourceSize.width: parent.width * 0.8
        sourceSize.height: parent.height * 0.8
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        transformOrigin: Item.Center

        // 动画过渡
        Behavior on scale {
            NumberAnimation {
                duration: 200 // 动画时长 200ms
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // 悬停时缩小，离开时恢复
        onEntered: innerImage.scale = 0.8
        onExited: innerImage.scale = 1.0

        // 点击反馈（可选）
        onPressed: innerImage.scale = 0.7
        onReleased: innerImage.scale = mouseArea.containsMouse ? 0.8 : 1.0

        // onClicked: {
        //     root.overlayvisible = !root.overlayvisible
        // }
        onClicked: root.clicked()
    }
}
