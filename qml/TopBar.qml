import QtQuick 1.1
import com.nokia.meego 1.0

TopPane {
    id: root

    property bool composeButton: true
    property bool composeTweet: true

    property bool editButton: false

    signal composeClicked
    signal editClicked
    signal doubleClicked

    MouseArea {
        anchors.fill: parent
        onClicked: root.doubleClicked();
    }

    Image {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        source: "../images/twitter-icon-logo"+(logo_area.containsMouse ? "-pressed" : "")+".png"
        MouseArea {
            id: logo_area
            anchors.fill: parent
            onClicked: {
                window.homePage();
            }
        }
    }

    BusyIndicator {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        platformStyle: BusyIndicatorStyle {
            size: "medium"
            inverted: true
        }
        running: visible
        visible: (posting_tweet) ? true : false
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        source: "../images/twitter-icon-compose"+(compose_area.containsMouse ? "-pressed" : "")+".png"
        visible: (composeButton && twitter_account_exists ? true : false)

        MouseArea {
            id: compose_area
            anchors.fill:parent
            onClicked: {
                if(root.composeTweet){
                    window.nextPage("ComposeView.qml");
                }else{
                    root.composeClicked()
                }
            }
        }
    }

    TwitterButton {
        id: cancelButton

        isTopButton: true

        visible: editButton

        text: qsTrId("qtn_twitter_profile_edit_command")

        textColor: "white"

        onClicked: root.editClicked()

        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 130
    }
}
