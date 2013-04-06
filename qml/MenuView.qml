import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: menuview
    orientationLock: window.orientationLock
    Fonts { id: fonts }

    property string item_fontcolor: fonts.c_color
    property int item_fontsize: fonts.c_size

    TopBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item {
        id: menu_list
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: childrenRect.height

        Item {
            id:profile_entry
            width:parent.width
            height:80
            anchors.left:parent.left
            Rectangle{
                anchors.fill: parent;
                color: "#DDDDDD";
                visible: profile_mouse_area.containsMouse ? true : false
            }
            Image {
                id: profile_image
                source: "../images/twitter-icon-list-profile.png"
                smooth: true
                anchors.left: parent.left
                anchors.leftMargin:16
                anchors.verticalCenter:parent.verticalCenter
            }
            Text {
                anchors.left:profile_image.right
                anchors.leftMargin:16
                text: qsTrId("qtn_twitter_more_profile")
                font.bold: true
                color: item_fontcolor
                font.pixelSize: item_fontsize
                anchors.verticalCenter:parent.verticalCenter
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 16
                text: profileview_screen_name
                color: "#C0C0C0"
                font.pixelSize: item_fontsize
                anchors.verticalCenter: parent.verticalCenter
            }
            MouseArea {
                id: profile_mouse_area
                anchors.fill: parent
                onClicked: {
                    dataHandler.currentUser = dataHandler.authenticatedUser();
                    window.nextPage("ProfileView.qml");
                }
            }
            Rectangle {
                width: parent.width
                anchors.top: parent.bottom
                height: 1
                color: "#E3E3E3"
            }
        }

        Item {
            id:favorites_entry
            width:parent.width
            height:80
            anchors.top:profile_entry.bottom
            anchors.left:parent.left
            Rectangle{
                anchors.fill: parent;
                color: "#DDDDDD";
                visible: favorites_mouse_area.containsMouse ? true : false
            }
            Image {
                id: favorite_image
                source: "../images/twitter-icon-toolbar-favourite.png"
                smooth: true
                anchors.left: parent.left
                anchors.leftMargin:16
                anchors.verticalCenter:parent.verticalCenter
            }
            Text {
                anchors.left:favorite_image.right
                anchors.leftMargin:16
                text: qsTrId("qtn_twitter_more_favorites")
                font.bold: true
                color: item_fontcolor
                font.pixelSize: item_fontsize
                anchors.verticalCenter:parent.verticalCenter
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 16
                text: dataHandler.getLocalizedInt(profileview_favourites_count)
                color: "#C0C0C0"
                font.pixelSize: item_fontsize
                anchors.verticalCenter: parent.verticalCenter
            }
            MouseArea {
                id: favorites_mouse_area
                anchors.fill: parent
                onClicked: {
                    window.nextPage("FavoritesView.qml")
                }
            }
            Rectangle {
                width: parent.width
                anchors.top: parent.bottom
                height: 1
                color: "#E3E3E3"
            }
        }

        Item {
            id:retweets_entry
            width:parent.width
            height:80
            anchors.top:favorites_entry.bottom
            anchors.left:parent.left

            Rectangle{
                anchors.fill: parent;
                color: "#DDDDDD";
                visible: retweets_mouse_area.containsMouse ? true : false
            }
            Image {
                id: retweet_image
                source: "../images/twitter-icon-menu-retweet.png"
                smooth: true
                anchors.left: parent.left
                anchors.leftMargin:16
                anchors.verticalCenter:parent.verticalCenter
            }
            Text {
                anchors.left: retweet_image.right
                anchors.leftMargin:16
                text: qsTrId("qtn_twitter_more_retweets")
                font.bold: true
                color: item_fontcolor
                font.pixelSize: item_fontsize
                anchors.verticalCenter:parent.verticalCenter
            }
            MouseArea {
                id: retweets_mouse_area
                anchors.fill: parent
                onClicked: {
                    window.nextPage("RetweetedByMeView.qml")
                }
            }
            Rectangle {
                width: parent.width
                anchors.top: parent.bottom
                height: 1
                color: "#E3E3E3"
            }
        }        
    }    

    Rectangle {
        id: listsCap

        anchors.top: menu_list.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: listsLabel.height + 16

        color: "#E0E0E0"

        Text {
            id: listsLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            font.pixelSize: fonts.f_size
            color: "grey"

            text: qsTrId("qtn_twitter_more_lists")
        }
    }

    ListView {
        id: lists_listview
        anchors.top: listsCap.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        model: mySubscribedListsModel
        delegate: ListsItem {
            width: lists_listview.width
            showAvatar: false
        }
        focus: true

        function itemCreated(index) {
            var refresh = (mylists_is_loading_more || mylists_loading) ? false : mylists_more_available ? true : false
            if (index == (count-1) && refresh) {
                dataHandler.moreSubscribedLists();
            }
        }

        footer: Item {
            id: tweet_footer
            width: lists_listview.width
            height: (mylists_is_loading_more || mylists_loading) ? 80: 0
            visible: (mylists_is_loading_more || mylists_loading) ? true : false

            BusyIndicator {
                anchors.centerIn: parent
                running: visible
                visible: lists_listview.count != 0 && (mylists_is_loading_more || mylists_loading) ? true : false
                platformStyle: BusyIndicatorStyle {inverted: false}
            }
        }

        BusyIndicator {
            anchors.centerIn: parent

            platformStyle: BusyIndicatorStyle {
                size: "large"
            }

            running: visible
            visible: lists_listview.count == 0 && (mylists_is_loading_more || mylists_loading) ? true : false
        }
    }

    ScrollDecorator {
        flickableItem: lists_listview
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            if (dataHandler.authenticatedUser() != "") {
                dataHandler.currentUser = dataHandler.authenticatedUser();
                dataHandler.updateProfileView(dataHandler.authenticatedUser());
                dataHandler.updateSubscribedLists();
            }
        }
    }

    Component.onDestruction: {
        dataHandler.cleanSubscribedLists();
    }
}
