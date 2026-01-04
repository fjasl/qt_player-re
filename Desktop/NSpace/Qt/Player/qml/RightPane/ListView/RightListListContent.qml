import QtQuick
import QtQuick.Controls
import Qt.labs.qmlmodels

Item {
    id: root
    // 必须确保这个容器填充父级布局分配的空间
    anchors.fill: parent

    function toggleSearchBar() {
        // 1. 检查第一项是否是搜索框
        if (listItem.count > 0 && listItem.get(0).searchBar === true) {
            console.log("搜索框已存在，执行移除...")
            listItem.remove(0) // 如果有，就移除它
        } else {
            console.log("搜索框不存在，执行添加...")
            listItem.insert(0, {
                                "searchBar": true,
                                "name": "搜索框"
                            })
            // 滚动到顶部确保可见
            scrollableList.positionViewAtBeginning()
        }
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
                           "name": "项目 " + i
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
                    onTrashBtnClick: listItem.remove(index)
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

        // delegate: DelegateChooser {
        //     id: chooser
        //     role: "searchBar" // 检查模型中的 searchBar 属性

        //     // 选项 1：搜索框 (当 searchBar == true 时)
        //     DelegateChoice {
        //         roleValue: true
        //         delegate: RightListItemSearchBar {// 可以在这里添加 searchBar 的特有逻辑
        //         }
        //     }

        //     // 选项 2：普通项 (默认项，不设置 roleValue)
        //     DelegateChoice {
        //         roleValue: false
        //         // 不写 roleValue 意味着它是 fallback（保底选项）
        //         delegate: RightListItemContent {
        //             // 这里可以直接使用 index
        //             onTrashBtnClick: {
        //                 console.log("正在移除索引:", index)
        //                 listItem.remove(index)
        //             }
        //         }
        //     }
        // }

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
    }
}
