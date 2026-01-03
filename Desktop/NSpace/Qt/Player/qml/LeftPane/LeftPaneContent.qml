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
    Item {
        // 在 Layout 内部，建议使用 Layout 属性而非直接写 width/height
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.25
        Text {
            anchors.centerIn: parent
            text: "yun"
            color: "white"
            font.pixelSize: 25
            font.family: customFont.name // 使用 FontLoader 加载的字体
            antialiasing: true
        }
    }
    Item {
        id: leftFunContainer

        property color activeColor: "#00ced1"
        property int currentActiveIndex: 0
        property var navButtons: [btnPlay, btnLyric, btnList, btnSetting]

        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.75

        Item {
            anchors.fill: parent

            DragHandler {}
        }

        ColumnLayout {
            anchors.fill: parent
            // 间距为父容器高度的 10%
            spacing: parent.height * 0.1

            // 1. 顶部占位符：利用 Layout.fillHeight 平分剩余空间实现居中
            Item {
                Layout.fillHeight: true
            }

            LeftNavButton {
                id: btnPlay
                source: "qrc:/icon/icons/awefont/play-solid.svg"
                overlaycolor: leftFunContainer.activeColor
                onClicked: leftFunContainer.activateButton(0)

            }

            LeftNavButton {
                id: btnLyric
                source: "qrc:/icon/icons/awefont/file-lines-solid.svg"
                overlaycolor: leftFunContainer.activeColor
                onClicked: leftFunContainer.activateButton(1)
            }

            LeftNavButton {
                id: btnList
                source: "qrc:/icon/icons/awefont/list-ul-solid.svg"
                overlaycolor: leftFunContainer.activeColor
                onClicked: leftFunContainer.activateButton(2)
            }

            LeftNavButton {
                id: btnSetting
                source: "qrc:/icon/icons/awefont/gear-solid.svg"
                overlaycolor: leftFunContainer.activeColor
                onClicked: leftFunContainer.activateButton(3)
            }
            // 3. 底部占位符
            Item {
                Layout.fillHeight: true
            }
        }
        // 统一激活逻辑函数
        function activateButton(index) {
            // 设置当前激活索引
            currentActiveIndex = index

            // 遍历所有按钮，只激活对应的那个
            for (var i = 0; i < navButtons.length; i++) {
                navButtons[i].overlayvisible = (i === index)
            }

            // 可选：在这里发出信号通知外部页面切换
            // root.pageChanged(index);
            rightContent.switchTo(index)
        }

        // 初始化时激活默认项
        Component.onCompleted: {
            activateButton(currentActiveIndex)
        }
    }
}
