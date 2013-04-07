import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.location 1.1

Rectangle {
    id: tweetedit
    property alias placeholderText: placeholder.text
    property alias text: edit.text
    property string locationId: location.enableLocation ? locationLabel.placeIdString :  ""
    property alias cursorPosition: edit.cursorPosition
    property int initialHeight: 220
    property int textLenght: dataHandler.countTweetTextLength(edit.text + edit.platformPreedit, uploadImagesCount)

    property bool messagingMode: false
    property int uploadImagesCount: 0

    function openSoftwareInputPanel() {
        edit.forceActiveFocus();
        edit.platformOpenSoftwareInputPanel();
    }

    function select(start, end) {
        edit.select(start, end)
    }

    onStateChanged: uploadImagesCount = uploadImages.model.count;

    height: edit.height + controls.height + image_grid_area.height
    color: "#000000"
    clip: true

    Fonts { id: fonts }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        color: "#000000"
    }

    Text {
        id: placeholder
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16
        font.pixelSize: 20
        color: "#cccccc"
        opacity: 0
    }

    TextArea {
        id: edit
        anchors.left: parent.left
        anchors.right: messagingMode ? charsCounterMessagingMode.left : parent.right
        anchors.bottom: messagingMode ? parent.bottom : controls.top
        height: Math.max(initialHeight - (parent.state != "minimized" ? controls.height : 0) - (initialHeight != 220 ? image_grid_area.height : 0), implicitHeight)

        wrapMode: Text.Wrap

        platformStyle: TextAreaStyle {
            background: ""
            backgroundSelected: ""
            backgroundDisabled: ""
            backgroundError: ""
            textColor: "white"
        }

        platformSipAttributes: SipAttributes {
            actionKeyHighlighted: false
        }
    }

    Text {
        id: charsCounterMessagingMode

        visible: messagingMode

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 16
        anchors.bottomMargin: 16

        font.pixelSize: fonts.c_size + 2
        color: "#cccccc"

        text: dataHandler.getLocalizedInt(140 - tweetedit.textLenght)
    }

    Loader {
        id: mentionSelectionLoader

        onLoaded: {
            item.open();
            item.openSoftwareInputPanel();
        }

        function open() {
            if (status == Loader.Ready) {
                item.open();
                item.openSoftwareInputPanel();
            } else {
                mentionSelectionLoader.source = "MentionSelectionSheet.qml";
            }
        }
    }

    Connections {
        target: mentionSelectionLoader.item
        onClicked: {
            var appendString = "@" + screenName + " ";
            var newCursorPos = edit.cursorPosition + appendString.length;
            edit.text = edit.text.substring(0,edit.cursorPosition) +  appendString + edit.text.substring(edit.cursorPosition)
            tweetedit.openSoftwareInputPanel();
            edit.cursorPosition = newCursorPos;
        }
    }

    Rectangle {
        id: controls
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: image_grid_area.top
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        visible: (!messagingMode && parent.state != "minimized") ? true : false
        height: messagingMode ? 0 : 80 + (locationLabel.visible ? locationLabel.height + locationLabel.anchors.bottomMargin : 0)
        color: "black"

        Image {
            id: contacts
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            source: "../images/twitter-button-composer"+(contacts_area.containsMouse?"-pressed":"")+".png"
            Image {
                anchors.centerIn: parent
                source: "../images/twitter-icon-compose-user.png"
            }
            MouseArea {
                id: contacts_area
                anchors.fill: parent
                onPressed: {
                    mentionSelectionLoader.open();
                }
            }
        }
        Image {
            anchors.left: contacts.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            anchors.leftMargin: 16
            source: "../images/twitter-button-composer"+(images_area.containsMouse?"-pressed":"")+".png"
            Image {
                anchors.centerIn: parent
                source: "../images/twitter-icon-add-image"+(uploadImagesCount > 0?"-on":"")+".png"
            }
            MouseArea {
                id: images_area
                anchors.fill: parent
                onPressed: {
                    if (uploadImages.model.count == 0) {
                        imagePickerDialog.open();
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: contacts.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: fonts.c_size + 2
            color: "#ffffff"
            text: dataHandler.getLocalizedInt(140 - tweetedit.textLenght)
        }

        Text {
            id: locationLabel

            property string placeString: geo_location
            property string placeIdString: geo_id

            anchors.right: parent.right
            anchors.bottom: location.top
            anchors.rightMargin: 8
            anchors.bottomMargin: 8
            font.pixelSize: fonts.c_size
            color: "#ffffff"
            visible: false

            onPlaceStringChanged: {
                if (placeString != "") {
                    if (placeString != "error") {
                        text = qsTrId("qtn_twitter_tweet_location").arg(placeString);
                        locationLabel.visible = true;
                        location.enableLocation = true;
                    }
                    locationBusyIndicator.visible = false;
                }
            }
        }
        Image {
            id: location
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            anchors.rightMargin: 8
            source: "../images/twitter-button-composer"+(positionSource.positioningMethod != PositionSource.SatellitePositioningMethod?"-disabled": location_area.containsMouse?"-pressed":"")+".png"
            property bool enableLocation: false
            Image {
                anchors.centerIn: parent
                source: "../images/twitter-icon-compose-location" + (positionSource.positioningMethod != PositionSource.SatellitePositioningMethod?"-disabled" : location.enableLocation?"-on":"")+".png"
                visible: locationBusyIndicator.visible ? false : true
            }
            BusyIndicator {
                id: locationBusyIndicator
                anchors.centerIn: parent
                running: visible
                visible: false
            }
            PositionSource {
                id: positionSource
                updateInterval: 1000
                active: false
                onPositionChanged: {
                    positionSource.active = false;
                    dataHandler.getGeoLocation(positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);
                }
                Component.onCompleted: {
                    if (positionSource.positioningMethod != PositionSource.SatellitePositioningMethod) {
                        // Reset location
                        dataHandler.getGeoLocation("","");
                        location.enableLocation = false;
                        locationLabel.visible = false;
                    }

                }
            }
            MouseArea {
                id: location_area
                anchors.fill: parent
                onPressed: {
                    if (positionSource.positioningMethod == PositionSource.SatellitePositioningMethod) {
                        if (!location.enableLocation) {
                            positionSource.active = true;
                            locationBusyIndicator.visible = true;
                        } else {
                            // Reset location
                            dataHandler.getGeoLocation("","");
                            location.enableLocation = false;
                            locationLabel.visible = false;
                        }
                    }
                }
            }
            Connections {
                target: dataHandler
                onPositioningTermsRejected: {
                    // Reset controls and state to initial values, if terms were not accepted.
                    dataHandler.getGeoLocation("","");
                    positionSource.active = false;
                    location.enableLocation = false;
                    locationLabel.visible = false;
                    locationBusyIndicator.visible = false;
                }
            }
        }
    }

    states: [
        State {
            name: "minimized"
            PropertyChanges {
                target: edit
                height: 80
            }
            PropertyChanges {
                target: controls
                height: 0
            }
            PropertyChanges {
                target: placeholder
                opacity: 1
            }
            PropertyChanges {
                target: charsCounterMessagingMode
                opacity: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "minimized"; to: "*"
            ParallelAnimation {
                PropertyAnimation { target: edit; duration: 300; properties: "height"; easing.type: Easing.OutQuart }
                PropertyAnimation { target: controls; duration: 300; properties: "height"; easing.type: Easing.OutQuart }
            }
        },
        Transition {
            from: "*"; to: "minimized"
            ParallelAnimation {
                PropertyAnimation { target: edit; duration: 300; properties: "height"; easing.type: Easing.InOutQuart }
                PropertyAnimation { target: controls; duration: 300; properties: "height"; easing.type: Easing.InOutQuart }
            }
        }
    ]

    ImagePickerDialog {
        id: imagePickerDialog

        onImagePicked: {
            dataHandler.addUploadImage(imageUrl, isPortrait, aspectRatio);
            uploadImagesCount = uploadImages.model.count;
            edit.text = edit.text;
        }
    }

    Rectangle {
        id: image_grid_area
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: (uploadImagesCount > 0 && !inputVisible) ? 320 : 0
        clip: true
        color: "#000000"

        property bool inputVisible: false

        Connections {
            target: inputContext
            onSoftwareInputPanelVisibleChanged: {
                if (inputContext.softwareInputPanelVisible) {
                    image_grid_area.inputVisible = true;
                } else {
                    image_grid_area.inputVisible = false;
                }
            }
        }

        Grid {
            id: image_grid
            anchors.fill: parent
            anchors.topMargin: 16

            columns: 3
            spacing: 16
            Repeater {
                id: uploadImages
                model: tweetImageUploadModel
                delegate: Item {
                    width: (image_grid.width - 32) / 3
                    height: 120

                    Item {
                        anchors.centerIn: parent
                        width: height
                        height: 110
                        MaskedItem {
                            anchors.fill: parent
                            mask: Image {
                                sourceSize.width: parent.width
                                sourceSize.height: parent.height
                                width: parent.width
                                height: parent.height
                                source: "../images/twitter-gallery-image-mask.png"
                            }
                            Image {
                                sourceSize.width: parent.width
                                sourceSize.height: parent.height * role_aspect_ratio
                                width: parent.width
                                height: parent.height
                                x: role_orientation_portrait ? -45: 0
                                y: role_orientation_portrait ? 45: 0
                                fillMode: Image.PreserveAspectCrop
                                source: pic_url
                                rotation: role_orientation_portrait ? 90 : 0
                            }
                        }
                        Image {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            source: "../images/twitter-remove-image.png"
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    dataHandler.removeUploadImage(pic_url);
                                    uploadImagesCount = uploadImages.model.count;
                                    edit.text = edit.text;
                                }
                            }
                        }
                    }
                }
            }
            Item {
                width: (image_grid.width - 32) / 3
                height: 120
                Image {
                    anchors.centerIn: parent
                    source: "../images/twitter-gallery-button.png"
                    width: height
                    height: 110
                    MouseArea {
                        anchors.fill: parent
                        onClicked: imagePickerDialog.open();
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        dataHandler.refreshConfigurationData();
    }
}
