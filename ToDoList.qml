import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BackgroundRectangle {
    property string taskListID: ""
    property var tasks: []

    property string title: ""

    property string key: "taskList-" + taskListID

    Timer {
        id: refreshTimer
    }

    function refresher() {
        console.log("refreshing list:", title)
        auther.getTasks(
            taskListID,
            (resp) => {
                let json = JSON.parse(resp)
                let newTask = []
                json["value"].forEach((val) => {
                    if(val.status !== "completed")
                        newTask.push({
                            "name": val.title,
                            "Id": val.id
                        })
                })
                tasks = newTask
            }
        )

        storage.task().set(tasks, taskListID)
    }

    Component.onCompleted: {
        let val = storage.task().get(taskListID, true)
        if (val !== null) {
            tasks = val
        }

        refreshTimer.interval = 10000
        refreshTimer.triggeredOnStart = true
        refreshTimer.repeat = true
        refreshTimer.triggered.connect(refresher)
        refreshTimer.start()
    }

    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent

            Repeater {
                model: tasks

                BackgroundRectangle {
                    id: thisTasks
                    Layout.fillWidth: true
                    height: 70

                    ColoredText {
                        text: "➡️\t" + modelData.name
                        anchors.fill: parent

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft

                        font.pointSize: parent.height / 4

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                thisTasks.visible = false
                                auther.updateTask(
                                    taskListID,
                                    modelData.Id,
                                    {
                                        "status": "completed"
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
