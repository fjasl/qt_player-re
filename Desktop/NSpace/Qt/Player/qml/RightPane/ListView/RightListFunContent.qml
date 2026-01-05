import QtQuick
import QtQuick.Layouts

ColumnLayout{
    id: root
    signal searchBtnClicked()
    signal locateBtnClicked()
    signal openfileBtnClicked()
    anchors.fill: parent
    spacing: parent.height * 0.05
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/folder-open-solid.svg"
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openfileBtnClicked()
        }
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
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.locateBtnClicked()
        }
    }
    Item{
        Layout.fillHeight: true
    }
}
