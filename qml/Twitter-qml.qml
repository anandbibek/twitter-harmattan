import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.systeminfo 1.1
import "TwitterViewHistory.js" as ViewHistory

TwitterPageStackWindow {
    id: window
    objectName: "viewContainer"

    property int orientationLock: PageOrientation.LockPortrait

    property bool eventPageLaunched: false

    property bool unreadTweets: false
    property bool unreadMentions: false
    property bool unreadMessages: false

    signal showHomePage
    signal showMentionsTab
    signal showMessagesTab
    signal refresh
    signal saveCurrentTweetId
    signal restoreCurrentTweetId(int index)

    function homePage() {
        if (!pageStack.busy) {
            ViewHistory.clearToBeginning();
            pageStack.pop(null, true);
            showHomePage();
        }
    }

    function clearNewMessages() {
        window.unreadMessages = false
    }

    function clearNewMentions() {
        window.unreadMentions = false
    }

    function mentionsTab() {
        showMentionsTab();
    }

    function messagesTab() {
        showMessagesTab();
    }

    function backToMain() {
//        if (!pageStack.busy) {
            ViewHistory.clearToBeginning();
            pageStack.pop(null, true);
//        }
    }

    function startPage(source) {
        ViewHistory.clear();
        pageStack.clear();
        ViewHistory.push(source, dataHandler.currentUser, dataHandler.currentTweetId, dataHandler.currentListId, dataHandler.currentListName, eventPageLaunched, dataHandler.currentSearchString);
        pageStack.push(Qt.createComponent(source));
    }

    function startEventPage(mainPage, eventPage) {
        ViewHistory.clear();
        pageStack.clear();
        ViewHistory.push(mainPage, dataHandler.currentUser, dataHandler.currentTweetId, dataHandler.currentListId, dataHandler.currentListName, eventPageLaunched, dataHandler.currentSearchString);
        eventPageLaunched = true;
        ViewHistory.push(eventPage, dataHandler.currentUser, dataHandler.currentTweetId, dataHandler.currentListId, dataHandler.currentListName, eventPageLaunched, dataHandler.currentSearchString);
        pageStack.push(Qt.createComponent(eventPage));
        pageStack.insert(0,Qt.createComponent(mainPage));
    }

    function nextPage(source, eventPageLaunch) {
        if (!pageStack.busy) {
            if (ViewHistory.viewName(ViewHistory.count()-1) == source &&
                ViewHistory.tweetId(ViewHistory.count()-1) == dataHandler.currentTweetId &&
                ViewHistory.username(ViewHistory.count()-1).toLowerCase() == dataHandler.currentUser.toLowerCase()) {
                // Trying to open same page again
                return null;
            }
            if (eventPageLaunch) {
                eventPageLaunched = true;
            }
            ViewHistory.push(source, dataHandler.currentUser, dataHandler.currentTweetId, dataHandler.currentListId, dataHandler.currentListName, eventPageLaunched, dataHandler.currentSearchString);
            var item = pageStack.push(Qt.createComponent(source));
            if (pageStack.depth > 3) {
                pageStack.remove(1,1);
            }
            return item;
        }
        return null
    }

    function replacePage(source) {
        if (!pageStack.busy) {
            ViewHistory.pop();
            ViewHistory.push(source, dataHandler.currentUser, dataHandler.currentTweetId, dataHandler.currentListId, dataHandler.currentListName, eventPageLaunched, dataHandler.currentSearchString);
            return pageStack.replace(Qt.createComponent(source));
        }
        return null
    }

    function prevPage() {
        if (ViewHistory.count() > 2) {
            eventPageLaunched = ViewHistory.eventPage(ViewHistory.count()-2);
            dataHandler.currentUser = ViewHistory.username(ViewHistory.count()-2);
            dataHandler.currentTweetId = ViewHistory.tweetId(ViewHistory.count()-2);
            dataHandler.currentListId = ViewHistory.listId(ViewHistory.count()-2);
            dataHandler.currentListName = ViewHistory.listName(ViewHistory.count()-2);
            dataHandler.currentSearchString = ViewHistory.searchString(ViewHistory.count()-2);
        }
        ViewHistory.pop();
        pageStack.pop();
        if (pageStack.depth == 2 && ViewHistory.count() > 2) {
            pageStack.insert(1, Qt.createComponent(ViewHistory.viewName(ViewHistory.count()-2)));
        }
    }

    function showError(error) {
        if (!hide_timer.running) {
            error_label.text = error;
            error_dialog.state = "show";
            hide_timer.start();
        }
    }

    function refreshModels() {
        refresh();
    }

    function prepareCleanup() {
        saveCurrentTweetId();
    }

    function doCleanup() {
        gc();
    }

    function restorePosition(index) {
        restoreCurrentTweetId(index);
    }

    function onNetworkAvailableChanged(connected) {
        if (connected && platformWindow.active) {
            dataHandler.startSyncTimer();
        } else {
            dataHandler.stopSyncTimer();
        }
    }

    Connections {
        target: platformWindow
        onActiveChanged: {
            dataHandler.setIsOnFullscreen(platformWindow.active)
            if (platformWindow.active) {
                dataHandler.emitUpdateTimestamp();
                dataHandler.startSyncTimer();
            } else {
                dataHandler.stopSyncTimer();
                gc();
            }
        }
        onVisibleChanged: {
            dataHandler.setVisible(platformWindow.visible)
        }
    }

    Timer {
        id: hide_timer
        interval: 2000
        onTriggered: {
            error_dialog.state = "";
        }
    }

    StatusBar {
        id: statusbar_height
        visible: false
    }

    BorderImage {
        id: error_dialog
        y: statusbar_height.height + 80 // align below the navi pane
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        height: 80
        opacity: 0.0
        source: "image://theme/meegotouch-notification-event-background"
        border.top: 20
        border.left: 20
        border.right: 20
        border.bottom: 20
        z: 1000
        Text {
            id: error_label
            anchors.fill: parent
            anchors.margins: 16
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            font.pixelSize: 24
            color: "white"
        }
        states: State {
            name: "show";
            PropertyChanges { target: error_dialog; opacity: 1.0 }
        }

        transitions: Transition {
            from: ""
            to: "show"
            reversible: true
            PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutExpo; duration: 500 }
        }
    }

    Component.onCompleted: {
        var startTab = dataHandler.startTab();
        console.log("startTab",startTab);
        var startView = dataHandler.startView();
        if (startView != "MainView.qml" && startView != "SignInView.qml") {
            eventPageLaunched = true;
        }

        ViewHistory.push(startView, dataHandler.currentUser, dataHandler.currentTweetId, dataHandler.currentListId, dataHandler.currentListName, eventPageLaunched, dataHandler.currentSearchString);
        pageStack.push(Qt.createComponent(startView));

        if( startTab == "Messages" ) {
            showMessagesTab()
        } else if( startTab == "Mentions" ) {
            showMentionsTab()
        }
    }
}

