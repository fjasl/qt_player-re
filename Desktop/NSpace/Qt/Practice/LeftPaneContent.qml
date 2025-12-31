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

            // 2. 业务组件
            // Rectangle {
            //     // 注意：使用 Layout.preferredWidth/Height 替代 width/height
            //     Layout.preferredWidth: parent.width * 0.5
            //     Layout.preferredHeight: parent.height * 0.125
            //     color: "transparent"
            //     Layout.alignment: Qt.AlignHCenter // 次轴(水平)居中
            //     Image {
            //         // 1. 让 Image 占据 Rectangle 的全部空间
            //         anchors.fill: parent

            //         // 2. 核心：必须设置 sourceSize，否则 SVG 不会自动适配大小
            //         // 将矢量渲染尺寸设置为父容器的大小
            //         sourceSize.width: parent.width
            //         sourceSize.height: parent.height

            //         // 3. 保持比例缩放，防止图标拉伸变形
            //         fillMode: Image.PreserveAspectFit

            //         // 4. 确保在 Image 内部也居中对齐
            //         horizontalAlignment: Image.AlignHCenter
            //         verticalAlignment: Image.AlignVCenter

            //         source: "svgIcons/light/play_white.svg"
            //     }
            // }
            LeftNavButton{
                source: "qrc:/icon/icons/light/play_white.svg"
            }

            // Rectangle {
            //     Layout.preferredWidth: parent.width * 0.5
            //     Layout.preferredHeight: parent.height * 0.125
            //     color: "transparent"
            //     Layout.alignment: Qt.AlignHCenter
            //     Image {
            //         // 1. 让 Image 占据 Rectangle 的全部空间
            //         anchors.fill: parent

            //         // 2. 核心：必须设置 sourceSize，否则 SVG 不会自动适配大小
            //         // 将矢量渲染尺寸设置为父容器的大小
            //         sourceSize.width: parent.width
            //         sourceSize.height: parent.height

            //         // 3. 保持比例缩放，防止图标拉伸变形
            //         fillMode: Image.PreserveAspectFit

            //         // 4. 确保在 Image 内部也居中对齐
            //         horizontalAlignment: Image.AlignHCenter
            //         verticalAlignment: Image.AlignVCenter

            //         source: "svgIcons/light/scroll-text_white.svg"
            //     }
            // }
            LeftNavButton{
                source: "qrc:/icon/icons/light/scroll-text_white.svg"
            }
            // Rectangle {
            //     Layout.preferredWidth: parent.width * 0.5
            //     Layout.preferredHeight: parent.height * 0.125
            //     color: "transparent"
            //     Layout.alignment: Qt.AlignHCenter
            //     Image {
            //         // 1. 让 Image 占据 Rectangle 的全部空间
            //         anchors.fill: parent

            //         // 2. 核心：必须设置 sourceSize，否则 SVG 不会自动适配大小
            //         // 将矢量渲染尺寸设置为父容器的大小
            //         sourceSize.width: parent.width
            //         sourceSize.height: parent.height

            //         // 3. 保持比例缩放，防止图标拉伸变形
            //         fillMode: Image.PreserveAspectFit

            //         // 4. 确保在 Image 内部也居中对齐
            //         horizontalAlignment: Image.AlignHCenter
            //         verticalAlignment: Image.AlignVCenter

            //         source: "svgIcons/light/list-music_white.svg"
            //     }
            // }
            LeftNavButton{
                            source: "qrc:/icon/icons/light/list-music_white.svg"
                        }
            // Rectangle {
            //     Layout.preferredWidth: parent.width * 0.5
            //     Layout.preferredHeight: parent.height * 0.125
            //     color: "transparent"
            //     Layout.alignment: Qt.AlignHCenter
            //     Image {
            //         // 1. 让 Image 占据 Rectangle 的全部空间
            //         anchors.fill: parent

            //         // 2. 核心：必须设置 sourceSize，否则 SVG 不会自动适配大小
            //         // 将矢量渲染尺寸设置为父容器的大小
            //         sourceSize.width: parent.width
            //         sourceSize.height: parent.height

            //         // 3. 保持比例缩放，防止图标拉伸变形
            //         fillMode: Image.PreserveAspectFit

            //         // 4. 确保在 Image 内部也居中对齐
            //         horizontalAlignment: Image.AlignHCenter
            //         verticalAlignment: Image.AlignVCenter

            //         source: "svgIcons/light/settings_white.svg"
            //     }
            // }
            LeftNavButton{
                            source: "qrc:/icon/icons/light/settings_white.svg"
                        }
            // 3. 底部占位符
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
