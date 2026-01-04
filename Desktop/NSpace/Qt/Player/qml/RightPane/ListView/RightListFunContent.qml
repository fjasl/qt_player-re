import QtQuick
import QtQuick.Layouts

ColumnLayout{
    id: root
    signal searchBtnClicked()
    anchors.fill: parent
    spacing: parent.height * 0.05
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/folder-open-solid.svg"
    }
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/magnifying-glass-solid.svg"
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.searchBtnClicked()
        }
    }
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/location-crosshairs-solid.svg"
    }
    Item{
        Layout.fillHeight: true
    }
}
