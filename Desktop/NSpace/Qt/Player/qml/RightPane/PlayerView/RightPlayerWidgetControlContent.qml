import QtQuick
import QtQuick.Layouts

RowLayout {
    id:root

    property alias playBtn: playButton
    signal playBtnOnClick();
    property alias prevBtn: prevButton
    signal prevBtnOnClick();
    property alias nextBtn: nextButton
    signal nextBtnOnClick();


    Connections {
           target: EventBus // 这里的 EventBus 是你在 C++ setContextProperty 注入的名称

           // 使用 Qt 6 推荐的 function 语法
           function onBackendEvent(event, payload) {
               if (event === "test") {
                   console.log("prev clicked 这里是响应")
               }
           }
       }


    anchors.fill: parent
    spacing: parent.height
    RightPlayerControlButton {
        id: prevButton
        Layout.preferredWidth: parent.width * 0.05
        Layout.preferredHeight: parent.height * 0.8
        source: "qrc:/icon/icons/awefont/player/backward-step-solid.svg"
        onClicked: root.prevBtnOnClick()
    }
    Item {
        Layout.fillWidth: true
    }
    RightPlayerControlButton {

        id: playButton
        Layout.preferredWidth: parent.width * 0.2
        Layout.preferredHeight: parent.height * 0.8
        source: "qrc:/icon/icons/awefont/play-solid.svg"
        // onClicked: {
        //     console.log("播放按钮被点击！")
        //     if (player.playbackState === MediaPlayer.PlayingState) {
        //         player.pause()
        //     } else {
        //         player.play()
        //     }
        // }
        onClicked: root.playBtnOnClick()
        Component.onCompleted: {
            console.log("BTN size:", width, height)
        }
    }
    Item {
        Layout.fillWidth: true
    }

    RightPlayerControlButton {
        id: nextButton
        Layout.preferredWidth: parent.width * 0.05
        Layout.preferredHeight: parent.height * 0.8
        source: "qrc:/icon/icons/awefont/player/forward-step-solid.svg"
        onClicked: root.nextBtnOnClick()
    }
}
