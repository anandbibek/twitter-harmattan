import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.location 1.1

TwitterPage {
    id: searchview
     
    orientationLock: window.orientationLock
     
    anchors.fill: parent

    property string placeholderText: qsTrId("qtn_twitter_search_command")

    property string search_text: dataHandler.currentSearchString

    property bool searchProfiles: tabGroup.currentTab==peopleTab
    property string item_fontcolor: fonts.c_color
    property int item_fontsize: fonts.c_size

    property bool saved: dataHandler.savedSearchId(text_input.text) != "" ? true : false

    property bool isLoadingFav: savedsearches_is_loading ? true : false
    property bool prevClicked: false
    onIsLoadingFavChanged: {
        saved = (dataHandler.savedSearchId(text_input.text) != "")
    }

    Fonts { id: fonts }

    TopPane {
        id: topbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        TextField {
            id:text_input

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin:16
            anchors.right: parent.right
            anchors.rightMargin:16
            placeholderText: qsTrId("qtn_twitter_search_command")
            text: search_text != "" ? search_text : placeholderText
            inputMethodHints: Qt.ImhNoPredictiveText

            platformStyle: TextFieldStyle {
                background: "../images/twitter-textedit.png"
                backgroundSelected: "../images/twitter-textedit-selected.png"
                backgroundCornerMargin: 18
                paddingRight: clearButton.width + 8
                baselineOffset: 0
                textColor: "black"
            }

            platformSipAttributes: SipAttributes {
                actionKeyLabel: text_input.text.length > 0 ? qsTrId("qtn_twitter_search_command") : qsTrId("qtn_twitter_done_command")
                actionKeyHighlighted: true
                actionKeyEnabled: true
            }

            Keys.onReturnPressed:{
                search_text = text_input.text
                if (tabGroup.currentTab==peopleTab) {
                    dataHandler.searchProfiles(search_text);
                } else if (tabGroup.currentTab == tweetsTab) {
                    dataHandler.searchTweets(search_text);
                } else if (tabGroup.currentTab == timelineTab) {
                    dataHandler.searchTimeline(search_text);
                } else if (tabGroup.currentTab == nearbyTab) {
                    positionSource.active = true;
                }
                dataHandler.updateSearchHistory(50);
                text_input.platformCloseSoftwareInputPanel();
                search_listview.focus = true;
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
            visible: searchProfiles ? searchview_searching_profiles ? true : false : positionSource.active ? true : searchview_searching_tweets ? true : false
        }
    }

    Connections {
        target: inputContext
        onSoftwareInputPanelVisibleChanged: {
            if (inputContext.softwareInputPanelVisible) {
                searchHistoryList.visible = true;                
            } else {
                searchHistoryList.visible = false;
                if (text_input.text == "") {
                    search_text = text_input.text
                    if (tabGroup.currentTab==peopleTab) {
                        dataHandler.searchProfiles(search_text);
                    } else if (tabGroup.currentTab == tweetsTab) {
                        dataHandler.searchTweets(search_text);
                    } else if (tabGroup.currentTab == timelineTab) {
                        dataHandler.searchTimeline(search_text);
                    } else if (tabGroup.currentTab == nearbyTab) {
                        positionSource.active = true;
                    }
                    search_listview.focus = true;
                } else {
                    text_input.text = search_text;
                }
            }
        }
    }

    ListView {
        id: searchHistoryList
        anchors.top: topbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        pressDelay: 100
        visible: false

        model: mySearchHistoryModel
        delegate: TrendingItem {
            width: searchHistoryList.width
            filter: text_input.text == "" ? "!"+query_item : text_input.text
            onClicked: {
                search_text = query_item;
                if (tabGroup.currentTab==peopleTab) {
                    dataHandler.searchProfiles(search_text);
                } else if (tabGroup.currentTab == tweetsTab) {
                    dataHandler.searchTweets(search_text);
                } else if (tabGroup.currentTab == timelineTab) {
                    dataHandler.searchTimeline(search_text);
                } else if (tabGroup.currentTab == nearbyTab) {
                    positionSource.active = true;
                }
                dataHandler.updateSearchHistory(50);
                text_input.platformCloseSoftwareInputPanel();
                search_listview.focus = true;
            }
        }
    }

    Rectangle {
        id: headertext
        anchors.top: topbar.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        height: 50
        color: "#242424"
        visible: searchHistoryList.visible ? false : true
        Row {
            Rectangle {
                width: twitter_account_exists ? headertext.width / 4 : headertext.width / 2
                height: headertext.height
                color: tabGroup.currentTab == tweetsTab ? "#505050" : "#242424"
                Text {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTrId("qtn_twitter_search_filter_all")
                    color: tabGroup.currentTab == tweetsTab ? "#FFFFFF" : "#929292"
                    font.pixelSize: item_fontsize - 4
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (tabGroup.currentTab != tweetsTab) {
                            positionSource.active = false;
                            dataHandler.searchTweets(search_text);
                            tabGroup.currentTab = tweetsTab;
                        }
                    }
                }
            }
            Rectangle {
                width: twitter_account_exists ? headertext.width / 4 : 0
                height: headertext.height
                color: tabGroup.currentTab == timelineTab ? "#505050" : "#242424"
                visible: twitter_account_exists ? true : false
                Text {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTrId("qtn_twitter_search_filter_timeline")
                    color: tabGroup.currentTab == timelineTab ? "#FFFFFF" : "#929292"
                    font.pixelSize: item_fontsize - 4
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (tabGroup.currentTab != timelineTab) {
                            positionSource.active = false;
                            dataHandler.searchTimeline(search_text);
                            tabGroup.currentTab = timelineTab;
                        }
                    }
                }
            }
            Rectangle {
                width: twitter_account_exists ? headertext.width / 4 : headertext.width / 2
                height: headertext.height
                color: tabGroup.currentTab == nearbyTab ? "#505050" : "#242424"
                Text {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTrId("qtn_twitter_search_filter_geo")
                    color: tabGroup.currentTab == nearbyTab ? "#FFFFFF" : "#929292"
                    font.pixelSize: item_fontsize - 4
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (tabGroup.currentTab != nearbyTab) {
                            positionSource.active = true;
                            tabGroup.currentTab = nearbyTab;
                        }
                    }
                }
            }
            Rectangle {
                width: twitter_account_exists ? headertext.width / 4 : 0
                height: headertext.height
                color: searchProfiles ? "#505050" : "#242424"
                visible: twitter_account_exists ? true : false
                Text {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTrId("qtn_twitter_search_filter_people")
                    color: searchProfiles ? "#FFFFFF" : "#929292"
                    font.pixelSize: item_fontsize - 4
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (tabGroup.currentTab != peopleTab) {
                            positionSource.active = false;
                            dataHandler.searchProfiles(search_text)
                            tabGroup.currentTab = peopleTab;
                        }
                    }
                }
            }
        }
    }

    Item {
        id: list_area
        anchors.top: headertext.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width
        clip:true
        visible: searchHistoryList.visible ? false : true

        Component {
            id: peopleItem
            PeopleListItem {
                width: searchview.width
            }
        }

        Component {
            id: tweetItem
            TimelineItem {
                width: searchview.width
            }
        }

        Component {
            id: profileResults
            ListView {
                delegate: peopleItem
                model: myProfileSearchModel
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 32
                    color: "#999999"
                    font.pixelSize: 50
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTrId("qtn_twitter_no_people_results").arg("\""+search_text+"\"")
                    property bool pendingScaleUpdate: false
                    function scaleText() {
                        if (paintedWidth == -1) {
                            pendingScaleUpdate = true;
                        } else {
                            pendingScaleUpdate = false;
                            font.pixelSize = 50; // reset size for updating paintedWidth
                            font.pixelSize = Math.floor(50 * (paintedWidth > width ? width / paintedWidth : 1));
                        }
                    }
                    onTextChanged: scaleText();
                    onPaintedWidthChanged: {
                        if (pendingScaleUpdate) {
                            scaleText();
                        }
                    }
                    visible: (!search_in_progress_indicator.visible && parent.count == 0) ? true : false
                }

                ScrollDecorator {
                    flickableItem: parent
                }

                function itemCreated(index) {
                    var refresh = (searchview_searching_profiles || searchview_searching_more_profiles) ? false : searchview_more_profiles_available ? true : false
                    if (index == (count-1) && refresh) {
                        dataHandler.searchMoreProfiles();
                    }
                }

                footer: Item {
                    width: searchview.width
                    height: searchview_searching_more_profiles ? 80: 0
                    visible: searchview_searching_more_profiles ? true : false

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: visible
                        visible: searchview_searching_more_profiles ? true : false
                        platformStyle: BusyIndicatorStyle {inverted: false}
                    }
                }
            }
        }

        Component {
            id: tweetResults
            ListView {
                delegate: tweetItem
                model: myTweetSearchModel
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 32
                    color: "#999999"
                    font.pixelSize: 50
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTrId("qtn_twitter_no_search_results").arg("\""+search_text+"\"")
                    property bool pendingScaleUpdate: false
                    function scaleText() {
                        if (paintedWidth == -1) {
                            pendingScaleUpdate = true;
                        } else {
                            pendingScaleUpdate = false;
                            font.pixelSize = 50; // reset size for updating paintedWidth
                            font.pixelSize = Math.floor(50 * (paintedWidth > width ? width / paintedWidth : 1));
                        }
                    }
                    onTextChanged: scaleText();
                    onPaintedWidthChanged: {
                        if (pendingScaleUpdate) {
                            scaleText();
                        }
                    }
                    visible: (!search_in_progress_indicator.visible && parent.count == 0) ? true : false
                }

                ScrollDecorator {
                    flickableItem: parent
                }

                function itemCreated(index) {
                    if (tabGroup.currentTab == tweetsTab || tabGroup.currentTab == nearbyTab) {
                        var refresh = (searchview_searching_tweets || searchview_searching_more_tweets) ? false : searchview_more_tweets_available ? true : false
                        if (index == (count-1) && refresh) {
                            dataHandler.searchMoreTweets();
                        }
                    }
                }

                footer: Item {
                    width: searchview.width
                    height: searchview_searching_more_tweets ? 80: 0
                    visible: searchview_searching_more_tweets ? true : false

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: visible
                        visible: searchview_searching_more_tweets ? true : false
                        platformStyle: BusyIndicatorStyle {inverted: false}
                    }
                }
            }
        }

        Loader {
            id: search_listview
            anchors.fill: parent
            focus: true
            visible: positionSource.active ? false : true
            sourceComponent: searchProfiles ? profileResults : tweetResults
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: false
        onPositionChanged: {
            positionSource.active = false;
            dataHandler.searchTweets(search_text, positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);
        }
    }
    Connections {
        target: dataHandler
        onPositioningTermsRejected: {
            // Reset controls and state to initial values, if terms were not accepted.
            dataHandler.searchTweets("");
            positionSource.active = false;
        }
    }

    TabGroup {
        id: tabGroup
        currentTab: tweetsTab
        PageStack {
            id: tweetsTab
        }
        PageStack {
            id: timelineTab
        }
        PageStack {
            id: nearbyTab
        }
        PageStack {
            id: peopleTab
        }
    }

    tools: Item {
        anchors.fill: parent
        ToolIcon {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            iconSource: "../images/twitter-icon-toolbar-back.png"
            onClicked: {
                prevClicked = true;
                window.prevPage();
            }
        }
        ToolIcon {
            anchors.centerIn: parent
            visible: twitter_account_exists ? true : false
            iconSource: saved ? "../images/twitter-icon-toolbar-favourite-marked.png" : "image://theme/icon-m-toolbar-favorite-unmark"
            onClicked: {
                if (!isLoadingFav) {
                    if (saved) {
                        dataHandler.deleteSearch(text_input.text);
                    } else {
                        dataHandler.saveSearch(text_input.text);
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.searchTweets(dataHandler.currentSearchString);
        }
        else if (status == PageStatus.Active) {
            dataHandler.updateSearchHistory(50);
            dataHandler.emitUpdateTimestamp();
        } else if (status == PageStatus.Inactive && prevClicked) {
            // reset search query
            dataHandler.currentSearchString = "";
        }
    }    
}
