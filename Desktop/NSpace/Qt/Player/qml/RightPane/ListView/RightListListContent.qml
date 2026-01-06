import QtQuick
import QtQuick.Controls
import Qt.labs.qmlmodels

Item {
    id: root
    anchors.fill: parent
    // 必须确保这个容器填充父级布局分配的空间
    property Item searchBar: null

    property int currentPlayingListIndex: -1
    property int activeInt: -1
    property int lastActiveIndex: -1
    property bool isSearchBarOn: false
    property var currentVisualItems: []

    Connections {
        target: EventBus // 这里的 EventBus 是你在 C++ setContextProperty 注入的名称

        // 使用 Qt 6 推荐的 function 语法
        function onBackendEvent(event, payload) {
            if (event === "playlist_changed") {
                root.reloadList(payload.playlist)
            }
            if (event === "current_track") {
                if (payload.current_track) {
                    var track = payload.current_track

                    if (track.index >= 0 && track.index < listItem.count) {
                        root.currentPlayingListIndex = track.index
                        console.log(" 获得播放索引 index:" + root.currentPlayingListIndex)
                        activeVisualItem(root.currentPlayingListIndex)
                    }
                }
            }
        }
    }

    function activeVisualItem(vIndex) {

        var currentVisualItem = visualModel.items.get(vIndex)
        if (!currentVisualItem) {
            return
        }

        var sourceIndex = currentVisualItem.model.index

        // 取消旧高亮
        if (root.lastActiveIndex !== -1) {
            unHighLightItem(root.lastActiveIndex)
        }

        // 新高亮
        highLightItem(sourceIndex)

        root.lastActiveIndex = sourceIndex
    }

    function highLightItem(listIndex) {
        listItem.setProperty(listIndex, "onActive", true)
    }

    function unHighLightItem(listIndex) {
        listItem.setProperty(listIndex, "onActive", false)
    }

    function toggleSearchBar() {
        var loader = scrollableList.headerItem.children[0]

        if (root.isSearchBarOn) {
            root.isSearchBarOn = false
            if (root.searchBar) {
                root.searchBar.text = ""
            }
        } else if (!root.isSearchBarOn) {
            root.isSearchBarOn = true
        }
    }

    function scrollToCurrent() {
        if (root.currentPlayingListIndex !== -1) {
            root.scrollToIndex(root.currentPlayingListIndex)
        }
    }


    /**
     * 滚动到指定索引
     * @param {int} sourceIdx - 原始数据模型中的索引 (ListItem 的索引)
     */
    function scrollToIndex(sourceIdx) {
        if (sourceIdx < 0 || sourceIdx >= listItem.count)
            return

        var visualIdx = -1
        if (root.isSearchBarOn && root.currentVisualItems.length > 0) {
            // 搜索模式：只在当前可见的 sourceIndex 数组里找位置
            for (var i = 0; i < root.currentVisualItems.length; ++i) {
                if (root.currentVisualItems[i] === sourceIdx) {
                    visualIdx = i
                    break
                }
            }
        } else {
            // 非搜索模式：所有项都可见，直接遍历 visualModel.items
            for (var i = 0; i < visualModel.items.count; ++i) {
                if (visualModel.items.get(i).model.index === sourceIdx) {
                    visualIdx = i
                    break
                }
            }
        }

        if (visualIdx === -1) {
            return
        }
        scrollableList.positionViewAtIndex(visualIdx, ListView.Contain)
        activeVisualItem(sourceIdx)
    }

    function filterItems(searchText) {
        root.currentVisualItems = []
        var term = searchText.toLowerCase()
        for (var i = 0; i < visualModel.items.count; i++) {
            var data = visualModel.items.get(i).model
            var isMatch = data.name.toLowerCase().indexOf(term) !== -1
            visualModel.items.get(i).inVisibleItems = isMatch
            if (isMatch) {
                root.currentVisualItems.push(visualModel.items.get(
                                                 i).model.index)
            }
        }
    }

    function reloadList(tracks) {
        // 1. 先清空现有模型
        listItem.clear()

        // 2. 安全检查
        if (!tracks || tracks.length === 0) {
            console.log("reloadList: tracks is empty or null")
            return
        }

        // 3. 遍历并填充新数据
        for (var i = 0; i < tracks.length; ++i) {
            var track = tracks[i]

            // 必须有 path，否则跳过该项
            if (!track.hasOwnProperty("path") || track["path"] === "") {
                console.warn("reloadList: track at index", i,
                             "has no valid path, skipping")
                continue
            }

            // 从路径中提取文件名（不包含扩展名或包含，根据需求调整）
            var fullPath = track["path"]
            var fileName = fullPath.split('/').pop(
                        ) // 取出最后一部分：01. Hello World.mp3
            var nameWithoutExt = fileName.replace(/\.[^.]+$/,
                                                  "") // 去掉扩展名：01. Hello World

            listItem.append({
                                "searchBar": false,
                                "name": nameWithoutExt,
                                "text"// 显示在列表中的标题（推荐去掉扩展名）
                                : nameWithoutExt,
                                "onActive"// 原始文件名（保留扩展名，便于调试或其他用途）
                                : false
                            })
        }

        console.log("reloadList: successfully loaded", listItem.count, "tracks")

        // 可选：加载完成后自动滚动到顶部或当前播放项
        scrollableList.positionViewAtBeginning()
    }

    ListModel {
        id: listItem
        dynamicRoles: true
        Component.onCompleted: {

        }
    }

    // 2. 视觉代理模型（负责过滤）
    DelegateModel {
        id: visualModel
        model: listItem

        filterOnGroup: "visibleItems" // 只显示属于此组的项

        groups: [
            DelegateModelGroup {
                id: visibleItemsGroup
                name: "visibleItems"
                includeByDefault: true // 初始全部加入此组
            }
        ]

        delegate: DelegateChooser {
            role: "searchBar"
            DelegateChoice {
                roleValue: true
                // 转发搜索文字变化信号
                delegate: RightListItemSearchBar {
                    onInputTextChanged: text => root.filterItems(text)
                }
            }
            DelegateChoice {
                roleValue: false

                delegate: RightListItemContent {
                    // 注意：在 DelegateModel 中删除需要使用原模型索引
                    text: model.text
                    onactive: model.onActive
                    onTrashBtnClick: {
                        //listItem.remove(index)
                        Connector.dispatch("list_track_del", {
                                               "index": index
                                           })
                    }
                    onItemClicked: {
                        //root.activeItem(index)
                        root.activeVisualItem(index)
                    }
                    onItemDoubleClicked: {
                        //root.activeItem(index)
                        root.activeVisualItem(index)
                        Connector.dispatch("list_track_play", {
                                               "index": index
                                           })
                    }
                }
            }
        }
    }

    ListView {
        id: scrollableList // 必须定义 ID 供 delegate 引用
        anchors.fill: parent
        clip: true

        // 关键点 1：必须有数据模型
        model: visualModel

        header: Item {
            // 使用一个容器包裹 Loader
            width: parent.width
            height: headerLoader.height // 容器高度同步 Loader 高度

            Loader {
                id: headerLoader
                width: parent.width
                // 关键：动画作用于此
                height: root.isSearchBarOn ? 45 : 0
                clip: true

                // 移除 visible: height > 0，改用 opacity 或直接靠 clip
                opacity: height > 0 ? 1 : 0

                Behavior on height {
                    NumberAnimation {
                        id: headerAnimation
                        duration: 200
                        easing.type: Easing.InOutQuad
                        onRunningChanged: {
                            if (!headerAnimation.running
                                    && root.isSearchBarOn) {
                                // 确保 header 完全可见
                                scrollableList.positionViewAtBeginning()
                            }
                        }
                    }
                }

                sourceComponent: RightListItemSearchBar {
                    id: searchBar
                    width: headerLoader.width
                    onInputTextChanged: text => root.filterItems(text)
                }
                onLoaded: {
                    root.searchBar = headerLoader.item
                }
            }
        }

        // 确保设置
        headerPositioning: ListView.PullBackHeader

        // 选配：设置滚动条（QtQuick.Controls 模块提供）
        ScrollBar.vertical: ScrollBar {
            id: vBar
            active: false // 设置为 true 则始终显示，false 则滚动时才显示
            policy: ScrollBar.AsNeeded

            // 1. 自定义滑块（移动的那个部分）
            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 100
                radius: 5
                // 正常状态灰色，鼠标悬停时变深
                color: vBar.hovered ? "#999999" : "#666666"
                // 增加透明度渐变动画
                opacity: vBar.active ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            // 2. 自定义轨道（滑块背后的背景）
            background: Rectangle {
                implicitWidth: 6
                color: "black" // 通常背景设为透明更好看
            }
        }

        add: Transition {
            NumberAnimation {
                property: "x"
                from: scrollableList.width // 从右侧开始
                to: 0
                duration: 400
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 400
            }
        }
        remove: Transition {
            NumberAnimation {
                property: "x"
                to: -scrollableList.width // 向左滑出
                duration: 300
            }
        }
        Behavior on contentY {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }
}
