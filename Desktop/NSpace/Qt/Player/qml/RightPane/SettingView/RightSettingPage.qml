import QtQuick

Rectangle {
    // FontLoader {
    //            id: hanSanSCFont
    //            // 指向你的字体文件路径
    //            source: "qrc:/font/font/SourceHanSansSC-Normal.otf"
    //        }
    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: parent.height * 0.75
    color: "transparent"

    Text {
        text: "Setting View"
        //font.family: hanSanSCFont.name
        anchors.centerIn: parent
        font.pointSize: 24
        font.bold: true
        color: "white"
    }
}
