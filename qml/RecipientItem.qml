import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container
    property bool showFollower: true
    property string filter: ""
    property bool match: (peoplelistitem_twittername != undefined && (peoplelistitem_twittername.toLowerCase().indexOf(filter.toLowerCase()) != -1 || peoplelistitem_realname.toLowerCase().indexOf(filter.toLowerCase()) != -1)) ? true : false

    height: (filter == "" || match) ? 80 : 0
    visible: (filter == "" || match) ? true : false

    Fonts { id: fonts }

    signal clicked

    Rectangle {
        anchors.fill: parent
        color: "#DDDDDD"
        visible: mouse_area.containsMouse ? true : false
    }

    BasicProfileHeader {
        anchors.fill: parent

        avatarURL: peoplelistitem_avatar != undefined ? peoplelistitem_avatar : ""
        avatarHeight: 50
        twitterName: peoplelistitem_twittername != undefined ? peoplelistitem_twittername : ""
        firstName: peoplelistitem_realname != undefined ? peoplelistitem_realname : ""
        listView: container.ListView.view
    }

    Rectangle {
        id: background

        anchors.fill: parent

        opacity: 0
    }

    //separator
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#E3E3E3"
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        onClicked: {
            container.clicked();
        }
    }
}
