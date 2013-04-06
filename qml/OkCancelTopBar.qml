import QtQuick 1.1
import com.nokia.meego 1.0

TopPane {
    id: root
    property alias cancelText: cancelButton.text
    property alias okText: okButtonText.text

    property bool okButtonEnabled: true

    signal cancelClicked
    signal okClicked

    TwitterButton {
        id: cancelButton

        isTopButton: true

        text: qsTrId("qtn_twitter_cancel_command")

        textColor: "white"

        onClicked: root.cancelClicked()

        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 130
    }

    // Not using default button because of text color issues
    BorderImage {
        id: okButton
        anchors.right: parent.right
        anchors.rightMargin:16
        anchors.verticalCenter: parent.verticalCenter
        width: 130
        height: 51
        border.top: 20
        border.left: 20
        border.right: 20
        border.bottom: 20
        source: "../images/twitter-top-button-blue"+(!root.okButtonEnabled?"-disabled":(ok_area.containsMouse?"-pressed":""))+".png"
        Text {
            id: okButtonText
            anchors.centerIn: parent
            font.weight: Font.Bold
            font.capitalization: Font.MixedCase
            font.pixelSize: 24
            color: "#FFFFFF"
            visible: root.okButtonEnabled ? true : false
            text: qsTrId("qtn_twitter_send_command")
        }
        Text {
            id: okButtonDisabledText
            anchors.centerIn: parent
            font.weight: Font.Bold
            font.capitalization: Font.MixedCase
            font.pixelSize: 24
            color: "#B2B2B4"
            visible: root.okButtonEnabled ? false : true
            text: okButtonText.text
        }
        MouseArea {
            id: ok_area
            anchors.fill: parent
            onClicked: {
                if (root.okButtonEnabled) {
                    root.okClicked();
                }
            }
        }
    }
}
