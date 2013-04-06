import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: container

    orientationLock: window.orientationLock

    anchors.fill: parent

    Fonts { id: fonts }

    property int pull_down_header_height: 320

    property bool isLoading: listsview_loading ? true : false
    property string loadedUser: ""

    TopBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        onDoubleClicked: lists_listview.positionViewAtBeginning();
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
        color: "#000000"
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: qsTrId("qtn_twitter_more_lists")
            color: "#666666"
            font.pixelSize: fonts.c_size -2
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            text: dataHandler.getLocalizedInt(profile_subview_listed_count)
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
            visible: isLoading && lists_listview.count != 0 ? true : false
        }

        ListView {
            id: lists_listview
            anchors.top: refreshing_header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            pressDelay: 100
            clip: true
            //maximumFlickVelocity:1500

            PulldownHeader {
                id: pull_down_header
                width: lists_listview.width
                height: pull_down_header_height
                y: lists_listview.visibleArea.yPosition > 0 ? -height : -(lists_listview.visibleArea.yPosition * Math.max(lists_listview.height, lists_listview.contentHeight)) - height
                visible: !lists_listview.moving || isLoading ? false : true
            }

            Connections {
                target: lists_listview.visibleArea
                onYPositionChanged: {
                    if (lists_listview.flicking)
                        return;

                    // reset last refresh time update flag
                    var contentYPos = lists_listview.visibleArea.yPosition * Math.max(lists_listview.height, lists_listview.contentHeight);

                    // reload content
                    if ( ((!inPortrait&&contentYPos < -100)||(inPortrait&&contentYPos < -120)) && lists_listview.moving ) {
                        dataHandler.releaseMouse(lists_listview.objectName);
                        lists_listview.positionViewAtBeginning();
                        dataHandler.updateProfileView(dataHandler.currentUser);
                        dataHandler.updateAddedToLists(dataHandler.currentUser);
                    }
                }
            }

            model: myAddedToListsModel
            delegate: ListsItem {
                width: lists_listview.width
            }
            focus: true

            function itemCreated(index) {
                var refresh = (listsview_is_loading_more || isLoading) ? false : listsview_more_available ? true : false
                if (index == (count-1) && refresh) {
                    dataHandler.moreAddedToLists(dataHandler.currentUser);
                }
            }

            footer: Item {
                id: tweet_footer
                width: lists_listview.width
                height: listsview_is_loading_more ? 80: 0
                visible: listsview_is_loading_more ? true : false

                BusyIndicator {
                    anchors.centerIn: parent
                    running: visible
                    visible: listsview_is_loading_more ? true : false
                    platformStyle: BusyIndicatorStyle {inverted: false}
                }
            }

            Component.onCompleted: {
                objectName = "ListsView_list" + Math.random();
            }
        }
        ScrollDecorator {
            flickableItem: lists_listview
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: visible
            visible: (isLoading && lists_listview.count == 0) ? true : false
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
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateProfileSubView(dataHandler.currentUser);
            dataHandler.updateAddedToLists(dataHandler.currentUser, loadedUser != dataHandler.currentUser);
            loadedUser = dataHandler.currentUser;
        }
    }

    Component.onDestruction: {
        dataHandler.cleanAddedToLists();
    }
}
