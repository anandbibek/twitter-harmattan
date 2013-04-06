import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container
    height: 80

    Fonts { id: fonts }

    Rectangle {
        anchors.fill: parent
        id: background
        color: "#202020"
        visible: mouse_area.containsMouse ? true : false
    }

    BasicProfileHeader {
        anchors.fill: parent
        avatarURL: peoplelistitem_avatar != undefined ? peoplelistitem_avatar : ""
        avatarHeight: 50
        twitterName: peoplelistitem_twittername != undefined ? peoplelistitem_twittername : ""
        firstName: peoplelistitem_realname != undefined ? peoplelistitem_realname : ""
        buttonItem: status.visible ? status : null
        listView: container.ListView.view
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        onClicked: {
            dataHandler.currentUser = peoplelistitem_twittername;
            window.nextPage("ProfileView.qml");
        }
    }
   
    TwitterImageButton {
        id: status

        pressedImage: "../images/twitter-icon-unfollow.png"
        unpressedImage: "../images/twitter-icon-follow.png"

        checkable: true
        checked: peoplelistitem_following ? true : false

        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        smooth: !container.ListView.view.moving
        visible: (peoplelistitem_twittername != undefined && (twitter_account_exists && peoplelistitem_twittername.toLowerCase() != dataHandler.authenticatedUser()) ? true : false)

        onClicked: {
            dataHandler.followProfile(peoplelistitem_twittername, !peoplelistitem_following);
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
