import QtQuick 1.1
import com.nokia.meego 1.0


Item {
    id: root

    height: tweet_name.height + tweet_desc.height + timestamp_text.height + 40 //margins

    property bool isListItem: true

    Image {
        id: user_image
        anchors.left:parent.left
        anchors.leftMargin:16
        anchors.top:parent.top
        anchors.topMargin:16
        width: 50
        height: 50
        cache:  false
        source: image_url != undefined ? image_url : ""
        smooth: !timelinedelegate.ListView.view.moving
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (isListItem) {
                    dataHandler.currentUser = name;
                    window.nextPage("ProfileView.qml");
                }
            }
        }        
    }

    Text {
        id: tweet_name
        anchors.top:parent.top
        anchors.topMargin:16
        anchors.left:user_image.right
        anchors.leftMargin:16
        text: name != undefined ? name : ""

        font.bold: true
        color: "#e0e0e0"
        font.pixelSize: fonts.c_size - 4
    }
    Item {
        id: retweet_item
        visible: retweeted_name != ""
        anchors.verticalCenter: tweet_name.verticalCenter
        anchors.left: tweet_name.right
        anchors.leftMargin: 8
        height: visible? retweet_text.height : 0
        width: retweet_image.width + retweet_text.width + retweet_text.anchors.leftMargin
        Image {
            id: retweet_image
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/twitter-icon-list-tiny-retweeted.png"
            smooth: !timelinedelegate.ListView.view.moving
            visible: retweeted_name != "" ? true : false
        }
        Text {
            id: retweet_text
            anchors.left: retweet_image.right
            anchors.leftMargin: 4
            anchors.verticalCenter: retweet_image.verticalCenter
            color: "#999999"
            font.pixelSize: fonts.c_size - 4
            font.bold: true
            text: qsTrId("qtn_twitter_retweet_by").arg(retweeted_name)
            visible: retweeted_name != "" ? true : false
        }
    }
    Image {
        anchors.right: parent.right
        anchors.verticalCenter: tweet_name.verticalCenter
        anchors.rightMargin: 16
        source: "../images/twitter-icon-list-small-retweeted.png"
        visible: (root.isListItem && retweeted_by_me_id != "") ? true : false
    }
    Text {
        id: tweet_desc
        anchors.top:tweet_name.bottom
        anchors.left:tweet_name.left
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 16
        wrapMode: Text.Wrap
        textFormat: Text.PlainText
        text: status_text != undefined ? status_text : ""
        font.pixelSize: fonts.c_size - 2        
        color: "#e0e0e0"
    }
    Item {
        id:location_item
        anchors.top:tweet_desc.bottom
        anchors.topMargin: 4
        anchors.left:tweet_name.left
        anchors.right: parent.right
        anchors.rightMargin: 16

        visible: root.isListItem

        Image {
            id: location_image
            anchors.left: parent.left
            anchors.verticalCenter: timestamp_text.verticalCenter
            source: (place != undefined && place != "") ? "../images/twitter-icon-list-tiny-location.png" : ""
        }
        Text {
            id: timestamp_text
            visible: (timestamp != undefined && timestamp == "") ? false : true
            anchors.top: parent.top
            anchors.left:location_image.right
            anchors.leftMargin: location_image.width
            text: timestamp != undefined ? dataHandler.createTimeString(timestamp) : ""
            color: "#999999"
            font.pixelSize: fonts.d_size

            Connections {
                target: dataHandler
                onUpdateTimestamp: {
                    timestamp_text.text = dataHandler.createTimeString(timestamp);
                }
            }
        }
        Image {
            anchors.right: parent.right
            anchors.verticalCenter: timestamp_text.verticalCenter
            source: "../images/twitter-icons-list-small-favourite.png"
            visible: (favorited != undefined && favorited) ? true : false
        }
    }
}
