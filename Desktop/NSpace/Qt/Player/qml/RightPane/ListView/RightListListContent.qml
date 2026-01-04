import QtQuick
import QtQuick.Controls
import Qt.labs.qmlmodels

Item {
    id: root
    anchors.fill: parent
    // 必须确保这个容器填充父级布局分配的空间
    property int currentInt: -1
    property int activeInt: -1
    property bool isSearchBarOn: false
    property list<int> indexList: []

    function activeItem(index) {
        if (indexList.length === 0) {
            indexList.push(index)
            highLight(indexList[0])
        } else if (indexList.length === 1) {
            indexList.push(index)
            unHighLight(indexList[0])
            highLight(indexList[1])
        } else {
            indexList.push(index)
            indexList.splice(0, 1)
            unHighLight(indexList[0])
            highLight(indexList[1])
        }
    }
    function updateFromSearchBar() {
        if (root.isSearchBarOn) {
            var tempArrayP = [...indexList]

            // 2. 遍历自增
            for (var i = 0; i < tempArrayP.length; i++) {
                tempArrayP[i] += 1
            }

            // 3. 写回属性
            // 此时 tempArray 是一个新的对象引用，赋值必会触发信号
            indexList = tempArrayP
            currentInt += 1
        } else if (!root.isSearchBarOn) {
            var tempArrayD = [...indexList]

            // 2. 遍历自增
            for (var i = 0; i < tempArrayD.length; i++) {
                tempArrayD[i] -= 1
            }

            // 3. 写回属性
            // 此时 tempArray 是一个新的对象引用，赋值必会触发信号
            indexList = tempArrayD
            currentInt -= 1
        }
    }

    function highLight(index) {
        if (index < 0 || index >= listItem.count)
            return
        // 使用 setProperty 修改数据，ListView 会自动通知对应的 Delegate 更新
        listItem.setProperty(index, "onActive", true)
    }

    function unHighLight(index) {
        if (index < 0 || index >= listItem.count)
            return
        // 使用 setProperty 修改数据，ListView 会自动通知对应的 Delegate 更新
        listItem.setProperty(index, "onActive", false)
    }

    function toggleSearchBar() {

        // 1. 检查第一项是否是搜索框
        if (listItem.count > 0 && listItem.get(0).searchBar === true) {
            //console.log("搜索框已存在，执行移除...")
            for (var i = 0; i < visualModel.items.count; i++) {
                visualModel.items.get(i).inVisibleItems = true
            }
            listItem.remove(0) // 如果有，就移除它
            root.isSearchBarOn = false
            root.updateFromSearchBar()
        } else {
            //console.log("搜索框不存在，执行添加...")
            listItem.insert(0, {
                                "searchBar": true,
                                "name": "搜索框"
                            })
            // 滚动到顶部确保可见
            scrollableList.positionViewAtBeginning()
            //scrollableList.contentY = -scrollableList.height * 0.2
            root.isSearchBarOn = true
            root.updateFromSearchBar()
        }
    }

    function scrollToCurrent() {
        if (currentInt < 0 || currentInt >= listItem.count)
            return

        activeItem(currentInt)

        // 1. 获取基础参数
        var itemHeight = scrollableList.height * 0.2
        var viewHeight = scrollableList.height

        // 2. 检查内容是否填满一屏
        // 注意：contentHeight 建议在渲染帧更新后再读取，这里加上 originY 修正
        if (scrollableList.contentHeight <= viewHeight) {
            scrollableList.contentY = scrollableList.originY // 修正点：使用 originY
            return
        }

        // 3. 计算理想目标位置
        // targetY 应该是相对于 originY 的偏移量
        var targetY = scrollableList.originY + (currentInt * itemHeight)

        // 如果 SearchBar 开启，且它在原始模型索引 0 的位置（导致后面项下移）
        if (root.isSearchBarOn) {
            //targetY += itemHeight
        }

        // 4. 计算最大允许滚动值
        // maxScrollY 也必须基于 originY
        var maxScrollY = scrollableList.originY + Math.max(
                    0, scrollableList.contentHeight - viewHeight)

        // 5. 最终赋值
        // Math.max(scrollableList.originY, ...) 确保不会滚过头露出上方空白
        scrollableList.contentY = Math.max(scrollableList.originY,
                                           Math.min(targetY, maxScrollY))
    }

    function filterItems(searchText) {
        var term = searchText.toLowerCase()
        for (var i = 0; i < visualModel.items.count; i++) {
            var data = visualModel.items.get(i).model
            // 搜索框项始终可见
            if (data.searchBar === true) {
                visualModel.items.get(i).inVisibleItems = true
            } else {
                // 根据 name 字段过滤
                var isMatch = data.name.toLowerCase().indexOf(term) !== -1
                visualModel.items.get(i).inVisibleItems = isMatch
            }
        }
    }

    ListModel {
        id: listItem
        dynamicRoles: true
        Component.onCompleted: {
            for (var i = 0; i < 20; i++)
                append({
                           "searchBar": false,
                           "name": "项目 " + i,
                           "onActive": false,
                           "text": i
                       })
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
                    onTrashBtnClick: listItem.remove(index)
                    onItemClicked: {
                        root.activeItem(index)
                    }
                    onItemDoubleClicked: {
                        root.activeItem(index)
                        root.currentInt = index
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
