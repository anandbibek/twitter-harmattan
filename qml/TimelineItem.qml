import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: timelinedelegate

    height: tweet_content.height + 8
    Fonts { id: fonts }

    Rectangle {
        anchors.fill: parent
        id: background
        color: mouse_area.containsMouse ? "#DDDDDD" : ((reply_name == undefined || reply_name == "") ? "#F2F2F2" : "#EDEDED")
    }   

    Loader {
        id: contextmenuLoader
        onLoaded: {
            item.open();
        }
    }

    Component {
        id: contextMenuContent
        ActionMenu {
            id: contextmenu

            TwitterConfirmationDialog {
                id: deleteDialog

                okButtonText: qsTrId("qtn_twitter_delete_command")
                titleText: qsTrId("qtn_twitter_delete_query")

                onAccepted: {
                    dataHandler.deleteTweet(tweetid);
                }
            }

            contentArea: Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.topMargin: 16
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                TweetContent {
                    isListItem: false

                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    ColumnButton {
                        Row{
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter

                            spacing: 16

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                source: "../images/twitter-icon-list-reply.png"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTrId("qtn_twitter_reply_tweet_command")
                                font.pixelSize: fonts.f_size
                                font.bold: true
                            }
                        }

                        onClicked: {
                            dataHandler.currentTweetId = original_tweetid;
                            var p = window.nextPage("TweetView.qml");
                            p.tweet_name = name;
                            p.goBackOnDone = true;
                            p.openTweetEditor();
                            contextmenu.close();
                        }
                    }
                    ColumnButton {
                        visible: name.toLowerCase() != dataHandler.authenticatedUser() && !protected_profile ? true : false

                        Row{
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter

                            spacing: 16

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                source: "../images/twitter-icon-menu-retweet"+(retweeted_by_me_id != ""?"-marked":"")+".png"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: retweeted_by_me_id != "" ? qsTrId("qtn_twitter_undo_retweet_command") : qsTrId("qtn_twitter_retweet_command")
                                font.pixelSize: fonts.f_size
                                font.bold: true
                            }
                        }

                        onClicked: {
                            if (retweeted_by_me_id != "") {
                                dataHandler.undoRetweet(retweeted_by_me_id, original_tweetid);
                            } else {
                                dataHandler.retweetMessage(original_tweetid);
                            }
                            contextmenu.close();
                        }
                    }
                    ColumnButton {
                        visible: name.toLowerCase() == dataHandler.authenticatedUser()

                        Row{
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter

                            spacing: 16

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                source: "../images/twitter-icon-toolbar-delete.png"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:  qsTrId("qtn_twitter_delete_command")
                                font.pixelSize: fonts.f_size
                                font.bold: true
                            }
                        }

                        onClicked: {
                            deleteDialog.open();
                            contextmenu.close();
                        }
                    }
                    ColumnButton {
                        Row{
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter

                            spacing: 16

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                source: "../images/twitter-icon-toolbar-favourite"+(favorited?"-marked":"")+".png"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: favorited ? qsTrId("qtn_twitter_unfavorite_command") : qsTrId("qtn_twitter_favorite_command")
                                font.pixelSize: fonts.f_size
                                font.bold: true
                            }
                        }

                        onClicked: {
                            dataHandler.favoriteTweet(original_tweetid, !favorited);
                            contextmenu.close();
                        }
                    }
//                    ColumnButton {
//                        Row{
//                            anchors.left: parent.left
//                            anchors.leftMargin: 16
//                            anchors.verticalCenter: parent.verticalCenter

//                            spacing: 16

//                            Image {
//                                anchors.verticalCenter: parent.verticalCenter
//                                source: "../images/twitter-icon-toolbar-share.png"
//                            }
//                            Text {
//                                anchors.verticalCenter: parent.verticalCenter
//                                text: qsTrId("qtn_twitter_share_command")
//                                font.pixelSize: fonts.f_size
//                                font.bold: true
//                            }
//                        }

//                        onClicked: {
//                            //TODO:
//                        }
//                    }
                }
            }
        }//~ActionMenu
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        property bool actionPerformed: false
        onClicked: {
            if (!actionPerformed) {
                longPressTimer.stop();
                dataHandler.currentTweetId = original_tweetid;
                window.nextPage("TweetView.qml");
            }
        }
        onPressed: {
            preventStealing = false;
            actionPerformed = false;
            longPressTimer.start();
        }
        onReleased: longPressTimer.stop();
        onCanceled: longPressTimer.stop();
        onDoubleClicked: longPressTimer.stop();

        Timer {
            id: longPressTimer
            interval: 500
            onTriggered: {
                mouse_area.preventStealing = true;
                mouse_area.actionPerformed = true;
                if (twitter_account_exists) {
                    if (contextmenuLoader.status == Loader.Ready) {
                        contextmenuLoader.item.open();
                    } else {
                        contextmenuLoader.sourceComponent = contextMenuContent;
                    }
                }

            }
        }
    }

    TweetContent {
        id: tweet_content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Rectangle {
        id: tweet_separator_line
        width: parent.width
        anchors.bottom: parent.bottom
        height: 1
        color: "#E3E3E3"
    }

    Component.onCompleted: {
        ListView.view.itemCreated(index);
    }
}
