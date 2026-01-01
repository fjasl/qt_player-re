import QtQuick

Rectangle {
    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: parent.height * 0.25
    color: "transparent"

    Text {
        text: "Lyric View"
        anchors.centerIn: parent
        font.pointSize: 24
        font.bold: true
        color: "white"
    }
}
