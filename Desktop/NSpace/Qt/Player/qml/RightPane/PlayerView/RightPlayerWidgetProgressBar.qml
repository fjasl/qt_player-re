import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    // FontLoader {
    //        id: hanSanSCFont
    //        // 指向你的字体文件路径
    //        source: "qrc:/font/font/SourceHanSansSC-Bold.otf"
    //    }
    anchors.fill: parent
    spacing: 0
    signal seekRequested(real percent)
    property alias track: progressBarTrack
    property alias fill: progressBarFill
    property alias positioner: position
    property alias durationer: duration

    RoundCornorContainer {
        id: progressBarTrack
        //color: barMouseArea.containsMouse ? "#25FFFFFF" : "#14FFFFFF"
        // color: "#14FFFFFF"
        color: barMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1,1,1, 0.08)

        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.preferredHeight: 3
        radius: height / 2

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
        Rectangle {
            id: progressBarFill
            color: "white"
            width: 0
            //radius: parent.height / 2
            height: parent.height

            // 重点：为宽度添加动画行为，实现“平滑滑动”
            Behavior on width {

                NumberAnimation {
                    duration: 300 // 动画时间
                    easing.type: Easing.OutQuad // 减速运动，效果更自然
                }
            }
        }

        MouseArea {
            id:barMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                           // 计算点击位置占总宽度的比例 (0.0 ~ 1.0)
                           let percent = Math.max(0, Math.min(1,
                                                              mouse.x / width))
                           // 触发自定义信号
                           seekRequested(percent)
                       }
        }
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.preferredHeight: 10
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Text {
                id: position
                text: "00:00"
                color: "gray"
                font.pixelSize: 15
                //font.family: hanSanSCFont.name
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft // RowLayout 子项对齐
            }
             Item { Layout.fillWidth: true } // 占位符，将两个时间挤向两边
            Text {
                id: duration
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
