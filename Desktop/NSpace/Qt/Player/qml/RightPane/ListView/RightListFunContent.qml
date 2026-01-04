import QtQuick
import QtQuick.Layouts

ColumnLayout{
    anchors.fill: parent
    spacing: parent.height * 0.05
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/folder-open-solid.svg"
    }
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/magnifying-glass-solid.svg"
    }
    RightListFunButton{
        source:"qrc:/icon/icons/awefont/list/location-crosshairs-solid.svg"
    }
    Item{
        Layout.fillHeight: true
    }
}
