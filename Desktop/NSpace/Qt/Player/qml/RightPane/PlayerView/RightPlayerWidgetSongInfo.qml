import QtQuick
import QtQuick.Layouts
ColumnLayout {

    property alias title: songTitle
    property alias artist: songArtist

    // FontLoader {
    //     id: hanSanSCFont
    //     // 指向你的字体文件路径
    //     source: "qrc:/font/font/SourceHanSansSC-Bold.otf"
    // }
    anchors.fill: parent
    spacing: 0
    Text {
        id: songTitle
        text: "This is title"
        color: "white"
        font.pixelSize: 20
        //font.family: hanSanSCFont.name
        antialiasing: true

        Layout.fillWidth: true // 让文本横向撑满布局
        // 左对齐
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight   // 关键！加上这行
    }

    Text {
        id: songArtist
        text: "Artist"
        color: "gray"
        font.pixelSize: 15
        //font.family: hanSanSCFont.name
        antialiasing: true

        Layout.fillWidth: true
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight   // 关键！加上这行
    }
}
