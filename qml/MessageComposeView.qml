import QtQuick 1.1
import com.nokia.meego 1.0


TwitterPage {
    id: root

    orientationLock: window.orientationLock

    Fonts { id: fonts }

    property bool validMessage: composeview_screenname != "" && edit.textLenght < 141 && edit.textLenght > 0

    OkCancelTopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        okButtonEnabled: root.validMessage

        MessageDiscardConfirmationDialog {
            id: messageDiscardDialog

            onAccepted: window.prevPage()
        }

        onOkClicked: {
            if(root.validMessage){
                dataHandler.postDirectMessage(composeview_screenname, edit.text);
            }
            window.prevPage();
        }
        onCancelClicked: {
            if(edit.text != ""){
                messageDiscardDialog.open()
            }else{
                window.prevPage();
            }
        }
    }

    Rectangle {
        id: profileViewRect

        color: "#000000"

        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: 105

        BasicProfileHeader {
            anchors.fill: parent

            avatarURL: composeview_imageurl
            twitterName: composeview_screenname
            firstName: composeview_realname
        }

        Image {
            source: "../images/twitter-drop-shadow.png"

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }
    MessagingConversationDelegate {
        id: conversationTip
        anchors.top: profileViewRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: visible ? preferredHeight : 0
        visible: (composeview_msg_text != undefined && composeview_msg_text != "") ? true : false

        message_text: composeview_msg_text != undefined ? composeview_msg_text : ""
        message_created_at: composeview_created_at != undefined ? composeview_created_at : ""
        message_received: composeview_received != undefined ? composeview_received : false
    }

    Flickable {
        id: content_area
        anchors.top: conversationTip.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        contentWidth: parent.width
        contentHeight: edit.height

        flickableDirection: Flickable.VerticalFlick
        pressDelay: 100

        TweetEdit {
            id: edit
            width: content_area.width
            initialHeight: root.height - topBar.height - profileViewRect.height - conversationTip.height

            messagingMode: true
        }
    }

    ScrollDecorator {
        flickableItem: content_area
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            edit.openSoftwareInputPanel();
        }
    }
}
