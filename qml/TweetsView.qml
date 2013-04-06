import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: container

    orientationLock: window.orientationLock

    anchors.fill: parent

    Fonts { id: fonts }

    property int pull_down_header_height: 320
    property bool showFavorites: false
    property bool showList: false
    property string titletext: showList ? dataHandler.currentListName : showFavorites ? qsTrId("qtn_twitter_more_favorites") : qsTrId("qtn_twitter_profile_tweets")
    property string loadedUser: ""

    property bool isLoading: tweetsview_is_refreshing ? true : false

    TopBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        onDoubleClicked: listview.positionViewAtBeginning();
    }

    ProfileHeader {
        id: profile_header

        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: showList ? 0 : 105
        visible: showList ? false : true

        avatarURL: profile_subview_profile_image_url
        twitterName: profile_subview_screen_name
        firstName: profile_subview_firstname
        showArrow: false
    }
    Rectangle {
        id: spacer
        anchors.top: profile_header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "#CCCCCC"
    }
    Rectangle {
        id: list_title
        anchors.top: spacer.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: "#E6E6E6"
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: showList ? dataHandler.currentListName : showFavorites ? qsTrId("qtn_twitter_more_favorites") : qsTrId("qtn_twitter_profile_tweets")
            color: "#666666"
            font.pixelSize: fonts.c_size -2
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            text: showList ? "" : showFavorites ? dataHandler.getLocalizedInt(profile_subview_favourites_count) : dataHandler.getLocalizedInt(profile_subview_statuses_count)
            color: "#999999"
            font.pixelSize: fonts.c_size -2
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: list_area
        anchors.top: list_title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip:true

        RefreshingHeader {
            id: refreshing_header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: isLoading ? 60 : 0
            visible: isLoading && listview.count != 0? true : false
        }

        ListView {
            id: listview
            anchors.top: refreshing_header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            //maximumFlickVelocity:1500

            section.property: "section_timestamp"
            section.criteria: ViewSection.FullString

            pressDelay: 100

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 32
                color: "#999999"
                font.pixelSize: 50
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                text: showFavorites ? qsTrId("qtn_twitter_no_favorites") : qsTrId("qtn_twitter_no_tweets")
                visible: (!isLoading && listview.count == 0) ? true : false
            }

            PulldownHeader {
                id: pull_down_header
                width: listview.width
                height: pull_down_header_height
                y: listview.visibleArea.yPosition > 0 ? -height : -(listview.visibleArea.yPosition * Math.max(listview.height,listview.contentHeight)) - height
                visible: !listview.moving || isLoading ? false : true
            }

            function itemCreated(index) {
                var refresh = (tweetsview_is_loading_more || isLoading) ? false : tweetsview_more_tweets_available ? true : false
                if (index == (count-1) && refresh) {
                    if (showFavorites)
                        dataHandler.moreUserFavorites(dataHandler.currentUser);
                    else if (showList)
                        dataHandler.moreListTweets(dataHandler.currentListId);
                    else
                        dataHandler.moreUserTweets(dataHandler.currentUser);
                }
            }

            footer: Item {
                id: tweet_footer
                width: listview.width
                height: tweetsview_is_loading_more ? 80 : 0
                visible: tweetsview_is_loading_more ? true : false

                BusyIndicator {
                    anchors.centerIn: parent
                    running: visible
                    visible: !refreshing_header.visible && tweetsview_is_loading_more ? true : false
                    platformStyle: BusyIndicatorStyle {inverted: false}
                }
            }

            Connections {
                target: listview.visibleArea
                onYPositionChanged: {
                    if (listview.flicking)
                        return;

                    // reset last refresh time update flag
                    var contentYPos = listview.visibleArea.yPosition * Math.max(listview.height,listview.contentHeight);

                    // reload content
                    if ( ((!inPortrait&&contentYPos < -100)||(inPortrait&&contentYPos < -120)) && listview.moving ) {
                        listview.positionViewAtBeginning();
                        dataHandler.updateProfileView(dataHandler.currentUser);
                        dataHandler.releaseMouse(listview.objectName);
                        if (showFavorites)
                            dataHandler.updateUserFavorites(dataHandler.currentUser);
                        else if (showList)
                            dataHandler.updateListTweets(dataHandler.currentListId);
                        else
                            dataHandler.updateUserTweets(dataHandler.currentUser);
                    }
                }
            }

            model: showFavorites ? myFavoritesModel : myTweetsModel
            delegate: TimelineItem {
                width: listview.width
            }
            focus: true

            Component.onCompleted: {
                objectName = "TweetsView_list" + Math.random();
            }
        }
        TwitterSectionScroller {
            listView: listview
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: visible
            visible: (isLoading && listview.count == 0) ? true : false
            platformStyle: BusyIndicatorStyle {
                size: "large"
            }
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconSource: "../images/twitter-icon-toolbar-back.png"
            onClicked: {
                window.prevPage();
            }
        }
        ToolIcon {
            visible: (profile_subview_own_profile || !twitter_account_exists || showList) ? false : true
            iconSource: "../images/twitter-icon-toolbar-" + (profile_subview_blocked ? "blocked" : "block") + ".png"
            onClicked: {
                if (!profileview_loading) {
                    dataHandler.blockProfile(profile_subview_screen_name, !profile_subview_blocked);
                }
            }
        }
        ToolIcon {
            visible: showList && !tweetsview_following_list ? true : false
            iconSource: "../images/twitter-icon-toolbar-follow.png"
            onClicked: {
                // TODO: follow list
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.emitUpdateTimestamp();
        }
    }

    Component.onDestruction: {
        if (showFavorites)
            dataHandler.cleanFavoritesView();
        else
            dataHandler.cleanTweetsView();
    }
}
