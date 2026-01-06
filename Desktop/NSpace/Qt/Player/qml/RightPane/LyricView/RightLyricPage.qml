import QtQuick
import QtQuick.Layouts

Item {
    id: root
    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: parent.height * 0.25
    Connections {
        target: EventBus
        function onBackendEvent(event, payload) {
            if (event === "lyric_changed") {
                if (payload.lyriclist !== undefined) {

                    root.lyricArray = payload.lyriclist
                }
            }
            if(event ==="lyric_index_changed"){
                console.log("歌词索引变动"+ payload.index)
                // root.scrollToLyric(payload.index)
            }
        }
    }


    // 1. 定义接收歌词数组的属性
    property var lyricArray: []

    // 2. 增加一个方法来更新数组（外部调用此方法）
    function updateLyrics(newLyrics) {
        lyricArray = newLyrics
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: parent.width * 0.05
        anchors.bottomMargin: parent.width * 0.05
        clip:true
        ColumnLayout {
            width: parent.width
            anchors.top: parent.top
            spacing:parent.height*0.1

            Repeater {
                model: root.lyricArray

                // 这里的 delegate 就是你要重复添加的内容
                delegate: RightLyricLineContent {

                    text: modelData.text || ""
                }
            }
        }
    }
}
