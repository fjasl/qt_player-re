import QtQuick
import QtQuick.Layouts

Item {
    width: parent.width
    height: parent.height * 0.25
    anchors.top: parent.top
    anchors.topMargin: parent.height * 0.5
    Item {
        anchors.fill: parent
        anchors.topMargin: parent.width * 0.05
        anchors.bottomMargin: parent.width * 0.05
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                RightListFunContent {
                    onSearchBtnClicked: {
                        listContent.toggleSearchBar()
                    }
                    onLocateBtnClicked: {
                        listContent.scrollToCurrent()
                    }
                    onOpenfileBtnClicked: {
                        Connector.dispatch("open_file", {})
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 9
                RightListListContent {
                    id: listContent
                }
            }
        }
    }
}
