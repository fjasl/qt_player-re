import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    spacing: 0
    property alias track: progressBarTrack
    property alias fill: progressBarFill
    property alias positioner: position
    property alias durationer: duration

    RoundCornorContainer {
        id: progressBarTrack
        color: "#14FFFFFF"
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.preferredHeight: 3
        radius: height / 2
        Rectangle {
            id: progressBarFill
            color: "white"
            width: parent.width / 2
            //radius: parent.height / 2
            height: parent.height
        }
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.preferredHeight: 10
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Text {
                id: position
                text: "00:00"
                color: "gray"
                font.pixelSize: 15
                //font.family: hanSanSCFont.name
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft // RowLayout 子项对齐
            }
            Text {
                id: duration
                text: "00:00"
                color: "gray"
                font.pixelSize: 15
                //font.family: hanSanSCFont.name
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignRight // RowLayout 子项对齐
            }
        }
    }
}
