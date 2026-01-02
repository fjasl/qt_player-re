import QtQuick

Rectangle {
    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: parent.height * 0.5
    color: "transparent"
    Text {
        text: "List View"
        anchors.centerIn: parent
        font.pointSize: 24
        font.bold: true
        color: "white"
    }
}
