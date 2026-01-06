import QtQuick
import QtQuick.Layouts

Item {
    // FontLoader {
    //            id: hanSanSCFont
    //            // 指向你的字体文件路径
    //            source: "qrc:/font/font/SourceHanSansSC-Bold.otf"
    //        }
    id:root
    property alias text: lyricText.text

    property bool active: false // 激活状态开关
    Layout.fillWidth: true
    height: lyricText.height
    Text {
        id: lyricText
        width: parent.width // 必须指定宽度，wrapMode 才会生效

        // 1. font-size: 20px
        font.pixelSize: root.active ? 25 : 20

        // 2. color: #a5a5a5
        color: root.active ? "#ffffff" : "#a5a5a5"
        //font.family: hanSanSCFont.name
        // 3. word-wrap: break-word & white-space: normal
        // WrapAnywhere 对应 break-word，允许在单词内部换行
        wrapMode: Text.WrapAnywhere

        // 4. text-align: center
        horizontalAlignment: Text.AlignHCenter

        // 5. pointer-events: none & user-select: none
        // QML Text 默认不支持选择。设置为 false 确保不响应鼠标
        enabled: false

        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 200
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        // 6. cursor: default
        // Text 默认不改变光标，除非在 MouseArea 中。
        // 设置为以下值可确保即使有交互也不改变形状
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
            acceptedButtons: Qt.NoButton // 确保穿透点击，对应 pointer-events: none
        }

        text: ""
    }
}
