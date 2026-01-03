import QtQuick
import QtQuick.Effects

Item {
    id: root
    anchors.fill: parent
    anchors.margins: parent.width * 0.05

    // 1. 基础唱片容器
    Rectangle {
        id: discoDisk
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        radius: width / 2

        // 调整背景颜色：使用深灰到浅黑的过渡，避免死黑
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a1a" } // 中心稍亮
            GradientStop { position: 0.4; color: "#0a0a0a" }
            GradientStop { position: 1.0; color: "#121212" } // 边缘回升，增加立体感
        }

        // 2. 封面图片
        Image {
            id: coverImage
            anchors.centerIn: parent
            width: parent.width * 0.75
            height: width
            source: ""
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        // 3. 处理封面圆角
        MultiEffect {
            source: coverImage
            anchors.fill: coverImage
            maskEnabled: true
            maskSource: Rectangle {
                width: coverImage.width
                height: coverImage.height
                radius: width / 2
            }
        }

        // 4. 第一道高光 (左上)
        Item {
            anchors.fill: parent
            rotation: -25 // 稍微偏移角度
            opacity: 0.7  // 降低不透明度使过渡更自然

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 0
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.25) }
                    GradientStop { position: 0.3; color: "transparent" }
                }
            }
        }

        // 5. 第二道高光 (右下 - 对称)
        Item {
            anchors.fill: parent
            rotation: 155 // 对应 CSS rotate(160deg) 效果
            opacity: 0.6

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.2) }
                    GradientStop { position: 0.3; color: "transparent" }
                }
            }
        }

        // 6. 唱片阴影
        MultiEffect {
            source: discoDisk
            anchors.fill: discoDisk
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.7)
            shadowBlur: 0.8
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 5 // 增加纵向偏移，增强悬浮感
            z: -1
        }
    }
}
