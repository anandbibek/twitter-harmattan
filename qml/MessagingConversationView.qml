import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: root
     
    orientationLock: window.orientationLock
     
    anchors.fill: parent

    Fonts { id: fonts }

    TopBar {
        id: toolbar;
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        composeButton: false
        onDoubleClicked: conversations.positionViewAtBeginning();
        BusyIndicator {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            platformStyle: BusyIndicatorStyle {
                size: "medium"
                inverted: true
            }
            running: visible
            visible: messagesview_refresh_after_sending ? true : false
        }
    }

    property bool validMessage: conversation_twitterName != "" && replyEdit.textLenght < 141 && replyEdit.textLenght > 0

    Connections {
        target: dataHandler
        onNewMessages: {
            dataHandler.updateConversationView(conversation_twitterName);
        }
    }

    OkCancelTopBar {
        id: commitBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: 0

        okButtonEnabled: validMessage

        MessageDiscardConfirmationDialog {
            id: messageDiscardDialog

            onAccepted: {
                replyEdit.text = "";
                replyEdit.state = "minimized";
            }
        }

        onOkClicked: {
            if (replyEdit.textLenght > 0) {
                if (profileview_follower) {
                    dataHandler.postDirectMessage(conversation_twitterName, replyEdit.text);
                } else {
                    window.showError(qsTrId("qtn_twitter_profile_user_not_following").arg(conversation_twitterName));
                }
            }

            replyEdit.text = "";
            replyEdit.state = "minimized";
        }
        onCancelClicked: {
            if(replyEdit.text != ""){
                messageDiscardDialog.open()
            }else{
                replyEdit.text = "";
                replyEdit.state = "minimized";
            }
        }
    }

    Flickable {
        id: content_area
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        contentWidth: parent.width
        contentHeight: col.height

        flickableDirection: Flickable.VerticalFlick
        pressDelay: 100

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right

            ProfileHeader {
                id: senderInfo

                anchors.left: parent.left
                anchors.right: parent.right

                height: 105

                avatarURL: conversation_image_url
                twitterName: conversation_twitterName
                firstName: conversation_firstname

                showArrow: replyEdit.state == "minimized"

                onClicked: {
                    if(!showArrow)
                        return

                    dataHandler.currentUser = conversation_twitterName;
                    window.nextPage("ProfileView.qml");
                }
            }

            ListView {
                id: conversations
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(senderInfo.height, content_area.height - senderInfo.height - replyEdit.height)

                pressDelay: 100

                clip: true

                model: myConversationModel
                delegate: MessagingConversationDelegate {
                    id: conversation_delegate
                    property bool actionPerformed: false
                    width: conversations.width

                    onPressed: {
                        preventStealing = false;
                        actionPerformed = false;
                        longPressTimer.start();
                    }
                    onClicked: longPressTimer.stop();
                    onReleased: longPressTimer.stop();
                    onCanceled: longPressTimer.stop();
                    onDoubleClicked: longPressTimer.stop();

                    Timer {
                        id: longPressTimer
                        interval: 500
                        onTriggered: {
                            conversation_delegate.preventStealing = true;
                            conversation_delegate.actionPerformed = true;
                            contextMenu.messageText = msg_text;
                            contextMenu.messageId = msg_id;
                            contextMenu.messageAvatar = sender_avatar_url;
                            contextMenu.messageScreenName = sender_screen_name;
                            contextMenu.open();
                        }
                    }
                }

                onCountChanged: {
                    focusTimer.restart();
                }

                Timer {
                    id: focusTimer
                    interval: 100
                    onTriggered: {
                        conversations.positionViewAtEnd();
                    }
                }

                onHeightChanged: positionViewAtEnd();

                ScrollDecorator {
                    flickableItem: conversations
                }

                Connections {
                    target: inputContext
                    onSoftwareInputPanelVisibleChanged: {
                        if (inputContext.softwareInputPanelVisible) {
                            conversations.positionViewAtEnd();
                        }
                    }
                }
            }

            TweetEdit {
                id: replyEdit
                anchors.left: parent.left
                anchors.right: parent.right
                placeholderText: qsTrId("qtn_twitter_reply_hint")
                state: "minimized"

                messagingMode: true

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        if (replyEdit.state == "minimized") {
                            replyEdit.state = "";
                            replyEdit.openSoftwareInputPanel();
                        }
                        mouse.accepted = false;
                    }
                }

            }
        }
    }

    ActionMenu {
        id: contextMenu

        property alias messageText: contextMenuMessageLabel.text
        property string messageId: ""
        property string messageScreenName: ""
        property string messageAvatar: ""

        contentArea: Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            spacing: 16

            Item {
                anchors.left: parent.left
                anchors.right: parent.right

                height: childrenRect.height

                Image {
                    id: contextMenuAvatarImage

                    width: height

                    anchors.top: parent.top
                    anchors.left: parent.left
                    cache: false
                    smooth: true

                    source: contextMenu.messageAvatar
                }

                Column {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: contextMenuAvatarImage.right
                    anchors.leftMargin: 16

                    spacing: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        wrapMode: Text.Wrap

                        font.pixelSize: fonts.c_size
                        font.bold: true
                        color: "black"

                        text: contextMenu.messageScreenName
                    }

                    Text {
                        id: contextMenuMessageLabel

                        anchors.left: parent.left
                        anchors.right: parent.right

                        wrapMode: Text.Wrap
                        textFormat: Text.RichText

                        font.pixelSize: fonts.b_size - 2
                        color: "#999999"
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                ColumnButton {
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32
                        font.pixelSize: fonts.f_size
                        text: qsTrId("qtn_twitter_delete_message_command")
                        font.bold: true
                    }

                    onClicked: {
                        deleteConfirmationDialog.open();
                        contextMenu.close();
                    }
                }
//                ColumnButton {
//                    Text {
//                        anchors.verticalCenter: parent.verticalCenter
//                        anchors.left: parent.left
//                        anchors.leftMargin: 32
//                        font.pixelSize: fonts.f_size
//                        text: qsTrId("qtn_twitter_share_message_command")
//                        font.bold: true
//                    }

//                    onClicked: {
//                        //TODO:
//                        contextMenu.close()
//                    }
//                }
            }
        }
    }//~ActionMenu

    TwitterConfirmationDialog {
        id: deleteConfirmationDialog

        okButtonText: qsTrId("qtn_twitter_delete_command")
        titleText: qsTrId("qtn_twitter_delete_message_query")

        onAccepted: {
            dataHandler.deleteMessage(contextMenu.messageId);
            //window.prevPage();
        }
    }

    onStateChanged: {
        if(state == "editing"){
            conversations.positionViewAtEnd();
        }
    }

    states: [
        State {
            name: "editing"
            when: replyEdit.state != "minimized"
            PropertyChanges {
                target: commitBar
                opacity: 1
            }
            PropertyChanges {
                target: window
                showToolBar: false
            }
        }
    ]
    transitions: Transition {
        ParallelAnimation {
            PropertyAnimation { target: commitBar; duration: 300; properties: "opacity"}
            //PropertyAnimation { target: toolbar; duration: 300; properties: "opacity"}
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconSource: "../images/twitter-icon-toolbar-back.png"
            onClicked: {
                window.prevPage();
            }
        }
//        ToolIcon {
//            iconSource: "../images/twitter-icon-toolbar-share.png"
//            onClicked: {
//                //TODO:
//            }
//        }
//        ToolIcon {
//            iconSource: "../images/twitter-icon-toolbar-delete.png"
//            onClicked: {
//                //TODO:
//            }
//        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            dataHandler.emitUpdateTimestamp();
        } else if (status == PageStatus.Activating) {
            dataHandler.updateConversationView(dataHandler.currentUser);
            dataHandler.updateIsFollower(dataHandler.currentUser);
            conversations.positionViewAtEnd();
        }
    }
}
