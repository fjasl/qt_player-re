import QtQuick
import QtQuick.Layouts
import QtMultimedia

Item {
    id: root
    FontLoader {
        id: hanSanSCFont
        // 指向你的字体文件路径
        source: "qrc:/font/font/segoesc.ttf"
    }

    property int metaData_Title: 0
    property int metaData_ContributingArtist: 20
    property int metaData_AlbumArtist: 9 // 备用
    property int metaData_AlbumTitle: 1
    property int metaData_CoverArtImage: 24
    property int metaData_TrackNumber: 12

    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: 0

    property url audioSource: ""

    MediaPlayer {
        id: player

        source: root.audioSource // 绑定外部传入的音频路径
        audioOutput: AudioOutput {} // Qt6 必须有这一行，否则无声！
        // 音量 0.0 ~ 1.0
        onPlaybackStateChanged: {
            if (player.playbackState === MediaPlayer.PlayingState) {
                controlContent.playBtn.source = "qrc:/icon/icons/awefont/player/pause-solid.svg"
            } else {
                controlContent.playBtn.source = "qrc:/icon/icons/awefont/play-solid.svg"
            }
        }
        onPositionChanged: {

            if (player.duration > 0) {
                progressBar.fill.width = progressBar.track.width * (player.position / player.duration)
                progressBar.positioner.text = Qt.formatTime(new Date(player.position),
                                              "mm:ss")
                progressBar.durationer.text = Qt.formatTime(new Date(player.duration),
                                              "mm:ss")
            }
        }
        onMetaDataChanged: {
            // console.log("所有可用键:", player.metaData.keys())
            // for (var i = 0; i < player.metaData.keys().length; ++i) {
            //     var key = player.metaData.keys()[i]
            //     console.log(key, ":", player.metaData.value(key))
            // }
            songInfo.title.text = player.metaData.value(root.metaData_Title) || "未知标题"
            songInfo.artist.text = player.metaData.value(root.metaData_ContributingArtist)[0]
                    || "未知艺术家"
        }
    }

    Item {
        id: rightPlayerPageContainer
        width: parent.width
        height: parent.height
        anchors.fill: parent
        anchors.topMargin: parent.width * 0.05
        anchors.bottomMargin: parent.width * 0.05
        Item {
            width: parent.width
            height: parent.height
            anchors.fill: parent
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    RightPlayerFunContent{
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 5
                    ColumnLayout {
                        anchors.fill: parent
                        // 间距为父容器高度的 10%
                        spacing: parent.height * 0.1
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RightPlayerWidgetSongInfo{
                                id: songInfo
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RightPlayerWidgetFunContent{

                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RightPlayerWidgetProgressBar{
                                id: progressBar
                                onSeekRequested: (percent) => {
                                        if (player.duration > 0) {
                                            // 跳转播放器进度：总时长 * 比例
                                            player.position = player.duration * percent
                                        }

                                    }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                           RightPlayerWidgetControlContent{
                               id:controlContent
                               onPlayBtnOnClick:  {
                                   console.log("播放按钮被点击！")
                                   if (player.playbackState === MediaPlayer.PlayingState) {
                                       player.pause()
                                   } else {
                                       player.play()
                                   }
                               }
                           }
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 4
                }
            }
        }
    }
    Component.onCompleted: {
        // Windows 本地路径写法（注意用正斜杠 / ，或者双反斜杠 \\）
        root.audioSource = "file:///D:/Resource/Music/风错过雨.mp3"

        // 或者这样写也行（Qt 会自动处理）
        // player.source = "file:D:/Resource/Music/aliez.mp3"
        //player.play() // 自动开始播放，方便你立刻听到声音测试
    }
}
