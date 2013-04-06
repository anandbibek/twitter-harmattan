import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: composeview

    orientationLock: window.orientationLock

    Fonts { id: fonts }

    property bool validMessage: tweet_edit.textLenght < 141 && tweet_edit.textLenght > 0

    property alias text: tweet_edit.text
    property alias cursorPosition: tweet_edit.cursorPosition

    OkCancelTopBar {
        id: topbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        okButtonEnabled: validMessage
        okText: qsTrId("qtn_twitter_tweet_command")

        TweetDiscardConfirmationDialog {
            id: tweetDiscardDialog

            onAccepted: {
                dataHandler.prepareReplyTo("");
                dataHandler.cleanUploadImages();
                window.prevPage()
            }
        }

        onOkClicked: {
            // If any images were selected, post with media..
            if (tweetImageUploadModel.count > 0) {
                dataHandler.postTweetWithMedia(tweet_edit.text, tweet_edit.locationId);
            } else {
                // ... otherwise post only text tweet
                dataHandler.postTweetMessage(tweet_edit.text, tweet_edit.locationId);
            }
            dataHandler.prepareReplyTo("");
            dataHandler.cleanUploadImages();
            window.prevPage();
        }
        onCancelClicked: {
            if(tweet_edit.text != "" || tweetImageUploadModel.count > 0){
                tweetDiscardDialog.open()
            }else{
                dataHandler.prepareReplyTo("");
                dataHandler.cleanUploadImages();
                window.prevPage();
            }
        }
    }

    Flickable {
        id: content_area
        anchors.top: topbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        contentWidth: parent.width
        contentHeight: tweet_edit.height

        flickableDirection: Flickable.VerticalFlick
        pressDelay: 100

        TweetEdit {
            id: tweet_edit
            width: content_area.width
            initialHeight: composeview.height - topbar.height
            text: composeview_in_reply_to != "" ? "@" + composeview_in_reply_to + " " : ""
        }
    }

    ScrollDecorator {
        flickableItem: content_area
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (window.eventPageLaunched) {
                window.eventPageLaunched = false;
            }
            tweet_edit.openSoftwareInputPanel();
        }
    }
}
