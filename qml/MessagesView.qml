import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: container
     
    orientationLock: window.orientationLock
     
    anchors.fill: parent

    Fonts { id: fonts }

    property int pull_down_header_height: 320
    property bool isLoading: messagesview_loading ? true : false
    property bool messagesview_refresh_after_sending: false

    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        composeTweet: false

        onComposeClicked: tweetOrMessageMenu.open()
        onDoubleClicked: conversations.positionViewAtBeginning();
        BusyIndicator {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            platformStyle: BusyIndicatorStyle {
                size: "medium"
                inverted: true
            }
            running: visible
            visible: messagesview_refresh_after_sending ? true : false
        }
    }

    TweetOrMessageMenu {
        id: tweetOrMessageMenu

        labelTxt: qsTrId("qtn_twitter_compose_new")

        onDirectMessageClicked: {
            dataHandler.prepareComposeTo("", "", "")
            window.nextPage("RecipientSelectionView.qml")
            tweetOrMessageMenu.close()
        }

        onTweetClicked: {
            window.nextPage("ComposeView.qml")
            tweetOrMessageMenu.close()
        }
    } 

    RefreshingHeader {
        id: refreshing_header

        anchors.top: topBar.bottom

        anchors.left: parent.left
        anchors.right: parent.right
        height: isLoading ? 60 : 0
        visible: isLoading ? true : false
    }

    ListView {
        id: conversations
        anchors.top: refreshing_header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right


        clip: true
        //maximumFlickVelocity:1500

        pressDelay: 100

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32
            color: "#ffffff"
            font.pixelSize: 50
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter

            text: qsTrId("qtn_twitter_no_direct_messages")
            visible: (!isLoading && conversations.count == 0) ? true : false
        }

        PulldownHeader {
            id: pull_down_header
            width: parent.width
            height: pull_down_header_height
            y: parent.visibleArea.yPosition > 0 ? -height : -(parent.visibleArea.yPosition * Math.max(parent.height, parent.contentHeight)) - height
            visible: !conversations.moving || isLoading ? false : true
        }

        ScrollDecorator {
            flickableItem: conversations
        }

        model: myMessageModel ? myMessageModel : 0
        delegate: MessagesListDelegate {
            width: conversations.width
        }

        Connections {
            target: conversations.visibleArea
            onYPositionChanged: {
                if (conversations.flicking)
                    return;

                // reset last refresh time update flag
                var contentYPos = conversations.visibleArea.yPosition * Math.max(conversations.height, conversations.contentHeight);

                // reload content
                if ( ((!inPortrait&&contentYPos < -100)||(inPortrait&&contentYPos < -120)) && conversations.moving ) {
                    dataHandler.releaseMouse(conversations.objectName);
                    conversations.positionViewAtBeginning();
                    dataHandler.updateMessagesView();
                }
            }
        }
        Component.onCompleted: {
            objectName = "MessagesView_list" + Math.random();
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.emitUpdateTimestamp();
            if (conversations.count == 0) {
                dataHandler.updateMessagesView();
            }
        }
    }
}
