// LeftPaneContent.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

ColumnLayout {

    FontLoader {
        id: customFont
        // 指向你的字体文件路径
        source: "qrc:/font/font/segoesc.ttf"
    }

    // 关键：必须填满父级 Container
    anchors.fill: parent
    spacing: 0
    Rectangle {
        // 在 Layout 内部，建议使用 Layout 属性而非直接写 width/height
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.25
        color: "transparent"
        // Image {
        //         anchors.centerIn: parent
        //         width: parent.width
        //         height: parent.height
        //         source: "logo.svg"
        // }
        Text {
            anchors.centerIn: parent
            text: "yun"
            color: "white"
            font.pixelSize: 25
            font.family: customFont.name // 使用 FontLoader 加载的字体
            antialiasing: true
        }
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.75
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            // 间距为父容器高度的 10%
            spacing: parent.height * 0.1

            // 1. 顶部占位符：利用 Layout.fillHeight 平分剩余空间实现居中
            Item {
                Layout.fillHeight: true
            }

            LeftNavButton {
                source: "qrc:/icon/icons/awefont/play-solid.svg"
            }

            LeftNavButton {
                source: "qrc:/icon/icons/awefont/file-lines-solid.svg"
            }

            LeftNavButton {
                source: "qrc:/icon/icons/awefont/list-ul-solid.svg"
            }

            LeftNavButton {
                source: "qrc:/icon/icons/awefont/gear-solid.svg"
            }
            // 3. 底部占位符
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
