import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: root

    property alias cancelButtonText: cancelButton.text
    property alias okButtonText: okButton.text

    property alias titleText: titleLabel.text
    property alias messageText: messageLabel.text

    Fonts { id: fonts }

    content: Column {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 16
        Text {
            id: titleLabel

            anchors.left: parent.left
            anchors.right: parent.right

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: fonts.c_size + 2
            font.bold: true
            color: "white"
            wrapMode: Text.WordWrap

            visible: text != "" ? true : false
        }

        Text {
            id: messageLabel

            anchors.left: parent.left
            anchors.right: parent.right

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: fonts.c_size - 2
            color: "white"
            wrapMode: Text.WordWrap

            visible: text != "" ? true : false
        }

        Item {
            width: parent.width
            height: 32
        }

        TwitterButton {
            id: okButton

            anchors.horizontalCenter: parent.horizontalCenter

            isDialogButton: true
            isPositiveAnswer: true
            onClicked: {
                root.accept();
            }
        }

        TwitterButton {
            id: cancelButton

            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTrId("qtn_twitter_cancel_command")
            isDialogButton: true
            onClicked: {
                root.reject();
            }
        }
    }
}
