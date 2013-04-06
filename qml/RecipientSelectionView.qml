import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: recipientselector
     
    orientationLock: window.orientationLock
     
    anchors.fill: parent

    Fonts { id: fonts }

    property bool isLoading: peoplelistview_is_refreshing ? true : false

    Image {
        id: searchBar

        anchors.left: parent.left
        anchors.right: parent.right

        source: "../images/twitter-top-pane.png"

        TextField {
            id:text_input

            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: cancelButton.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            placeholderText: qsTrId("qtn_twitter_search_command")
            inputMethodHints: Qt.ImhNoPredictiveText

            platformStyle: TextFieldStyle {
                background: "../images/twitter-textedit.png"
                backgroundSelected: "../images/twitter-textedit-selected.png"
                backgroundCornerMargin: 18
                paddingRight: clearButton.width + 8
                baselineOffset: 0
                textColor: "#333333"
            }

            platformSipAttributes: SipAttributes {
                actionKeyLabel: qsTrId("qtn_twitter_done_command")
                actionKeyHighlighted: true
                actionKeyEnabled: true
            }

            Keys.onReturnPressed:{
                text_input.platformCloseSoftwareInputPanel();
                text_input.activeFocus = false;
            }
        }
        Image {
            id: clearButton
            anchors.right: text_input.right
            anchors.rightMargin: 8
            anchors.verticalCenter: text_input.verticalCenter
            source: text_input.text.length > 0 ? "image://theme/icon-m-input-clear" : "image://theme/icon-m-common-search"
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -25
                anchors.bottomMargin: -25
                anchors.rightMargin: -25
                onPressed: {
                    text_input.text = "";
                    mouse.accepted = false;
                }
            }
        }

        TwitterButton {
            id: cancelButton

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16

            width: 130
            inverted: false
            text: qsTrId("qtn_twitter_cancel_command")
            textColor: "white"

            onClicked: window.prevPage()
        }
    }

    Item {
        id: list_area
        anchors.top: searchBar.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width
        clip:true

        RefreshingHeader {
            id: refreshing_header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: (isLoading && search_listview.count != 0) ? 60 : 0
            visible: (isLoading && search_listview.count != 0) ? true : false
        }

        ListView {
            id: search_listview
            anchors.top: refreshing_header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true
            //maximumFlickVelocity:1500
            model: myFollowerModel

            pressDelay: 100

            delegate: RecipientItem {
                width: recipientselector.width
                filter: text_input.text
                onClicked: {
                    dataHandler.prepareComposeTo(peoplelistitem_twittername, peoplelistitem_avatar, peoplelistitem_realname);
                    window.replacePage("MessageComposeView.qml");
                }
            }

            focus: true
        }

        ScrollDecorator {
            flickableItem: search_listview
        }

        BusyIndicator {
            anchors.centerIn: parent
            platformStyle: BusyIndicatorStyle {
                size: "large"
            }
            running: visible
            visible: (isLoading && search_listview.count == 0) ? true : false
        }

    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
        }
    }

    Component.onCompleted: {
        dataHandler.updateFollowersView(dataHandler.authenticatedUser());
    }
}
