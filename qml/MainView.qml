import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: mainview

    orientationLock: window.orientationLock

    width: parent.width
    height: parent.height

    Fonts { id: fonts }

    Connections {
        target: dataHandler
        onNewTweets: {
            window.unreadTweets = true;
        }
        onNewMentions: {
            window.unreadMentions = true;
        }
        onNewMessages: {
            if (tabGroup.currentTab != tab_messages) {
                window.unreadMessages = true;
            }
        }
    }

    Connections {
        target: window
        onShowHomePage: {
            console.log("onShowHomePage")
            tabGroup.currentTab = tab_timeline;
        }
        onRefresh: {
            dataHandler.updateTimelineView(true);
            dataHandler.updateMentionsView(true);
            dataHandler.updateMessagesView(true);
        }
        onShowMessagesTab: {
            tabGroup.currentTab = tab_messages;
        }

        onShowMentionsTab: {
            tabGroup.currentTab = tab_mentions;
        }
    }

    tools: ToolBarLayout {
        id: toolbar
        anchors.fill: parent
        ButtonRow {
            TabButton {
                iconSource: "../images/twitter-icon-navigationbar-timeline"+(window.unreadTweets?"-new":"")+".png";
                tab: tab_timeline
                onCheckedChanged: {
                    if (checked && window.unreadTweets) {
                        window.homePage();
                    }
                }
            }
            TabButton {
                iconSource: "../images/twitter-icon-navigationbar-mentions"+(window.unreadMentions?"-new":"")+".png";
                tab: tab_mentions
                onCheckedChanged: {
                    if (checked && window.unreadMentions) {
                        window.mentionsTab();
                    }
                }
            }
            TabButton {
                iconSource: "../images/twitter-icon-navigationbar-messages"+(window.unreadMessages?"-unread":"")+".png";
                tab: tab_messages
                onCheckedChanged: {
                    if (checked) {
                        window.unreadMessages = false;
                    }
                }
            }
            TabButton {
                iconSource: "../images/twitter-icon-navigationbar-search.png";
                tab: tab_search
                onCheckedChanged: {
                    if (checked) {
                        // reset search query
                        dataHandler.currentSearchString = "";
                    }
                }
            }
            TabButton {
                iconSource: "../images/twitter-icon-navigationbar-more.png";
                tab: tab_more
            }
        }
    }

    TabGroup {
        id: tabGroup

        currentTab: tab_timeline

        onCurrentTabChanged: {
            if( currentTab == tab_mentions ) {
                dataHandler.clearMentionNotifications()
            } else if( currentTab == tab_messages ) {
                dataHandler.clearMessageNotifications()
            }
        }

        TimelineView{
            id: tab_timeline
        }
        MentionsView{
            id: tab_mentions
        }
        MessagesView{
            id: tab_messages
        }
        SearchHistoryView{
            id: tab_search
        }
        MenuView{
            id: tab_more
        }
    }
}
