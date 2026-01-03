import QtQuick
import QtQuick.Layouts

RowLayout {
    anchors.fill: parent
    spacing: 0
    RightPlayerWidgetFuncButton {
        source: "qrc:/icon/icons/awefont/player/heart-solid.svg"
    }
    Item {
        Layout.fillWidth: true
    }
    RightPlayerWidgetFuncButton {
        source: "qrc:/icon/icons/awefont/player/shuffle-solid.svg"
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
