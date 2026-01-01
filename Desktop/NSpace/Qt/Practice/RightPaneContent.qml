// RightArea.qml 或直接放在主文件中
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: rightArea
    width: parent.width
    height: parent.height * 4 // 总高度 400%
    color: "transparent"

    // 内容容器：用 Item 包裹四个页面，便于统一控制 y 位置动画
    Item {
        id: rightcontentContainer
        width: parent.width
        height: parent.height

        property int currentIndex: 0

        // 平滑滑动动画
        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack // 关键：弹性超调效果（超出一点再回弹）
                easing.overshoot: 1.7 // 可选：调节超调强度，默认 1.7，1.2 更柔和
            }
        }

        y: -currentIndex * (parent.height / 4)
        RightPlayerPage {}

        RightLyricPage {}

        RightListPage {}

        RightSettingPage {}
    }
    function switchTo(index) {
        if (index >= 0 && index <= 3) {
            rightcontentContainer.currentIndex = index
        }
    }
}
