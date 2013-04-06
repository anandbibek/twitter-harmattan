import QtQuick 1.1
import com.nokia.meego 1.0



Rectangle {
    id: root

    property alias avatarURL: basicProfileHeader.avatarURL

    property alias twitterName: basicProfileHeader.twitterName
    property alias firstName: basicProfileHeader.firstName
    property alias showArrow: arrowImage.visible

    property alias imageHorizontalPadding: basicProfileHeader.imageHorizontalPadding

    signal clicked

	color: "#101010"

    height: 73 + 2 * 12

    Rectangle {
        anchors.fill: parent
        color: "#202020"
        visible: showArrow && mouse_area.containsMouse ? true : false
    }

    BasicProfileHeader {
        id: basicProfileHeader
        buttonItem: showArrow ? arrowImage : null
        anchors.fill: parent
    }

    Image {
        id: arrowImage

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: parent.height / 2 - width
        
        source: "../images/twitter-icon-drildown-arrow.png"
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
    }
}
