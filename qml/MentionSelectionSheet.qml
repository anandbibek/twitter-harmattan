import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: recipientselector

    Fonts { id: fonts }

    property bool isLoading: searchProfiles ? (searchview_searching_profiles ? true : false) : (peoplelistview_is_refreshing ? true : false)
    property bool searchProfiles: false

    function openSoftwareInputPanel() {
        text_input.text = "";
        searchProfiles = false;
        text_input.forceActiveFocus();
        text_input.platformOpenSoftwareInputPanel();
    }

    signal clicked(string screenName)

    title: Image {
        id: searchBar

        anchors.left: parent.left
        anchors.right: parent.right

        source: "../images/twitter-top-pane-light.png"

        TextField {
            id:text_input

            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: cancelButton.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            placeholderText: qsTrId("qtn_twitter_search_users_hint")
            inputMethodHints: Qt.ImhNoPredictiveText

            platformStyle: TextFieldStyle {
                background: "qrc:///resources/images/twitter-textedit.png"
                backgroundSelected: "qrc:///resources/images/twitter-textedit-selected.png"
                backgroundCornerMargin: 18
                paddingRight: clearButton.width + 8
                baselineOffset: 0
                textColor: "#333333"
            }

            platformSipAttributes: SipAttributes {
                actionKeyLabel: text_input.text.length > 0 ? qsTrId("qtn_twitter_search_command") : qsTrId("qtn_twitter_done_command")
                actionKeyHighlighted: true
                actionKeyEnabled: true
            }

            Keys.onReturnPressed:{
                if (text_input.text.length > 0) {
                    dataHandler.searchProfiles(text_input.text);
                    searchProfiles = true;
                }
                search_listview.focus = true;
                text_input.platformCloseSoftwareInputPanel();
            }
        }
        Image {
            id: clearButton
            anchors.right: text_input.right
            anchors.rightMargin: 8
            anchors.verticalCenter: text_input.verticalCenter
            source: text_input.text.length > 0 ? "image://theme/icon-m-input-clear" : "image://theme/icon-m-common-search"
            visible: search_in_progress_indicator.visible ? false : true
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
        BusyIndicator {
            id: search_in_progress_indicator
            anchors.verticalCenter: text_input.verticalCenter
            anchors.right: text_input.right
            anchors.rightMargin: 16

            platformStyle: BusyIndicatorStyle {
                size: "medium"
            }

            running: visible
            visible: (searchProfiles && searchview_searching_profiles) ? true : false
        }

        TwitterButton {
            id: cancelButton

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16

            width: 130
            inverted: false
            text: qsTrId("qtn_twitter_cancel_command")

            onClicked: {
                recipientselector.close();
            }
        }
    }

    content: Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: recipientselector.height - searchBar.height

        Rectangle {
            anchors.fill: parent
            color: "#F2F2F2"
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
            }
        }

        Item {
            id: list_area
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: parent.width
            clip:true

            RefreshingHeader {
                id: refreshing_header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: (peoplelistview_is_refreshing && search_listview.count != 0)  ? 72 : 0
                visible: (peoplelistview_is_refreshing && search_listview.count != 0) ? true : false
            }

            ListView {
                id: search_listview
                anchors.top: refreshing_header.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                //maximumFlickVelocity:1500
                model: searchProfiles ? myProfileSearchModel : myFollowerModel

                pressDelay: 100

                header: Rectangle {
                    width: recipientselector.width
                    height: visible ? 80 : 0
                    visible: (!searchProfiles && text_input.text.length > 0) ? true : false
                    color: "#F2F2F2"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16

                        font.pixelSize: fonts.c_size
                        font.bold: true
                        color: "#00C0FF"

                        text: qsTrId("qtn_twitter_search_command") + " \""+text_input.text+"\""
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dataHandler.searchProfiles(text_input.text);
                            searchProfiles = true;
                        }
                    }
                    //separator
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: "#E3E3E3"
                    }
                }

                delegate: RecipientItem {
                    width: recipientselector.width
                    filter: text_input.text
                    onClicked: {
                        recipientselector.clicked(peoplelistitem_twittername);
                        recipientselector.close();
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 32
                    color: "#999999"
                    font.pixelSize: 50
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter

                    text: { searchProfiles ?
                                qsTrId("qtn_twitter_no_people_results").arg("\""+text_input.text+"\"")
                            :
                                qsTrId("qtn_twitter_no_followers")
                    }
                    visible: (!isLoading && search_listview.count == 0) ? true : false
                }
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
                visible: (peoplelistview_is_refreshing && search_listview.count == 0) ? true : false
            }
        }
    }

    Component.onCompleted: {
        dataHandler.updateFollowersView(dataHandler.authenticatedUser());
    }
}
