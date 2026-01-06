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
            if (event === "lyric_index_changed") {
                console.log("歌词索引变动" + payload.index)
                scrollLyricContainer.currentIndex = payload.index
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
        id: container
        anchors.fill: parent
        anchors.topMargin: parent.width * 0.05
        anchors.bottomMargin: parent.width * 0.05
        clip: true
        Item {
            id: scrollLyricContainer
            width: parent.width

            property int currentIndex: 0

            Behavior on y {
                NumberAnimation {
                    duration: 100 // 平滑滚动通常建议在 200ms - 400ms 之间
                    easing.type: Easing.InOutQuad // 减速到终点，没有回弹，视觉最舒适
                }
            }

            y: getTargetY(currentIndex)
            function getTargetY(index) {
                // 1. 获取目标行对象 (Repeater 的第 index 个子项)
                var targetItem = lyricRepeater.itemAt(index)
                if (!targetItem)
                    return 0

                // 2. 计算理想偏移：视口高度的 40% 减去 目标行相对于布局顶部的 y 坐标
                // 逻辑：y = 视口基准线 - 目标在内容中的位置
                var viewportHeight = container.height
                var targetLineY = targetItem.y
                var desiredY = ((viewportHeight * 0.35)-viewportHeight*0.05) - targetLineY

                // 3. 边界限制 (Clamping)
                // 上边界：y 不能大于 0 (防止第一行下方留白)
                var topLimit = 0
                // 下边界：y 不能小于 (视口高度 - 内容总高度) (防止最后一行上方留白)
                // 如果内容总高度小于视口高度，则限制在 0
                var contentHeight = lyricLayout.height
                var bottomLimit = Math.min(0, (viewportHeight-viewportHeight*0.05) - contentHeight)

                return Math.max(bottomLimit, Math.min(topLimit, desiredY))
            }

            ColumnLayout {
                id: lyricLayout
                width: parent.width
                anchors.top: parent.top
                spacing: container.height * 0.1

                Repeater {
                    id: lyricRepeater
                    model: root.lyricArray

                    // 这里的 delegate 就是你要重复添加的内容
                    delegate: RightLyricLineContent {

                        text: modelData.text || ""
                        active: index === scrollLyricContainer.currentIndex
                    }
                }
            }
        }
    }
}
