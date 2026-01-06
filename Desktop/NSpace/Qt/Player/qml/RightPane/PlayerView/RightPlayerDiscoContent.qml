import QtQuick
import QtQuick.Effects

Item {
    id: root
    anchors.fill: parent
    anchors.margins: parent.width * 0.05

    // --- 暴露给外部的接口 ---
    property bool running: false // 控制开关
    property alias source: coverImage.source
    Connections {
        target: EventBus // 这里的 EventBus 是你在 C++ setContextProperty 注入的名称

        // 使用 Qt 6 推荐的 function 语法
        function onBackendEvent(event, payload) {
            if (event === "cover_request_reply") {
                coverImage.source = payload.base64
            }
        }
    }
    function startRotation() {
        frameAnim.start()
    }

    function stopRotation() {
        frameAnim.stop()
    }
    FrameAnimation {
        id: frameAnim
        onTriggered: {
            // frameTime 是两帧之间的时间间隔（秒）
            // 15 * frameTime 确保了每秒旋转 15 度，且不受掉帧影响
            discoDisk.rotation = (discoDisk.rotation + 15 * frameTime) % 360
        }
    }
    Rectangle {
        id: discoDisk
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        radius: width / 2
        color: "white"

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#1a1a1a"
            }
            GradientStop {
                position: 0.4
                color: "#0a0a0a"
            }
            GradientStop {
                position: 1.0
                color: "#121212"
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: parent.width * 0.125
            RoundCornorContainer {
                width: Math.min(parent.width, parent.height)
                height: width
                radius: width / 2
                color: "gray"
                Image {
                    id: coverImage
                    anchors.centerIn: parent
                    width: parent.width * (10 / 9) * (20 / 19)
                    height: width
                    // source: "qrc:/icon/icons/awefont/gear-solid.svg"
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }
    // 4. 第一道高光 (固定在外部视角，不随唱片旋转)
    Item {
        anchors.fill: parent
        //rotation: -25 - rotationTransform.angle // 减去旋转角，使高光相对屏幕静止
        rotation: -25
        opacity: 0.7

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0.25)
                }
                GradientStop {
                    position: 0.3
                    color: "transparent"
                }
            }
        }
    }

    // 5. 第二道高光 (固定在外部视角)
    Item {
        anchors.fill: parent
        //rotation: 155 - rotationTransform.angle // 同理，抵消旋转
        rotation: 155
        opacity: 0.6

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0.2)
                }
                GradientStop {
                    position: 0.3
                    color: "transparent"
                }
            }
        }
    }
}
