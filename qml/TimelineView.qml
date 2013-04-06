import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: timelineview

    orientationLock: window.orientationLock

    property bool showMentions: false
    property bool showRetweetedByMe: false

    anchors.fill: parent

    property int pull_down_header_height: 320

    property bool isLoading: ((!showMentions && (timelineview_is_refreshing || timelineview_is_catching_up)) || (showMentions && mentions_is_refreshing) || twitter_authenticating)? true : false

    Fonts { id: fonts }

    TopBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        onDoubleClicked: timeline_listview.positionViewAtBeginning();
    }

    Item {
        id: list_area
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip:true

        RefreshingHeader {
            id: refreshing_header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: isLoading ? 60 : 0
            visible: (isLoading && (timeline_listview.count != 0 || !showRetweetedByMe)) ? true : false
        }

        ListView {
            id: timeline_listview
            anchors.top: refreshing_header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true

            pressDelay: 100

            model: showMentions ? myMentionsModel : showRetweetedByMe ? myRetweetedModel : myTimelineModel
            delegate: TimelineItem {
                width: timeline_listview.width
            }
            focus: true

            section.property: "section_timestamp"
            section.criteria: ViewSection.FullString

            onFlickingChanged: {
                if (!flicking && visibleArea.yPosition <= 10) {
                    if (showMentions) {
                        window.unreadMentions = false;
                    } else if (!showRetweetedByMe) {
                        window.unreadTweets = false;
                    }
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

                text: showMentions ? qsTrId("qtn_twitter_no_mentions") : showRetweetedByMe ? qsTrId("qtn_twitter_no_retweets") : qsTrId("qtn_twitter_no_tweets")
                visible: (!isLoading && timeline_listview.count == 0) ? true : false
            }

            PulldownHeader {
                id: pull_down_header
                width: timeline_listview.width
                height: pull_down_header_height                
                y: timeline_listview.visibleArea.yPosition > 0 ? -height : -(timeline_listview.visibleArea.yPosition * Math.max(timeline_listview.height, timeline_listview.contentHeight)) - height
                visible: !timeline_listview.moving || isLoading ? false : true
            }

            function itemCreated(index) {
                var refresh = (timelineview_is_loading_more || isLoading) ? false : showMentions ? ( timelineview_more_mentions_available ? true : false ) : showRetweetedByMe ? (timelineview_more_retweets_available ? true : false) : timelineview_more_tweets_available ? true : false
                if (index == (count-1) && refresh) {
                    if (showMentions)
                        dataHandler.moreMentionsView();
                    else if (showRetweetedByMe)
                        dataHandler.moreRetweetedByMeView();
                    else
                        dataHandler.moreTimelineView();
                }
            }

            footer: Item {
                id: tweet_footer
                width: timeline_listview.width
                height: timelineview_is_loading_more ? 80 : 0
                visible: timelineview_is_loading_more ? true : false

                BusyIndicator {
                    anchors.centerIn: parent
                    running: visible
                    visible: !refreshing_header.visible && timelineview_is_loading_more ? true : false
                    platformStyle: BusyIndicatorStyle {inverted: false}
                }
            }

            Connections {
                target: timeline_listview.visibleArea
                onYPositionChanged: {
                    if (timeline_listview.flicking)
                        return;

                    // reset last refresh time update flag
                    var contentYPos = timeline_listview.visibleArea.yPosition * Math.max(timeline_listview.height, timeline_listview.contentHeight);

                    if (contentYPos <= 10) {
                        if (showMentions) {
                            window.unreadMentions = false;
                        } else if (!showRetweetedByMe) {
                            window.unreadTweets = false;
                        }

                        // reload content
                        if ( contentYPos < -120 && timeline_listview.moving ) {
                            dataHandler.releaseMouse(timeline_listview.objectName);
                            timeline_listview.positionViewAtBeginning();
                            if (showMentions) {
                                dataHandler.refreshMentionsView();
                            } else if (showRetweetedByMe) {
                                dataHandler.updateRetweetedByMeView();
                            } else {
                                dataHandler.refreshTimelineView();
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                objectName = "TimelineView_list" + Math.random();
            }
        }
        TwitterSectionScroller {
            listView: timeline_listview
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: visible
            visible: (isLoading && timeline_listview.count == 0 && showRetweetedByMe) ? true : false
            platformStyle: BusyIndicatorStyle {
                size: "large"
            }
        }
    }

    Connections {
        target: window
        onShowHomePage: {
            if (!showMentions && !showRetweetedByMe) {
                window.unreadTweets = false;
                timeline_listview.positionViewAtBeginning();
            }
        }

        onShowMentionsTab: {
            window.unreadMentions = false;
            timeline_listview.positionViewAtBeginning();
        }

        onShowMessagesTab: {
            window.unreadMessages = false;
            timeline_listview.positionViewAtBeginning();
        }
        onSaveCurrentTweetId: {
            if (!showMentions && !showRetweetedByMe) {
                var id = timeline_listview.model.get(timeline_listview.indexAt(25, timeline_listview.contentY + 25)).original_tweetid
                if (id.length > 0)
                    dataHandler.setCurrentVisibleTweetId(id);
            }
        }
        onRestoreCurrentTweetId: {
            if (!showMentions && !showRetweetedByMe) {
                console.debug("setting view in index:" + index);
                timeline_listview.positionViewAtIndex(index, ListView.Beginning);
            }
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconSource: "../images/twitter-icon-toolbar-back.png"
            onClicked: {
                window.prevPage();
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.emitUpdateTimestamp();
            if (showMentions && timeline_listview.count == 0) {
                dataHandler.updateMentionsView();
            }
        }
    }    

    Component.onDestruction: {
        if (showRetweetedByMe)
            dataHandler.cleanRetweetsView();
    }
}

