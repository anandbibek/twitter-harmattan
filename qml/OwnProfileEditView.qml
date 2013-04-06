import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: root
     
    orientationLock: window.orientationLock
     
    anchors.fill: parent

    Fonts { id: fonts }

    property bool imageChanged: false
    property bool validValues: nameEditLine.valid && urlEditLine.valid && locationEditLine.valid && bioTextField.valid

    ImagePickerDialog {
        id: imagePickerDialog

        onImagePicked: {
            root.imageChanged = true;
            profilePhotoImage.source = imageUrl
        }
    }

    Column {
        id: profile_header
        width: parent.width
        Image {
            id: topBar

            anchors.left: parent.left
            anchors.right: parent.right

            source: "../images/twitter-top-pane.png"

            TwitterButton {
                id: cancelButton

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16

                width: 130
                inverted: false
                text: qsTrId("qtn_twitter_cancel_command")
                textColor: "white"

                onClicked: window.prevPage()
            }

            BorderImage {
                id: saveButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16
                width: 130
                height: 51
                border.top: 20
                border.left: 20
                border.right: 20
                border.bottom: 20
                source: "../images/twitter-top-button-blue"+(!root.validValues?"-disabled":(ok_area.containsMouse?"-pressed":""))+".png"
                Text {
                    id: okButtonText
                    anchors.centerIn: parent
                    font.weight: Font.Bold
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 24
                    color: "#FFFFFF"
                    text: qsTrId("qtn_twitter_save_command")
                }

                MouseArea {
                    id: ok_area
                    anchors.fill: parent
                    onClicked: {
                        if (root.validValues) {
                            dataHandler.updateAccountData(nameEditLine.text, urlEditLine.text, locationEditLine.text, bioTextField.text);
                            if (root.imageChanged) {
                                dataHandler.updateAccountImage(profilePhotoImage.source);
                            }
                        }
                    }
                }
            }
        }


        MouseArea {
            anchors.left: parent.left
            anchors.right: parent.right

            height: childrenRect.height

            onClicked: imagePickerDialog.open()

            Rectangle{
                anchors.fill: parent
                id: background
                color: "#202020"
                visible: parent.containsMouse ? true : false
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.leftMargin: 16

                height: 96

                spacing: 16

                MaskedItem {
                    id: maskedItem
                    anchors.verticalCenter: parent.verticalCenter

                    width: height
                    height: 80

                    mask: Image {
                        sourceSize.width: maskedItem.width
                        sourceSize.height: maskedItem.height
                        width: maskedItem.width
                        height: maskedItem.height
                        source: "../images/twitter-avatar-image-mask.png"
                    }

                    Image {
                        id: profilePhotoImage
                        anchors.fill: parent
                        cache:  false
                        smooth: true
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        source: profileview_profile_image_url
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTrId("qtn_twitter_change_photo_command")
                    font.pixelSize: 24
                    color: fonts.d_color
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: anchors.leftMargin

            color: "#202020"

            height: 1
        }
    }

    Flickable {
        anchors.top: profile_header.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        flickableDirection: Flickable.VerticalFlick
        contentWidth: edit_fields.width
        contentHeight: edit_fields.height
        clip: true
        pressDelay: 100

        Column {
            id: edit_fields
            width: root.width
            property string capt: qsTrId("qtn_twitter_profile_name")
            LayoutMirroring.enabled: dataHandler.isRightToLeftText(capt)
            LayoutMirroring.childrenInherit: true

            ProfileEditLine {
                id: nameEditLine

                property bool valid: text.length + platformPreedit.length < 21

                labelText: qsTrId("qtn_twitter_profile_name")+":"
                text: profileview_firstname
                textColor: valid ? "#ffffff": "#FF0000"

                onEnterPressed: urlEditLine.forceActiveFocus()
            }
            ProfileEditLine {
                id: urlEditLine

                property bool valid: text.length + platformPreedit.length < 101

                labelText: qsTrId("qtn_twitter_profile_url")+":"
                text: profileview_url
                textColor: valid ? "#ffffff": "#FF0000"

                onEnterPressed: locationEditLine.forceActiveFocus()
            }
            ProfileEditLine {
                id: locationEditLine

                property bool valid: text.length + platformPreedit.length < 31

                labelText: qsTrId("qtn_twitter_profile_location")+":"
                text: profileview_location
                textColor: valid ? "#ffffff": "#FF0000"

                onEnterPressed: bioEditLine.forceActiveFocus()
            }

            Item {
                id: bioEditLine

                width: root.width
                height: Math.max(label.height, bioTextField.height)

                property alias activeFocus: bioTextField.activeFocus

                function forceActiveFocus(){
                    bioTextField.forceActiveFocus()
                }

                Image {
                    id: bioArrowLabel

                    source: "../images/twitter-editor-inputfield-panel-background-selected.png"
                    anchors.verticalCenter: label.verticalCenter
                    anchors.left: parent.left
                    mirror: LayoutMirroring.enabled ? true : false

                    visible: bioTextField.activeFocus
                }

                Text {
                    id: label

                    color: bioTextField.activeFocus ? "#d0d0d0" : "grey"

                    anchors.top: bioTextField.top
                    anchors.left: bioArrowLabel.right
                    anchors.topMargin: 14
                    anchors.leftMargin: 8
                    font.pixelSize: 24
                    text: qsTrId("qtn_twitter_profile_bio")+":"
                }

                TextArea {
                    id: bioTextField

                    property bool valid: text.length + platformPreedit.length < 161

                    anchors.verticalCenter: parent.verticalCenter

                    anchors.left: label.right
                    anchors.right: parent.right

                    text: profileview_description

                    platformSipAttributes: SipAttributes {
                        actionKeyHighlighted: false
                    }

                    platformStyle: TextAreaStyle {
                        textColor: bioTextField.valid ? "#ffffff": "#FF0000"
                        background: ""
                        backgroundSelected: ""
                        backgroundDisabled: ""
                        backgroundError: ""
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            nameEditLine.forceActiveFocus();
        }
    }
}
