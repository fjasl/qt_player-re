import QtQuick
import QtQuick.Effects

Item {
    id: root
    anchors.fill: parent
    anchors.margins: parent.width * 0.05

    // --- 暴露给外部的接口 ---
    property bool running: false // 控制开关
    property alias rotationAngle: rotationTransform.angle // 记录并导出当前角度
    property alias source: coverImage.source
    Connections {
        target: EventBus // 这里的 EventBus 是你在 C++ setContextProperty 注入的名称

        // 使用 Qt 6 推荐的 function 语法
        function onBackendEvent(event, payload) {
            if (event === "cover_request_reply") {
                console.log("即将载入图片")
                coverImage.source = payload.base64
                console.log("载入图片成功")
            }
        }
    }
    //旋转控制方法
    function toggleRotation() {
        running = !running
    }

    function startRotation() {
        running = true
    }

    function stopRotation() {
        running = false
    }

    // 1. 基础唱片容器
    // Rectangle {
    //     id: discoDisk
    //     anchors.centerIn: parent
    //     width: Math.min(parent.width, parent.height)
    //     height: width
    //     radius: width / 2

    //     // 旋转变换对象
    //     transform: Rotation {
    //         id: rotationTransform
    //         origin.x: discoDisk.width / 2
    //         origin.y: discoDisk.height / 2
    //         angle: 0
    //     }

    //     // 动画逻辑
    //     NumberAnimation {
    //         target: rotationTransform
    //         property: "angle"
    //         from: 0
    //         to: 360
    //         duration: 16000 // 8秒转一圈
    //         loops: Animation.Infinite
    //         running: root.running // 绑定外部开关
    //     }

    //     gradient: Gradient {
    //         GradientStop {
    //             position: 0.0
    //             color: "#1a1a1a"
    //         }
    //         GradientStop {
    //             position: 0.4
    //             color: "#0a0a0a"
    //         }
    //         GradientStop {
    //             position: 1.0
    //             color: "#121212"
    //         }
    //     }

    //     // 2. 封面图片
    //     Image {
    //         id: coverImage
    //         anchors.centerIn: parent
    //         width: parent.width * 0.75
    //         height: width
    //         source: "qrc:/icon/icons/awefont/gear-solid.svg"
    //         fillMode: Image.PreserveAspectCrop
    //         visible: true
    //     }

    //     // 3. 处理封面圆角
    //     MultiEffect {
    //         source: coverImage
    //         anchors.fill: coverImage
    //         maskEnabled: true
    //         maskSource: Rectangle {
    //             width: coverImage.width
    //             height: coverImage.height
    //             radius: width / 2
    //         }
    //     }

    // 4. 第一道高光 (固定在外部视角，不随唱片旋转)
    Item {
        anchors.fill: parent
        rotation: -25 - rotationTransform.angle // 减去旋转角，使高光相对屏幕静止
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
        rotation: 155 - rotationTransform.angle // 同理，抵消旋转
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

    Rectangle {
        id: discoDisk
        anchors.fill: parent
        width: Math.min(parent.width, parent.height)
        height: width
        radius: width
        color: "white"


            // 旋转变换对象
            transform: Rotation {
                id: rotationTransform
                origin.x: discoDisk.width / 2
                origin.y: discoDisk.height / 2
                angle: 0
            }

            // 动画逻辑
            NumberAnimation {
                target: rotationTransform
                property: "angle"
                from: 0
                to: 360
                duration: 16000 // 8秒转一圈
                loops: Animation.Infinite
                running: root.running // 绑定外部开关
            }


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
            anchors.margins: parent.width * 0.1
            RoundCornorContainer {
                width: Math.min(parent.width, parent.height)
                height: width
                radius: width
                color: "gray"
                Image {
                    id: coverImage
                    anchors.centerIn: parent
                    width: parent.width *(10/9)*(20/19)
                    height: width
                    source: "qrc:/icon/icons/awefont/gear-solid.svg"
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }
}
// 6. 唱片阴影 (MultiEffect 放在外部，防止阴影跟着转导致锯齿)
// MultiEffect {
//     source: discoDisk
//     anchors.fill: discoDisk
//     shadowEnabled: true
//     shadowColor: Qt.rgba(0, 0, 0, 0.7)
//     shadowBlur: 0.8
//     shadowVerticalOffset: 5
//     z: -1
// }

