import QtQuick 1.1
import com.nokia.meego 1.0
import "StringUtils.js" as StringUtils

Item {
    id: container

    property bool showAvatar: true

    height: 80

    Fonts { id: fonts }

    Rectangle {
        anchors.fill: parent
        id: background
        color: "#DDDDDD"
        visible: profile_mouse_area.containsMouse || list_mouse_area.containsMouse ? true : false
    }

    BasicProfileHeader {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: isprivate ? privateImage.left : parent.right
        avatarURL: avatar != undefined && showAvatar ? avatar : ""
        avatarHeight: showAvatar ? 50 : 0
        twitterName: name != undefined ? name : ""
        firstName: desc != undefined ? StringUtils.reduceWhitespace(desc) : ""
        buttonItem: privateImage.visible ? privateImage : null
        listView: container.ListView.view
    }

    Image {
        id: privateImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16
        visible: isprivate ? true : false
        source: "../images/twitter-icon-list-locked.png"
    }

    MouseArea {
        id: profile_mouse_area
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 74
        onClicked: {
            dataHandler.currentUser = screenName;
            window.nextPage("ProfileView.qml");
        }
    }
    MouseArea {
        id: list_mouse_area
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: profile_mouse_area.right
        anchors.right: parent.right

        onClicked: {
            dataHandler.currentUser = screenName;
            dataHandler.currentListId = id;
            dataHandler.currentListName = name;
            window.nextPage("ListTweetsView.qml");
        }
    }

    Rectangle {
        id: tweet_separator_line
        width: container.width
        anchors.top: container.bottom
        height: 1
        color: "#E3E3E3"
    }

    Component.onCompleted: {
        ListView.view.itemCreated(index);
    }
}
