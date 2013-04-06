import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right

    height: Math.max(label.height, textField.height)

    property alias labelText: label.text
    property alias text: textField.text
    property alias platformPreedit: textField.platformPreedit
    property alias textColor: field_style.textColor

    property alias actionButtonText: sipAttributes.actionKeyLabel

    property alias activeFocus: textField.activeFocus

    signal enterPressed

    function forceActiveFocus(){
        textField.forceActiveFocus()
    }

    Image {
        id: arrowLabel

        source: "../images/twitter-editor-inputfield-panel-background-selected.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        mirror: LayoutMirroring.enabled ? true : false

        visible: textField.activeFocus
    }

    Text {
        id: label

        color: textField.activeFocus ? "#ffffff" : "d0d0d0"
        font.pixelSize: 24
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: arrowLabel.right
        anchors.leftMargin: 8
    }

    TextField {
        id: textField

        anchors.verticalCenter: parent.verticalCenter

        anchors.left: label.right
        anchors.right: parent.right

        platformSipAttributes: SipAttributes {
            id: sipAttributes
            actionKeyLabel: qsTrId("qtn_twitter_next_command")
            actionKeyHighlighted: true
            actionKeyEnabled: true
        }

        Keys.onReturnPressed: {
            root.enterPressed()
        }

        platformStyle: TextFieldStyle {
            id: field_style
            background: ""
            backgroundSelected: ""
            backgroundDisabled: ""
            backgroundError: ""
        }
    }


}
