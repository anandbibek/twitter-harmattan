import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    property alias avatarURL: avatarImage.source

    property alias twitterName: twitterNameLabel.text
    property alias firstName: firstNameLabel.text
    property alias avatarHeight: avatarImage.height
    property Item buttonItem: null
    property ListView listView: null
    property real imageHorizontalPadding: 12

    height: 73 + 12 * 2

    Item {
        id: avatar_item
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: avatarImage.width + root.imageHorizontalPadding * 2

        Image {
            id: avatarImage

            width: height

            anchors.verticalCenter: parent.verticalCenter

            x: root.imageHorizontalPadding
            cache: false
            smooth: listView != undefined ? !listView.moving : true
            visible: updatingProfileImage ? false : true
        }
        BusyIndicator {
            anchors.centerIn: avatarImage
            running: visible
            visible: updatingProfileImage ? true : false
            platformStyle: BusyIndicatorStyle {
                size: "medium"
            }
        }
    }

    Column{
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: avatar_item.right
        anchors.right: root.right
        spacing: 4
        Text {
            id: twitterNameLabel

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: root.buttonItem != undefined ? (root.width - buttonItem.x) + 16 : 16

            font.pixelSize: fonts.c_size
            font.bold: true
            color: "black"
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

        Text {
            id: firstNameLabel

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: root.buttonItem != undefined ? (root.width - buttonItem.x) + 16 : 16

            font.pixelSize: fonts.b_size - 2
            color: "#999999"
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }//~Column
}//~Row
