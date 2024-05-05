import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls

BackgroundRectangle {
        ColumnLayout{
            id: settingsColumnLayout
            spacing: 10
            anchors.fill: parent

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                color: "transparent"
            }

            BackgroundRectangle {
                id: bgColorSetting
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width - myUI.margin * 2
                height: 70

                ColoredText {
                    anchors.fill: parent

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    text: qsTr("修改背景颜色(右击恢复默认)")

                    font.pointSize: parent.height / 4
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton) {
                            bgColorpicker.open()
                        } else {
                            root.realbg = "#4e000000"
                            bgColorSetting.save("#4e000000")
                        }
                    }
                }

                ColorDialog {
                    id: bgColorpicker
                    selectedColor: root.realbg
                    onAccepted: {
                        root.realbg = selectedColor
                        bgColorSetting.save(selectedColor.toString())
                    }
                }

                function save(newVal) {
                    storage.set("bgColor", newVal)
                }
            }

            BackgroundRectangle {
                id: textColorSetting
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width - myUI.margin * 2
                height: 70

                ColoredText {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("修改文字颜色(右击恢复默认)")
                    font.pointSize: parent.height / 4
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton) {
                            textColorpicker.open()
                        } else {
                            myUI.textColor = "#ffffffff"
                            textColorSetting.save("#ffffffff")
                        }
                    }
                }

                ColorDialog {
                    id: textColorpicker
                    selectedColor: myUI.textColor
                    onAccepted: {
                        myUI.textColor = selectedColor
                        textColorSetting.save(selectedColor.toString())
                    }
                }

                function save(newVal) {
                    storage.set("textColor", newVal)
                }
            }

            BackgroundRectangle {
                id: hideListSetting
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width - myUI.margin * 2
                height: 70

                ColoredText {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("显示列表")
                    font.pointSize: parent.height / 4
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: (mouse) => {
                        hideDialog.open()
                    }
                }

                Dialog {
                    id: hideDialog
                    width: root.width / 2
                    height: root.height / 2



                    BackgroundRectangle{
                        anchors.fill: parent

                        ColumnLayout {
                            Repeater {
                                model: myUI.alllists

                                CheckBox {
                                    text: qsTr(modelData.name)

                                    onCheckedChanged: {
                                        if(checked) {
                                            myUI.hideTabsID.delete(modelData.Id)
                                            storage.hideList().remove(modelData.Id)
                                        } else {
                                            myUI.hideTabsID.add(modelData.Id)
                                            storage.hideList().add(modelData.Id)
                                        }
                                        myUI.filterTabs()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            BackgroundRectangle {
                id: exitRect
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width - myUI.margin * 2
                height: 70
                color: "darkred"

                ColoredText {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("点此退出")
                    font.pointSize: parent.height / 4
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: (mouse) => {
                        Qt.quit()
                    }
                }
            }
        }
}


