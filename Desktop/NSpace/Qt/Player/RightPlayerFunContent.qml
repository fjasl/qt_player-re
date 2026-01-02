import QtQuick.Layouts
import QtQuick

ColumnLayout {
    anchors.fill: parent
    // 间距为父容器高度的 10%
    spacing: parent.height * 0.05
    RightPlayerFunButton {
        source: "qrc:/icon/icons/awefont/player/chevron-left-solid.svg"
    }
    Item {
        Layout.fillHeight: true
    }
}
