import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    anchors.fill: parent
    //property alias mode:modeIcon.source
    signal switchModeBtnClick
    spacing: 0

    Connections {
        target: EventBus
        function onBackendEvent(event, payload) {
            if (event === "mode_switched") {
                if (payload.play_mode === "single_loop") {
                    modeIcon.source = "qrc:/icon/icons/awefont/player/repeat-solid.svg"
                } else if (payload.play_mode === "shuffle") {
                    modeIcon.source = "qrc:/icon/icons/awefont/player/shuffle-solid.svg"
                }
            }
        }
    }
    RightPlayerWidgetFuncButton {
        source: "qrc:/icon/icons/awefont/player/heart-solid.svg"
    }
    Item {
        Layout.fillWidth: true
    }
    RightPlayerWidgetFuncButton {
        id: modeIcon
        source: "qrc:/icon/icons/awefont/player/shuffle-solid.svg"
        MouseArea {
            anchors.fill: parent
            onClicked: root.switchModeBtnClick()
        }
    }
    Item {
        Layout.fillWidth: true
    }
    RightPlayerWidgetFuncButton {
        source: "qrc:/icon/icons/awefont/file-lines-solid.svg"
    }
    Item {
        Layout.fillWidth: true
    }
    RightPlayerWidgetFuncButton {
        source: "qrc:/icon/icons/awefont/player/volume-low-solid.svg"
    }
}
