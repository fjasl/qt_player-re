import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    signal clicked()
    property alias source: innerImage.source
    property alias  overlaycolor:castOverlay.color
    property bool overlayvisible: false

    Layout.preferredWidth:  parent.width*0.5
    Layout.preferredHeight: parent.height*0.125
    Layout.alignment: Qt.AlignHCenter

    Image {
        id: innerImage
        anchors.fill: parent
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter


        layer.enabled: true
        layer.smooth: true
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

    Rectangle {
        id: castOverlay
        anchors.fill: innerImage

        opacity: root.overlayvisible ? 1.0 : 0.0
        Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
            }
        // 关键：把 layer.effect 放在这里！
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: innerImage // 使用 innerImage 的 alpha + 当前 scale
        }

        // 跟随 innerImage 的 scale 动画（自动继承）
        scale: innerImage.scale
        visible:opacity>0
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
