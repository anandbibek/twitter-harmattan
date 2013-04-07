import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: container
    property string tweet_desc: ""
    property string tweet_name: ""
    property string tweet_place: ""
    property string tweet_timestamp: ""
    property string tweet_image_url: ""
    property string tweet_retweeted_name: ""
    property string tweet_retweeted_by_me_id: ""
    property string tweet_reply_status_id: ""
    property string tweet_reply_name: ""
    property string tweet_source: ""
    property string tweet_tweetid: ""
    property string tweet_firstname: ""
    property bool tweet_favorited: false
    property string tweet_original_status: ""
    property bool tweet_protected_profile: false

    orientationLock: window.orientationLock
     
    anchors.fill: parent

    property bool editable: ((tweet_tweetid != "") && twitter_account_exists) ? true : false
    property bool goBackOnDone: false

    function openTweetEditor(){
        reply_edit.openTweetEditor()
    }

    Fonts { id: fonts }

    property int editExpandSpace: (container.height - commitbar.height)

    TopBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        BusyIndicator {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            platformStyle: BusyIndicatorStyle {
                size: "medium"
                inverted: true
            }
            running: visible
            visible: (tweetview_loading || tinyurl_thumb_loading || twitter_authenticating) ? true : false
        }
    }

    property bool validMessage: tweet_name != "" && reply_edit.textLenght < 141 && reply_edit.textLenght > 0

    OkCancelTopBar {
        id: commitbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: 0

        okButtonEnabled: validMessage && editable
        okText: qsTrId("qtn_twitter_reply_tweet_command")

        onOkClicked: {
            // If any images were selected, post with media..
            if (tweetImageUploadModel.count > 0) {
                dataHandler.replyToTweetWithMedia(reply_edit.text, tweet_tweetid, reply_edit.locationId);
            } else {
                // ... otherwise post only text tweet
                dataHandler.replyToTweetMessage(reply_edit.text, tweet_tweetid, reply_edit.locationId);
            }

            reply_edit.text = "";
            dataHandler.cleanUploadImages();
            reply_edit.state = "minimized";

            if(container.goBackOnDone){
                window.prevPage()
            }
        }
        onCancelClicked: {
            if((reply_edit.text == "" || reply_edit.text == ("@"+ tweet_name + " ")) && tweetImageUploadModel.count == 0){
                handleCancel()
            }else{
                discardDialog.open()
            }
        }

        function handleCancel(){
            reply_edit.text = "";
            dataHandler.cleanUploadImages();
            reply_edit.state = "minimized";

            if(container.goBackOnDone){
                window.prevPage()
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 32
        color: "#999999"
        font.pixelSize: 50
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter

        text: qsTrId("qtn_twitter_no_tweet_found")
        visible: (!tweetview_loading && !twitter_authenticating && tweet_desc == "") ? true : false
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
                id: profile_header

                anchors.left: parent.left
                anchors.right: parent.right

                height: visible ? 105 : 0
                visible: container.state == "editing" ? false : true

                property string loadedProfile: tweetview_profile_name
                property string loadedAvatar: tweetview_profile_avatar

                onLoadedAvatarChanged: {
                    if (twitterName.toLowerCase() == loadedProfile.toLowerCase()) {
                        avatarURL = loadedAvatar;
                    }
                }

                avatarURL: tweet_image_url
                twitterName: tweet_name
                firstName: tweet_firstname

                onClicked: {
                    if (tweet_name != "") {
                        dataHandler.currentUser = tweet_name;
                        window.nextPage("ProfileView.qml");
                    }
                }

                showArrow: true
            }

            Flickable {
                id:tweetcontent
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                height: Math.max(150, content_area.height - profile_header.height - reply_edit.height)

                flickableDirection: Flickable.VerticalFlick
                contentHeight: in_reply_item.y + in_reply_item.height + 16

                Item {
                    id: tweet_item
                    anchors.left: parent.left
                    anchors.right: parent.right

                    HighlightText {
                        id: tweet_text
                        y: 16
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 16

                        text: tweet_desc
                        fontSize: fonts.c_size+2
                        fontColor: fonts.c_color

                        Connections {
                            target: tweetcontent
                            onMovingChanged: tweet_text.resetHighlight();
                        }
                    }

                    Grid {
                        id: thumb_grid
                        anchors.top: tweet_text.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 16
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        visible: tweet_desc != "" ? true : false
                        columns: 3
                        spacing: 16

                        Repeater {
                            model: tweetThumbModel
                            delegate: Image {
                                sourceSize.width: (thumb_grid.width - 16) / thumb_grid.columns
                                source: pic_source != undefined ? pic_source : ""
                                smooth: true
                                MouseArea {
                                    id: thumb_area
                                    anchors.fill: parent
                                    onClicked: {
                                        dataHandler.updateImagePreview(pic_url);
                                        previewDialog.open()
                                    }
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    color: "#000000"
                                    radius: 5
                                    opacity: thumb_area.containsMouse ? 0.5 : 0
                                }
                            }
                        }
                    }

                    Text {
                        id: timestamp_text
                        anchors.top: thumb_grid.bottom
                        anchors.topMargin:12
                        anchors.left: parent.left
                        anchors.leftMargin:16

                        text: tweet_timestamp != "" ? dataHandler.createDetailTimeString(tweet_timestamp) : ""

                        color: "#999999"
                        font.pixelSize: fonts.d_size
                    }

                    Item {
                        id:location_item
                        visible: tweet_place != "" ? true : false
                        anchors.top:timestamp_text.top
                        anchors.left: timestamp_text.right
                        anchors.leftMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        height: tweet_place != "" ? location_text.height : 0
                        Item {
                            id:location_image_container
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: location_text.height
                            width:35
                            //visible: tweet_place != "" ? true : false
                            Image {
                                id: location_image
                                //anchors.left: parent.left
                                anchors.horizontalCenter:parent.horizontalCenter
                                anchors.top: parent.top
                                source: "../images/twitter-icon-location.png"
                                smooth: true

                            }
                        }
                        Text {
                            id: location_text
                            anchors.left: location_image_container.right
                            anchors.leftMargin: 4
                            anchors.right: parent.right
                            anchors.top: location_image_container.top
                            wrapMode: Text.WordWrap
                            text: tweet_place
                            color: fonts.e_color
                            //font.bold: true
                            font.pixelSize: fonts.e_size
                            //visible: tweet_place == "" ? false : true
                        }
                    }

                    HighlightText {
                        id: retweet_item
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.top: timestamp_text.bottom
                        anchors.topMargin: visible ? 12 : 0
                        height: visible ? timestamp_text.height : 0
                        fontColor: "#999999"
                        fontSize: fonts.d_size
                        text: dataHandler.findLinks(qsTrId("qtn_twitter_tweet_retweet").arg("@" + tweet_retweeted_name), false)
                        visible: tweet_retweeted_name != "" ? true : false
                        Connections {
                            target: tweetcontent
                            onMovingChanged: retweet_item.resetHighlight();
                        }
                    }

                    Text {
                        id: source_item
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.top: retweet_item.bottom
                        anchors.topMargin: visible ? 12 : 0
                        height: visible ? timestamp_text.height : 0
                        color: "#999999"
                        font.pixelSize: fonts.d_size
                        text: tweet_source
                        visible: tweet_source != "" ? true : false
                    }

                    HighlightText {
                        id: in_reply_item
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.top: source_item.bottom
                        anchors.topMargin: visible ? 32 : 0
                        height: visible ? timestamp_text.height : 0
                        alignRight: true
                        fontColor: "#999999"
                        fontSize: fonts.d_size
                        split: false
                        text: tweet_reply_status_id != "" ? ("<a href=\"$" + tweet_reply_status_id + "\" style=\"text-decoration:none; color:#4d6980\">"+qsTrId("qtn_twitter_inreply_to").arg("@" + tweet_reply_name) + "</a>") : qsTrId("qtn_twitter_inreply_to").arg("@" + tweet_reply_name)
                        visible: tweet_reply_name != "" ? true : false
                        Connections {
                            target: tweetcontent
                            onMovingChanged: in_reply_item.resetHighlight();
                        }
                    }
                }
            }

            TweetEdit {
                id: reply_edit
                anchors.left: parent.left
                anchors.right: parent.right
                visible: (!tweetview_loading && !twitter_authenticating) ? true : false
                placeholderText: qsTrId("qtn_twitter_reply_hint")
                state: "minimized"

                MouseArea {
                    anchors.fill: parent
                    onPressed: {                        
                        mouse.accepted = reply_edit.openTweetEditor();
                    }
                }

                Timer {
                    id: focusTimer
                    interval: 300
                    onTriggered: {
                        var mentions = dataHandler.getMentions(tweet_original_status, "@" + tweet_name);
                        var reply_user = "@" + tweet_name + " ";
                        reply_edit.text =  reply_user + mentions;
                        if (mentions.length > 0) {
                            reply_edit.select(reply_user.length, reply_edit.textLenght);
                        } else {
                            reply_edit.cursorPosition = reply_edit.textLenght;
                        }
                    }
                }

                function openTweetEditor(){
                    if (state == "minimized") {
                        openSoftwareInputPanel();
                        state = "";
                        focusTimer.start();
                        return true;
                    }
                    return false;
                }
            }
        }
    }

    Dialog {
        id: previewDialog

        platformStyle: DialogStyle {
            leftMargin: 0
            rightMargin: 0
            topMargin: 0
            bottomMargin: 0
            centered: true
        }

        content: Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: tinyUrlPreview != "" ? tinyUrlPreview : ""
            BusyIndicator {
                anchors.centerIn: parent
                running: visible
                visible: tinyurl_preview_loading ? true : false
                platformStyle: BusyIndicatorStyle {
                    size: "large"
                    inverted: true
                }
            }
        }
    }

    TwitterConfirmationDialog {
        id: deleteDialog

        okButtonText: qsTrId("qtn_twitter_delete_command")
        titleText: qsTrId("qtn_twitter_delete_query")

        onAccepted: {
            dataHandler.deleteTweet(tweet_tweetid);
            window.prevPage();
        }
    }

    TweetDiscardConfirmationDialog {
        id: discardDialog

        onAccepted: {
            commitbar.handleCancel()
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            id: toolBarback
            iconId: "toolbar-back";
            onClicked: {
                window.prevPage();                
            }
        }
        ToolIcon {
            iconSource: (tweet_name.toLowerCase() == dataHandler.authenticatedUser() ? "../images/twitter-icon-toolbar-delete.png" : "../images/twitter-icon-toolbar-retweet"+(tweet_retweeted_by_me_id != ""?"-marked":"")+".png")
            visible: !editable || (tweet_name.toLowerCase() != dataHandler.authenticatedUser() && tweet_protected_profile) ? false : true
            onClicked: {
                if (tweet_name.toLowerCase() == dataHandler.authenticatedUser()) {
                    deleteDialog.open();
                } else {
                    if (tweet_retweeted_by_me_id != "") {
                        dataHandler.undoRetweet(tweet_retweeted_by_me_id, tweet_tweetid);
                    }
                    else {
                        dataHandler.retweetMessage(tweet_tweetid);
                    }
                }
            }
        }
        ToolIcon {
            iconSource: tweet_favorited ? "../images/twitter-icon-toolbar-favourite-marked.png" : "../images/twitter-icon-toolbar-favourite.png"
            visible: editable ? true : false
            onClicked: {
                dataHandler.favoriteTweet(tweet_tweetid,!tweet_favorited);
            }
        }
//        ToolIcon {
//            enabled: false
//            visible: editable ? true : false
//            iconSource: "../images/twitter-icon-toolbar-share.png"
//            onClicked: {

//            }
//        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            if (window.eventPageLaunched) {
                toolBarback.iconSource = "image://theme/icon-l-twitter-main-view";
                window.eventPageLaunched = false;
            }
            container.objectName = "TweetView_"+dataHandler.currentTweetId;
            dataHandler.updateTweetView(dataHandler.currentTweetId);
            if (reply_edit.textLenght > 0) {
                state = "editing";
            }
        } else if (status == PageStatus.Deactivating) {
            state = "";
        }
    }

    states: [
        State {
            name: "editing"
            when: reply_edit.state != "minimized"
            PropertyChanges {
                target: commitbar
                opacity: 1
            }
            PropertyChanges {
                target: window
                showToolBar: false
            }
        },
        State {
            name: "loading"
            when: tweetview_loading || twitter_authenticating
            PropertyChanges {
                target: reply_edit
                height: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "editing"; to: "*"
            ParallelAnimation {
                PropertyAnimation { target: commitbar; duration: 300; properties: "opacity"}
            }
        },
        Transition {
            from: "*"; to: "editing"
            ParallelAnimation {
                PropertyAnimation { target: commitbar; duration: 300; properties: "opacity"}
            }
        },
        Transition {
            from: "loading"; to: "*"
            ParallelAnimation {
                PropertyAnimation { target: reply_edit; duration: 300; properties: "height"; easing.type: Easing.OutQuart }
            }
        },
        Transition {
            from: "*"; to: "loading"
            ParallelAnimation {
                PropertyAnimation { target: reply_edit; duration: 300; properties: "height"; easing.type: Easing.InOutQuart }
            }
        }
    ]
}
