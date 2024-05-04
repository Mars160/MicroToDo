import QtQuick
import QtQuick.LocalStorage


Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    flags: Qt.FramelessWindowHint | Qt.WA_TranslucentBackground


    property string realbg: "#4e000000"

    color: root.realbg

    property int bw: 3
    property bool loadFinished: false

    Storage{
        id: storage
    }

    Component.onCompleted: {
        let wx = storage.get("WindowX", 'n')
        let wy = storage.get("WindowY", 'n')
        let ww = storage.get("WindowWidth", 'n')
        let wh = storage.get("WindowHeight", 'n')

        if (wx !== null) root.x = wx
        if (wy !== null) root.y = wy
        if (ww !== null) root.width = ww
        if (wh !== null) root.height = wh

        loadFinished = true
    }

    onXChanged: {
        if(loadFinished)
            storage.set("WindowX", x)
    }

    onYChanged: {
        if(loadFinished)
        storage.set("WindowY", y)
    }

    onWidthChanged: {
        if(loadFinished)
        storage.set("WindowWidth", width)
    }

    onHeightChanged: {
        if(loadFinished)
        storage.set("WindowHeight", height)
    }


    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: {
            const p = Qt.point(mouseX, mouseY);
            const b = bw;
            if (p.x < b && p.y < b) return Qt.SizeFDiagCursor;
            if (p.x >= width - b && p.y >= height - b) return Qt.SizeFDiagCursor;
            if (p.x >= width - b && p.y < b) return Qt.SizeBDiagCursor;
            if (p.x < b && p.y >= height - b) return Qt.SizeBDiagCursor;
            if (p.x < b || p.x >= width - b) return Qt.SizeHorCursor;
            if (p.y < b || p.y >= height - b) return Qt.SizeVerCursor;
            return Qt.SizeAllCursor
        }
        acceptedButtons: Qt.NoButton // don't handle actual events
    }

    DragHandler {
            id: resizeHandler
            grabPermissions: TapHandler.TakeOverForbidden
            target: null
            onActiveChanged: if (active) {
                const p = resizeHandler.centroid.position;
                const b = bw;
                let e = 0;
                if (p.x < b) {
                    e |= Qt.LeftEdge
                    root.startSystemResize(e)
                }
                else if (p.x >= width - b) {
                    e |= Qt.RightEdge
                    root.startSystemResize(e)
                }
                else if (p.y < b) {
                    e |= Qt.TopEdge
                    root.startSystemResize(e)
                }
                else if (p.y >= height - b) {
                    e |= Qt.BottomEdge
                    root.startSystemResize(e)
                } else {
                    root.startSystemMove()
                }
            }
        }

    Auther{
        id: auther
    }

    UI {
        id: myUI
        color: myUI.bgColor
        width: parent.width - 50
        height: parent.height - 50

        anchors.centerIn: parent
    }
}
