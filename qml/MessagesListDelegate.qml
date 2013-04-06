import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container

    property bool receivedMessage: received != undefined ? received : false

    height: 98

    Fonts { id: fonts }

    Rectangle{
        anchors.fill: parent
        id: background
        color: "#DDDDDD"
        visible: mouse_area.containsMouse ? true : false
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        onClicked: {
            dataHandler.currentUser = screen_name;
            window.nextPage("MessagingConversationView.qml");
        }
    }


    Image {
        id: avatar
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16
        width: 50
        height: 50
        cache: false
        source: avatar_url ? avatar_url : "../images/default_profile_0_bigger.png"
        smooth: !container.ListView.view.moving
        MouseArea {
            anchors.fill: parent
            onClicked: {
                dataHandler.currentUser = screen_name;
                window.nextPage("ProfileView.qml");
            }
        }
    }

    Text {
        id: twitterName
        anchors.bottom: conversationTip.top
        anchors.left: avatar.right
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16

        font.pixelSize: fonts.c_size - 4
        font.bold: true
        color: "#000000"

        text: screen_name != undefined ? screen_name : ""
    }

    Text {
        id: conversationTip
        anchors.left: twitterName.left
        anchors.verticalCenter: container.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 32

        height: text_height.paintedHeight

        font.pixelSize: fonts.c_size - 2
        elide: Text.ElideRight        
        color: "#666666"
        clip: true
        textFormat: Text.RichText

        Text {
            id: text_height
            font.pixelSize: fonts.c_size
            text: " "
            visible: false
        }

        text: msg_text != undefined ? msg_text : ""
    }

    Text {
        id: lastMessageTime
        anchors.left: twitterName.left
        anchors.top: conversationTip.bottom
        anchors.right: parent.right
        anchors.rightMargin: 16

        font.pixelSize: fonts.d_size
        color: "#A5A5A5"
        textFormat: Text.RichText

        text: dataHandler.createTimeString(created_at)

        Connections {
            target: dataHandler
            onUpdateTimestamp: {
                lastMessageTime.text = dataHandler.createTimeString(created_at);
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
        anchors.topMargin: 16
        width: 8
        color: "#35CDFF"
        visible: msg_unread != undefined ? msg_unread : false
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#E6E6E6"
    }

}
