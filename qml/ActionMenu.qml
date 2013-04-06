import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: root

    property alias contentArea: content_area.children

    Rectangle {
        id: fade
        color: "black"
        opacity: 0

        z: content_area.z - 1

        anchors.fill: parent
    }

    platformStyle: SheetStyle{
        acceptButtonRightMargin: 0
        rejectButtonLeftMargin: 0

        background: ""
        headerBackground: ""

        headerBackgroundMarginLeft: 0
        headerBackgroundMarginRight: 0
        headerBackgroundMarginTop: 0
        headerBackgroundMarginBottom: 0
    }

    content: Item {
        height: parent.height
        width: parent.width

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.close();
            }
        }

        BorderImage {
            id: content_area

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: childrenRect.height + 32

            border.left: 19
            border.top: 0
            border.right: 19
            border.bottom: 19

            source: "../images/twitter-object-menu-background.png"
        }

        MouseArea {
            anchors.fill: content_area
            z: content_area.z - 1
        }

        states: [
            State {
                name: "shown"
                when: ((root.status == DialogStatus.Open) || (root.status == DialogStatus.Opening))
                PropertyChanges {
                    target: fade
                    opacity: 0.8
                }
            }
        ]
        transitions: [
            Transition {
                from: "*"
                to: "*"
                PropertyAnimation {
                    target: fade
                    properties: "opacity"
                    duration: 500
                    easing.type: Easing.InOutExpo
                }
            }
        ]
    }
}
