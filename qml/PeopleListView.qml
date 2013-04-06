import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: container
     
    orientationLock: window.orientationLock
    property bool showFollowers: false
    property string loadedUser: ""

    anchors.fill: parent

    Fonts { id: fonts }

    property int pull_down_header_height: 320

    property bool isLoading: peoplelistview_is_refreshing ? true : false

    TopBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        onDoubleClicked: peoplelist_listview.positionViewAtBeginning();
    }

    ProfileHeader {
        id: profile_header

        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: 105

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
        color: "#101010"
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: showFollowers ? qsTrId("qtn_twitter_profile_followers") : qsTrId("qtn_twitter_profile_following")
            color: "#ffffff"
            font.pixelSize: fonts.c_size -2
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            text: showFollowers ? dataHandler.getLocalizedInt(profile_subview_followers_count) : dataHandler.getLocalizedInt(profile_subview_friends_count)
            color: "#d0d0d0"
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
            visible: (isLoading && peoplelist_listview.count != 0) ? true : false
        }

        ListView {
            id: peoplelist_listview
            anchors.top: refreshing_header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            //maximumFlickVelocity:1500

            pressDelay: 100

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 32
                color: "#d0d0d0"
                font.pixelSize: 50
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                text: showFollowers ? qsTrId("qtn_twitter_no_followers") : qsTrId("qtn_twitter_no_followings")
                visible: (!isLoading && peoplelist_listview.count == 0) ? true : false
            }

            PulldownHeader {
                id: pull_down_header
                width: peoplelist_listview.width
                height: pull_down_header_height
                y: peoplelist_listview.visibleArea.yPosition > 0 ? -height : -(peoplelist_listview.visibleArea.yPosition * Math.max(peoplelist_listview.height, peoplelist_listview.contentHeight)) - height
                visible: !peoplelist_listview.moving || isLoading ? false : true
            }

            ScrollDecorator {
                flickableItem: peoplelist_listview
            }

            Connections {
                target: peoplelist_listview.visibleArea
                onYPositionChanged: {
                    if (peoplelist_listview.flicking)
                        return;

                    // reset last refresh time update flag
                    var contentYPos = peoplelist_listview.visibleArea.yPosition * Math.max(peoplelist_listview.height, peoplelist_listview.contentHeight);

                    // reload content
                    if ( ((!inPortrait&&contentYPos < -100)||(inPortrait&&contentYPos < -120)) && peoplelist_listview.moving ) {
                        dataHandler.releaseMouse(peoplelist_listview.objectName);
                        peoplelist_listview.positionViewAtBeginning();
                        dataHandler.updateProfileView(dataHandler.currentUser);
                        if (showFollowers)
                            dataHandler.updateFollowersView(dataHandler.currentUser);
                        else
                            dataHandler.updateFollowingView(dataHandler.currentUser);
                    }
                }
            }

            model: showFollowers ? myFollowerModel : myFollowingModel
            delegate: PeopleListItem {
                width: peoplelist_listview.width
            }
            focus: true

            function itemCreated(index) {
                var refresh = (peoplelistview_is_loading_more || isLoading) ? false : peoplelistview_more_people_available ? true : false
                if (index == (count-1) && refresh) {
                    if (showFollowers)
                        dataHandler.moreFollowersView();
                    else
                        dataHandler.moreFollowingView();
                }
            }

            footer: Item {
                id: tweet_footer
                width: peoplelist_listview.width
                height: peoplelistview_is_loading_more ? 80: 0
                visible: peoplelistview_is_loading_more ? true : false

                BusyIndicator {
                    anchors.centerIn: parent
                    running: visible
                    visible: !refreshing_header.visible && peoplelistview_is_loading_more ? true : false
                    platformStyle: BusyIndicatorStyle {inverted: false}
                }
            }

            Component.onCompleted: {
                objectName = "PeopleListView_list" + Math.random();
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: visible
            visible: (isLoading && peoplelist_listview.count == 0) ? true : false
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
            visible: (profile_subview_own_profile || !twitter_account_exists) ? false : true
            iconSource: "../images/twitter-icon-toolbar-" + (profile_subview_blocked ? "blocked" : "block") + ".png"
            onClicked: {
                if (!profileview_loading) {
                    dataHandler.blockProfile(profile_subview_screen_name, !profile_subview_blocked);
                }
            }
        }
    }

    Component.onDestruction: {
        if (showFollowers)
            dataHandler.cleanFollowersView();
        else
            dataHandler.cleanFollowingView();
    }
}
