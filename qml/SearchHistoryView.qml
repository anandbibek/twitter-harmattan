import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: searchview
     
    orientationLock: window.orientationLock

    anchors.fill: parent

    property string item_fontcolor: fonts.c_color
    property int item_fontsize: fonts.c_size

    Fonts { id: fonts }

    TopPane {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        focus: true

        TextField {
            id:text_input
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin:16
            anchors.right: parent.right
            anchors.rightMargin:16
            placeholderText: qsTrId("qtn_twitter_seach_topic_name_hint")
            property bool autoClear: true
            property bool hasBeenEdited: false
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
                text_input.platformCloseSoftwareInputPanel();
                toolbar.focus = true;
                if(text_input.text.length > 0) {
                    dataHandler.currentSearchString = text_input.text;
                    window.nextPage("SearchView.qml");
                }
            }

            Keys.onReleased: {
                if(text.length >=140) {
                    text = text.substring(0, 140);
                    cursorPosition = 140;
                }
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
    }

    Connections {
        target: inputContext
        onSoftwareInputPanelVisibleChanged: {
            if (inputContext.softwareInputPanelVisible) {
                searchHistoryList.visible = true;
            } else {
                searchHistoryList.visible = false;
            }
        }
    }

    ListView {
        id: searchHistoryList
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        pressDelay: 100
        visible: false

        model: mySearchHistoryModel
        delegate: TrendingItem {
            width: searchHistoryList.width
            filter: text_input.text
        }
    }

    Flickable {
        id: flickable_area
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        contentWidth: width
        contentHeight: col.height

        visible: searchHistoryList.visible ? false : true

        Column {
            id: col
            Rectangle {
                id: saved_searches_header

                width: searchview.width
                height: 40
                color: "#E6E6E6"
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#CCCCCC"
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    text: qsTrId("qtn_twitter_search_saved_head")
                    color: "#666666"
                    font.pixelSize: item_fontsize -2
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Repeater {
                id: saved_searches
                model: mySavedSearchesModel
                delegate: TrendingItem {
                    width: searchview.width
                }
            }
            Rectangle {
                id: trends_header
                width: searchview.width
                height: 40
                color: "#E6E6E6"
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#CCCCCC"
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    text: qsTrId("qtn_twitter_first_run_trends")
                    color: "#666666"
                    font.pixelSize: item_fontsize -2
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Repeater {
                id: trends
                model: myTrendsModel
                delegate: TrendingItem {
                    width: searchview.width
                }
            }
            Item {
                height: trends_is_loading ? 16 : 0
                width: searchview.width
            }
        }
    }

    BusyIndicator {
        x: (flickable_area.x + flickable_area.width - width)/2
        y: (flickable_area.y + flickable_area.height - height + saved_searches_header.height + saved_searches.height + trends_header.height)/2

        platformStyle: BusyIndicatorStyle {
            size: "large"
        }
        running: visible
        visible: trends_is_loading && trends.count == 0 && saved_searches.count == 0 ? true : false
    }

    ScrollDecorator {
        flickableItem: flickable_area
    }

    onStatusChanged: {
        if (status == PageStatus.Active && mainview.status != PageStatus.Deactivating) {
            dataHandler.updateSearchHistory(50);
            dataHandler.updateTrendingTopics();
            if (!savedsearches_is_loading) {
                dataHandler.updateSavedSearches();
            }
        } else if (status == PageStatus.Activating) {
            text_input.text = "";
        }
    }
}


