import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: root
    property int loadingCount: 0
    signal imagePicked(string imageUrl, bool isPortrait, real aspectRatio)

    platformStyle: DialogStyle {
        leftMargin: 0
        rightMargin: 0
    }

    onStatusChanged: {
        switch(status) {
            case DialogStatus.Opening:
                dataHandler.queryPhotosModel();
                break;
        }
    }

    content: Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right

        height: screen.displayWidth > screen.displayHeight ? screen.displayWidth : screen.displayHeight

        color: "black"

        MouseArea {
            anchors.fill: parent
        }

        Item {
            id: imagePickerTopBar

            y: statusbar_height.height

            anchors.left: parent.left
            anchors.right: parent.right
            height: 80

            TwitterButton {
                textColor: "white"
                text: qsTrId("qtn_twitter_done_command")
                width: parent.width / 3

                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    root.close()
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                running: visible
                visible: root.loadingCount > 0 ? true : false
                platformStyle: BusyIndicatorStyle {
                    inverted: true
                }
            }

            Rectangle {
                color: "#202020"

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                height: 2
            }
        }

        GridView {
            id: photoSelectionGridView

            clip: true

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: imagePickerTopBar.bottom
            anchors.bottom: parent.bottom

            cellWidth: parent.width / 3 - 1
            cellHeight: cellWidth

            model: dataHandler.photosModel

            delegate: Image {
                x: 2
                y: 2

                sourceSize.width: photoSelectionGridView.cellWidth - 4
                sourceSize.height: (photoSelectionGridView.cellHeight - 4 ) * role_aspect_ratio
                width: photoSelectionGridView.cellWidth - 4
                height: photoSelectionGridView.cellHeight - 4

                rotation: role_orientation_portrait ? 90 : 0

                clip: true
                source: role_image_url
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: "#000000"
                    border.color: "#3C3C3C"
                    border.width: 1
                    visible: (parent.status == Image.Loading) ? true : false
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (parent.status == Image.Ready) {
                            console.log("image picked");
                            // role_orientation_portrait is boolean
                            root.imagePicked(parent.source, role_orientation_portrait, role_aspect_ratio);
                            root.close();
                        }
                    }
                }
                property bool isLoading: false
                onStatusChanged: {
                    if (status == Image.Loading) {
                        if (!isLoading) {
                            isLoading = true;
                            root.loadingCount = root.loadingCount + 1;
                        }
                    } else if (isLoading) {
                        isLoading = false;
                        root.loadingCount = root.loadingCount - 1;
                    }
                }
                Component.onDestruction: {
                    if (isLoading) {
                    root.loadingCount = root.loadingCount - 1;
                    }
                }
            }
            ScrollDecorator {
                flickableItem: photoSelectionGridView
            }
        }
    }//~Item
}//~Dialog
