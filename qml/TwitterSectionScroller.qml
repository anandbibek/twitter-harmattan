import QtQuick 1.1
import com.nokia.meego 1.0
import "TwitterSectionScroller.js" as Sections

Item {
    id: root

    property ListView listView

    onListViewChanged: {
        if (listView && listView.model) {
            internal.initDirtyObserver();
        } else if (listView) {
            listView.modelChanged.connect(function() {
                if (listView.model) {
                    internal.initDirtyObserver();
                }
            });
        }
    }

    Item {
        id: container
        property bool dragging: false

        width: 64
        height: listView.height
        y: listView.y
        x: listView.x + listView.width - width

        Rectangle {
            id: scrollBackground
            anchors.fill: parent
            color: "#000000"
            opacity: 0
        }

        MouseArea {
            id: dragArea
            objectName: "dragArea"
            anchors.fill: parent
            drag.axis: Drag.YAxis
            drag.minimumY: listView.y
            drag.maximumY: listView.y + listView.height - tooltip.height

            onPressed: {
                mouseDownTimer.restart()
            }

            onReleased: {
                container.dragging = false;
                drag.target = undefined;
                mouseDownTimer.stop()
            }

            onPositionChanged: {
                if (container.dragging) {
                    internal.adjustContentPosition(dragArea.mouseY);
                }
            }

            Timer {
                id: mouseDownTimer
                interval: 150

                onTriggered: {
                    container.dragging = true;
                    internal.adjustContentPosition(dragArea.mouseY);
                    tooltip.positionAtY(dragArea.mouseY);
                    dragArea.drag.target = tooltip;
                }
            }
        }
        Image {
            id: horizontalIndicator
            source: "image://theme/meegotouch-fast-scroll-handle"
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(0, (listView.visibleArea.yPosition / (1 - listView.visibleArea.heightRatio)) * (listView.height - horizontalIndicator.height))
            visible: container.dragging ? false : true
            opacity: 0
        }
        Item {
            id: tooltip
            objectName: "popup"
            anchors.right: parent.right
            width: listView.width
            height: 178

            function positionAtY(yCoord) {
                tooltip.y = Math.max(dragArea.drag.minimumY, Math.min(yCoord - tooltip.height/2, dragArea.drag.maximumY));
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: container.dragging && root.listView.model.count > 0 ? 0.8 : 0
            }

            Text {
                id: currentSectionLabel
                objectName: "currentSectionLabel"

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                font.pixelSize: 48
                wrapMode: Text.WordWrap
                color: "#FFFFFF"
                text: internal.curSect
                visible: container.dragging && root.listView.model.count > 0 ? true : false
            }

            states: [
                State {
                    name: "visible"
                    when: container.dragging
                }
            ]

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }

    Timer {
        id: dirtyTimer
        interval: 100
        running: false
        onTriggered: {
            Sections.initSectionData(listView);
            internal.modelDirty = false;
        }
    }

    Connections {
        target: root.listView
        onCurrentSectionChanged: internal.curSect = container.dragging ? internal.curSect : ""
    }


    states: State {
        name: "visible"
        when: (root.listView.moving || container.dragging) && root.listView.model.count > 0 ? true : false
        PropertyChanges {
            target: horizontalIndicator
            opacity: 1
        }
        PropertyChanges {
            target: scrollBackground
            opacity: 0.2
        }
    }

    transitions: [
        Transition {
            from: "*"; to: "visible"
            NumberAnimation {
                properties: "opacity"
                duration: 300
                easing.type: Easing.InOutExpo
            }
        },
        Transition {
            from: "visible"; to: "*"
            NumberAnimation {
                properties: "opacity"
                duration: 700
                easing.type: Easing.InOutExpo
            }
        }
    ]

    QtObject {
        id: internal

        property string curSect: ""
        property bool modelDirty: false

        function initDirtyObserver() {
            Sections.initialize(listView);
            function dirtyObserver() {
                if (!internal.modelDirty) {
                    internal.modelDirty = true;
                    dirtyTimer.running = true;
                }
            }

            if (listView.model.countChanged)
                listView.model.countChanged.connect(dirtyObserver);

            if (listView.model.itemsChanged)
                listView.model.itemsChanged.connect(dirtyObserver);

            if (listView.model.itemsInserted)
                listView.model.itemsInserted.connect(dirtyObserver);

            if (listView.model.itemsMoved)
                listView.model.itemsMoved.connect(dirtyObserver);

            if (listView.model.itemsRemoved)
                listView.model.itemsRemoved.connect(dirtyObserver);
        }

        function adjustContentPosition(y) {
            if (y < 0 || y > dragArea.height) return;

            var sect = Sections.getClosestSection((y / dragArea.height));
            if (sect != undefined && internal.curSect != sect) {
                internal.curSect = sect;
                var idx = Sections.getIndexFor(sect);
                listView.positionViewAtIndex(idx, ListView.Beginning);
            }
        }

    }
}
