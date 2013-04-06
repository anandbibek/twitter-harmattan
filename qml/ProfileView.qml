import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    orientationLock: window.orientationLock

    Fonts { id: fonts }

    anchors.fill: parent

    property bool navigatedToProfileEdit: false

    Column {
        id: topColumn

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        TopBar {
            id: topBar

            anchors.left: parent.left
            anchors.right: parent.right

            composeTweet: false

            composeButton: !editButton

            editButton: profileview_own_profile

            onEditClicked: {
                navigatedToProfileEdit = true;
                window.nextPage("OwnProfileEditView.qml");
            }

            onComposeClicked: {
                if(profileview_follower){
                    tweetOrMessageMenu.open()
                }else{
                    startMentioningComposer()
                }
            }

            TweetOrMessageMenu {
                id: tweetOrMessageMenu

                labelTxt: profileview_screen_name
                imageSrc: profileview_profile_image_url

                firstButtonLabelText: qsTrId("qtn_twitter_mention_command")

                onDirectMessageClicked: {
                    dataHandler.prepareComposeTo(profileview_screen_name, profileview_profile_image_url, profileview_firstname);
                    window.nextPage("MessageComposeView.qml");
                    tweetOrMessageMenu.close();
                }

                onTweetClicked: {
                    topBar.startMentioningComposer();
                }
            }

            function startMentioningComposer(){
                var p = window.nextPage("ComposeView.qml");
                p.text = "@" + profileview_screen_name + " ";
                p.cursorPosition = p.text.length;
                tweetOrMessageMenu.close();
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right

            height: !profileview_protected || profileview_own_profile ? basicProfileHeader.height : basicProfileHeader.height + followRequestButton.height + 32

            color: "#000000"

            BasicProfileHeader {
                id: basicProfileHeader

                height: 105

                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right

                avatarURL: profileview_profile_image_url
                twitterName: profileview_screen_name
                firstName: profileview_firstname
                buttonItem: followUnfollowButton.visible ? followButtonArea : busyInd.visible ? busyInd : profile_locked_image.visible ? profile_locked_image : null
            }

            MouseArea {
                anchors.fill: basicProfileHeader

                onClicked: {
                    fullscreenAvatarDialog.open()
                }
            }

            Item {
                id: followButtonArea
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                anchors.rightMargin: 10

                width: 130
                height: followUnfollowButton.height

                TwitterButton {
                    id: followUnfollowButton
                    inverted: true
                    visible: !profileview_loading && !twitter_authenticating && !profileview_protected && !profileview_blocked && !profileview_own_profile && twitter_account_exists

                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: profileview_following ? qsTrId("qtn_twitter_profile_unfollow") : qsTrId("qtn_twitter_profile_follow")
                    textColor: "white"

                    onClicked: {
                        dataHandler.followProfile(profileview_screen_name, !profileview_following);
                    }
                }
            }

            Image {
                id: profile_locked_image
                visible: profileview_protected

                anchors.right: parent.right
                anchors.verticalCenter: basicProfileHeader.verticalCenter

                anchors.rightMargin: 10

                source: "../images/twitter-icon-top-pane-locked.png"
            }

            BusyIndicator {
                id: busyInd
                anchors.right: profile_locked_image.left
                anchors.verticalCenter: basicProfileHeader.verticalCenter

                anchors.rightMargin: 16

                platformStyle: BusyIndicatorStyle {
                    size: "medium"
                }
                running: visible
                visible: ((profileview_loading || twitter_authenticating) && !updatingProfileImage) ? true : false
            }

            TwitterButton {
                id: followRequestButton

                inverted: true
                visible: profileview_protected && !profileview_own_profile && twitter_account_exists

                anchors.top: basicProfileHeader.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                anchors.rightMargin: 10

                text: qsTrId("qtn_twitter_profile_follow_request")
                textColor: "white"

                onClicked: {
                    dataHandler.followProfile(profileview_screen_name, true);
                }
            }
        }
    }//~Column



    Flickable {
        id: profileContent
        anchors.top: topColumn.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

//        contentWidth: childrenRect.width
        contentHeight: buttonsColumn.y + buttonsColumn.height + 32

        flickableDirection: Flickable.VerticalFlick

        clip: true

        Text {
            id: descriptionLabel

            y: text != "" ? 32 : 0
            anchors.leftMargin: 32
            anchors.rightMargin: 32

            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: fonts.f_size
            height: text != "" ? paintedHeight : 0
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            text: profileview_description
            color: "white"
        }

        Text {
            id: locationLabel

            anchors.leftMargin: 32
            anchors.rightMargin: 32

            anchors.topMargin: text != "" ? 24 : 0
            anchors.top: descriptionLabel.bottom

            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: fonts.f_size
            height: text != "" ? paintedHeight : 0
            color: "#999999"
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            text: profileview_location
        }

        HighlightText {
            id: urlLabel

            anchors.leftMargin: 32
            anchors.rightMargin: 32

            anchors.topMargin: text != "" ? 24 : 0
            anchors.top: locationLabel.bottom

            anchors.left: parent.left
            anchors.right: parent.right
            fontSize: fonts.f_size
            height: text != "" ? paintedHeight : 0
            text: profileview_ui_url

            Connections {
                target: profileContent
                onMovingChanged: urlLabel.resetHighlight();
            }

            onTextChanged: {
                console.log("profileview text:",text)
            }
        }

        Text {
            id: statusLabel

            anchors.leftMargin: 32
            anchors.rightMargin: 32

            anchors.topMargin: text != "" && visible ? 32 : 0
            anchors.top: urlLabel.bottom

            anchors.left: parent.left
            anchors.right: parent.right

            text: (profileview_blocked ? qsTrId("qtn_twitter_profile_user_blocked").arg(profileview_screen_name) : (profileview_follower ? qsTrId("qtn_twitter_profile_user_following").arg(profileview_screen_name) : qsTrId("qtn_twitter_profile_user_not_following").arg(profileview_screen_name)))
            font.pixelSize: fonts.f_size
            height: text != "" && visible ? paintedHeight : 0
            wrapMode: Text.WordWrap
            color: "#999999"
            visible: (profileview_screen_name != "" && twitter_account_exists && !profileview_own_profile) ? true : false
        }

        Column {
            id: buttonsColumn

            anchors.topMargin: 32
            anchors.top: statusLabel.bottom

            anchors.leftMargin: 16
            anchors.rightMargin: 16

            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 16

            function openProfilePage(pageFilename){
                if(profileview_protected){
                    profileProtectedDialog.imageUrl = profileview_profile_image_url
                    profileProtectedDialog.username = profileview_screen_name
                    profileProtectedDialog.open()
                }else{
                    window.nextPage(pageFilename)
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                ColumnButton {
                    onClicked: buttonsColumn.openProfilePage("UserTweetsView.qml")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32

                        font.pixelSize: fonts.f_size
                        font.bold: true
                        color: "white"

                        text: qsTrId("qtn_twitter_profile_tweets")
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 32

                        font.pixelSize: fonts.f_size
                        color: "#999999"

                        text: dataHandler.getLocalizedInt(profileview_statuses_count)
                    }
                }
                ColumnButton {
                    onClicked: buttonsColumn.openProfilePage("FavoritesView.qml")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32

                        font.pixelSize: fonts.f_size
                        font.bold: true
                        color: "white"

                        text: qsTrId("qtn_twitter_more_favorites")
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 32

                        font.pixelSize: fonts.f_size
                        color: "#999999"

                        text: dataHandler.getLocalizedInt(profileview_favourites_count)
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                ColumnButton {
                    onClicked: buttonsColumn.openProfilePage("FollowingView.qml")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32

                        font.pixelSize: fonts.f_size
                        font.bold: true
                        color: "white"

                        text: qsTrId("qtn_twitter_profile_following")
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 32

                        font.pixelSize: fonts.f_size
                        color: "#999999"

                        text: dataHandler.getLocalizedInt(profileview_friends_count)
                    }
                }
                ColumnButton {
                    onClicked: buttonsColumn.openProfilePage("FollowersView.qml")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32

                        font.pixelSize: fonts.f_size
                        font.bold: true
                        color: "white"

                        text: qsTrId("qtn_twitter_profile_followers")
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 32

                        font.pixelSize: fonts.f_size
                        color: "#999999"

                        text: dataHandler.getLocalizedInt(profileview_followers_count)
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                ColumnButton {
                    onClicked: buttonsColumn.openProfilePage("ListsView.qml")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32

                        font.pixelSize: fonts.f_size
                        font.bold: true
                        color: "white"

                        text: qsTrId("qtn_twitter_profile_listed")
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 32

                        font.pixelSize: fonts.f_size
                        color: "#999999"

                        text: dataHandler.getLocalizedInt(profileview_listed_count)
                    }
                }
            }
        }//~Column (buttons)

    }//~Flickable



    property bool profile_image_reloaded: false



    tools: ToolBarLayout {
        ToolIcon {
            id: toolBarback
            iconSource: "../images/twitter-icon-toolbar-back.png"
            onClicked: {                
                window.prevPage();
            }
        }

        ToolIcon {
            visible: (profileview_own_profile || !twitter_account_exists) ? false : true
            iconSource: "../images/twitter-icon-toolbar-" + (profileview_blocked ? "blocked" : "block") + ".png"
            onClicked: {
                if (!profileview_loading) {
                    dataHandler.blockProfile(profileview_screen_name, !profileview_blocked);
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            if (window.eventPageLaunched) {
                toolBarback.iconSource = "image://theme/icon-l-twitter-main-view";
                window.eventPageLaunched = false;
            }
            if (navigatedToProfileEdit) {
                // No need to refresh again when returning from profile edit
                navigatedToProfileEdit = false;
            } else {
                dataHandler.updateProfileView(dataHandler.currentUser, !profile_image_reloaded);
            }
            if (!profile_image_reloaded) {
                profile_image_reloaded = true;
            }
        }
    }

    Dialog {
        id: fullscreenAvatarDialog

        content: Image {
            cache: false
            id: fullscreenPicImage
            source: profileview_profile_image_url_original
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }//~Dialog

    Dialog {
        id: profileProtectedDialog

        property alias imageUrl: protectedDialogPicImage.source

        property string username

        content: Column {
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 32

            Image {
                id: protectedDialogPicImage

                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTrId("qtn_twitter_follow_request_head").arg("@" + profileProtectedDialog.username)

                font.pixelSize: fonts.b_size
                font.bold: true
                color: "white"

                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: qsTrId("qtn_twitter_follow_request").arg("@" + profileProtectedDialog.username)

                font.pixelSize: fonts.c_size
                font.bold: false
                color: "white"

                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Column {
                spacing: 16

                TwitterButton {                    
                    text: qsTrId("qtn_twitter_follow_request_command")

                    isDialogButton: true
                    isPositiveAnswer: true

                    onClicked: {
                        dataHandler.followProfile(profileview_screen_name, true);
                        profileProtectedDialog.close()
                    }
                }

                TwitterButton {
                    text: qsTrId("qtn_twitter_cancel_command")

                    isDialogButton: true

                    onClicked: {
                        profileProtectedDialog.close()
                    }
                }
            }
        }//~Column
    }//~Dialog
}
