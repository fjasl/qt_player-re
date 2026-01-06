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

    Connections {
        target: EventBus // 这里的 EventBus 是你在 C++ setContextProperty 注入的名称

        // 使用 Qt 6 推荐的 function 语法
        function onBackendEvent(event, payload) {
            if (event === "current_track") {
                if (payload.current_track) {
                    var track = payload.current_track

                    if (track.path) {
                        let formattedPath = track.path
                        if (!formattedPath.startsWith("file:///")) {
                            formattedPath = "file:///" + formattedPath
                        }
                        root.audioSource = formattedPath
                        if (track.position > 0) {
                            player.targetStartPosition = track.position
                        } else {
                            player.targetStartPosition = 0
                        }
                    }
                }
            }
            if (event === "player_state_changed") {
                if (payload.is_playing) {
                    player.play()
                } else if (!payload.is_playing) {
                    player.pause()
                }
            }
            if (event === "seek_handled") {
                if (payload.target_position !== undefined) {
                    // 真正执行 MediaPlayer 的跳转
                    player.position = payload.target_position;
                }
            }
        }
    }

    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: 0

    property url audioSource: ""

    MediaPlayer {
        id: player

        source: root.audioSource // 绑定外部传入的音频路径
        audioOutput: AudioOutput {} // Qt6 必须有这一行，否则无声！
        property real targetStartPosition: 0

        onMediaStatusChanged: {
            // 情况 A: 媒体加载或缓冲完成 (用于恢复进度)
               if (mediaStatus === MediaPlayer.LoadedMedia || mediaStatus === MediaPlayer.BufferedMedia) {
                   if (targetStartPosition > 0 && seekable) {
                       console.log("2026 恢复位置成功:", targetStartPosition);
                       player.position = targetStartPosition;
                       targetStartPosition = 0;
                   }
               }
               // 情况 B: 播放自然结束
               else if (mediaStatus === MediaPlayer.EndOfMedia) {
                   console.log("检测到播放结束，准备切换下一首...");

                   // 触发下一首逻辑 (通过 Connector 发送指令给 C++ 处理列表循环)
                   Connector.dispatch("play_next", {});
               }
            }
        // 音量 0.0 ~ 1.0
        onPlaybackStateChanged: {
            if (player.playbackState === MediaPlayer.PlayingState) {
                controlContent.playBtn.source = "qrc:/icon/icons/awefont/player/pause-solid.svg"
                discoCover.startRotation()
            } else {
                controlContent.playBtn.source = "qrc:/icon/icons/awefont/play-solid.svg"
                discoCover.stopRotation()
            }
        }
        onPositionChanged: {

            if (player.duration > 0) {
                progressBar.fill.width = progressBar.track.width
                        * (player.position / player.duration)
                progressBar.positioner.text = Qt.formatTime(
                            new Date(player.position), "mm:ss")
                progressBar.durationer.text = Qt.formatTime(
                            new Date(player.duration), "mm:ss")
                Connector.dispatch("position_report", {
                                       "position": player.position
                                   })
            }
        }
        onMetaDataChanged: {
            // console.log("所有可用键:", player.metaData.keys())
            // for (var i = 0; i < player.metaData.keys().length; ++i) {
            //     var key = player.metaData.keys()[i]
            //     console.log(key, ":", player.metaData.value(key))
            // }
            songInfo.title.text = player.metaData.value(
                        root.metaData_Title) || "未知标题"
            songInfo.artist.text = player.metaData.value(
                        root.metaData_ContributingArtist)[0] || "未知艺术家"
            if (player.metaData.value(root.metaData_CoverArtImage)) {
                Connector.dispatch("cover_request", {
                                       "image": player.metaData.value(
                                                    root.metaData_CoverArtImage)
                                   })
            }
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
                    RightPlayerFunContent {}
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
                            RightPlayerWidgetSongInfo {
                                id: songInfo
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RightPlayerWidgetFunContent {
                                 onSwitchModeBtnClick:{
                                     Connector.dispatch("switch_mode", {})
                                 }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RightPlayerWidgetProgressBar {
                                id: progressBar
                                onSeekRequested: percent => {
                                                     // if (player.duration > 0) {
                                                     //     // 跳转播放器进度：总时长 * 比例
                                                     //     player.position = player.duration * percent
                                                     // }
                                                     Connector.dispatch("seek", {percent:percent})
                                                 }
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            RightPlayerWidgetControlContent {
                                id: controlContent
                                onPlayBtnOnClick: {
                                    Connector.dispatch("play_toggle", {})
                                }
                                onPrevBtnOnClick: {
                                    Connector.dispatch("play_prev", {})
                                }
                                onNextBtnOnClick: {
                                    Connector.dispatch("play_next", {});
                                }
                            }
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 4
                    RightPlayerDiscoContent {
                        id: discoCover
                    }
                }
            }
        }
    }
    Component.onCompleted: {

        // Windows 本地路径写法（注意用正斜杠 / ，或者双反斜杠 \\）
        //root.audioSource = "file:///D:/Resource/Music/风错过雨.mp3"

        // 或者这样写也行（Qt 会自动处理）
        // player.source = "file:D:/Resource/Music/aliez.mp3"
        //player.play() // 自动开始播放，方便你立刻听到声音测试
    }
}
