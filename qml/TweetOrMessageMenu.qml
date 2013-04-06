import QtQuick 1.1
import com.nokia.meego 1.0


ActionMenu {
    id: root

    signal directMessageClicked
    signal tweetClicked

    property alias imageSrc: image.source
    property alias labelTxt: label.text

    property alias firstButtonLabelText: firstButtonLabel.text
    property alias secondButtonLabelText: secondButtonLabel.text

    contentArea: Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Item {
            anchors.left: parent.left
            anchors.right: parent.right

            height: 80

            Image {
                id: image

                anchors.left: parent.left
//				anchors.verticalCenter: parent.verticalCenter

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 8
                anchors.bottomMargin: anchors.topMargin

                width: height
                cache: false
                source: ""
                smooth: true

                visible: source != ""
            }

            Text {
                id: label

                anchors.left: image.visible ? image.right : parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8

                color: fonts.b_color
                font.pixelSize: fonts.b_size + 4
                font.bold: true

                text: ""
            }


            TwitterImageButton {
                pressedImage: "../images/twitter-icon-menu-close-pressed.png"
                unpressedImage: "../images/twitter-icon-menu-close.png"

                anchors.right: parent.right

                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    root.close()
                }
            }

        }
        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnButton {
                Text {
                    id: firstButtonLabel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    text: qsTrId("qtn_twitter_tweet_command")

                    color: fonts.c_color
                    font.pixelSize: fonts.c_size
                    font.bold: true
                }

                onClicked: root.tweetClicked()
            }
            ColumnButton {
                Text {
                    id: secondButtonLabel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    text: qsTrId("qtn_twitter_message_command")

                    color: fonts.c_color
                    font.pixelSize: fonts.c_size
                    font.bold: true
                }

                onClicked: root.directMessageClicked()
            }
        }
    }
}
