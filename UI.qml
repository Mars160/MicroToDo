import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Rectangle {
    property int margin: 10
    property var alllists: []
    property var tabs: []

    property var hideTabsID: null

    property var bgColor: Qt.rgba(0, 0, 0, 0)
    property var textColor: Qt.rgba(1, 1, 1, 1)

    Timer {
        id: syncTimer
    }

    TabBar {
        id: bar
        width: parent.width
        height: 50
        position: TabBar.Header
        anchors.bottom: view.top

        property int curIndex: 0

        background: Rectangle {
            anchors.fill: parent
            color: myUI.bgColor
        }


        Repeater {
            id: tabbtns
            model: tabs

            TabButton {
                text: modelData.name
                font.bold: false
                font.pointSize: bar.height / 3

                palette.buttonText: textColor

                background: Rectangle {
                    anchors.fill: parent
                    color: myUI.bgColor
                }

                onClicked: {
                    view.currentIndex = bar.currentIndex
                    if(bar.curIndex === tabbtns.count) {
                        settingbtn.font.bold = false
                    } else {
                        tabbtns.itemAt(bar.curIndex).font.bold = false
                    }
                    font.bold = true
                    bar.curIndex = bar.currentIndex
                    storage.set("currTabIndex", bar.currentIndex)
                }
            }
        }

        TabButton {
            id: settingbtn
            text: qsTr("设置")
            font.bold: false
            font.pointSize: bar.height / 3

            palette.buttonText: textColor

            background: Rectangle {
                anchors.fill: parent
                color: myUI.bgColor
            }

            onClicked: {
                view.currentIndex = bar.currentIndex
                if(bar.curIndex > tabbtns.count) {
                    settingbtn.font.bold = false
                } else {
                    tabbtns.itemAt(bar.curIndex).font.bold = false
                }
                font.bold = true
                bar.curIndex = bar.currentIndex
            }
        }
    }

    function refreshTabs(init = false) {
        if(init) {
            let oldTabs = storage.get("tabs")
            let oldTabsJson = JSON.parse(oldTabs)
            tabs = oldTabsJson
            console.log("tabs", oldTabs)
            return
        }

        let newTabs = []
        let count = -1

        auther.getLists((resp) => {
            let json = JSON.parse(resp)
            json.value.forEach((item) => {
                count += 1
                let selected = item.displayName === bar.currentItem.text
                newTabs.push({
                    "name": item.displayName,
                    "Id": item.id,
                })
                if(selected) {
                    bar.curIndex = count
                }
            })
            alllists = newTabs
            storage.set("list", JSON.stringify(newTabs))
            filterTabs()
        })
    }

    function filterTabs(tabid = null) {
        if(tabid === null) {
            let newTabs = []
            let oldTabs = storage.get("tabs")
            alllists.forEach((val) => {
                if (!hideTabsID.has(val.Id)) {
                    newTabs.push(val)
                }
            })

            let newTabsStr = JSON.stringify(newTabs)
            if(oldTabs !== newTabsStr) {
                tabs = newTabs
                storage.set("tabs", newTabsStr)
            }
        }
    }

    Component.onCompleted: {
        let first = storage.get("refreshToken") !== null ? false : true
        if(first) {
            firstDialog.visible = true
            storage.set("bgColor", "#00000000")
            storage.set("textColor", "#ffffffff")
        } else {
            let hids = storage.get("hideTabsID", "o")
            if(hids !== null) {
                myUI.hideTabsID = new Set(hids)
            }

            refreshTabs(true)
            let bg = storage.get("bgColor")
            let tc = storage.get("textColor")

            if (bg !== null) root.realbg = bg
            if (tc !== null) textColor = tc

            let lists = storage.get("list", "o")
            if (lists !== null) alllists = lists

            syncTimer.interval = 10000;
            syncTimer.triggered.connect(refreshTabs)
            syncTimer.repeat = true
            syncTimer.start()

            let barCurIndex = storage.get("currTabIndex", "n")
            if (barCurIndex !== null) {
                bar.currentIndex = barCurIndex
                view.currentIndex = barCurIndex
            }
        }
    }

    MessageDialog {
        id: firstDialog
        title: qsTr("授权窗口")
        text: qsTr("似乎是您第一次使用本软件？需要授权才能使用。")
        buttons: MessageDialog.Ok | MessageDialog.Cancel
        onButtonClicked: (btn, role) => {
            switch(btn) {
            case MessageDialog.Ok:
                auther.auth()
                syncTimer.interval = 5000;
                syncTimer.triggered.connect(refreshTabs)
                syncTimer.repeat = true
                syncTimer.start()
                break;
            case MessageDialog.Cancel:
            default:
                Qt.quit();
                break;
            }
        }
    }

    StackLayout {
        id: view
        currentIndex: 0
        //anchors.fill: parent
        width: bar.width
        height: parent.height - bar.height
        anchors.bottom: parent.bottom

        Repeater {
            model: tabs

            ToDoList {
                Layout.fillHeight: true
                Layout.fillWidth: true
                //Layout.maximumWidth: bar.width
                taskListID: modelData.Id
                title: modelData.name
            }
        }

        Settings {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
