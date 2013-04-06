import QtQuick 1.1
import com.nokia.meego 1.0


MouseArea {
    id: rootItem
    property string message_text: msg_text != undefined ? msg_text : ""
    property string message_created_at: created_at != undefined ? created_at : ""
    property bool message_received: received ? true : false
    property int preferredHeight: container.height
    Fonts { id: fonts }

    height: preferredHeight

    function getHeight(r) {
        var h = 0;
        for( var i=0; i<r.children.length; ++i) {
            var child = r.children[i]
            if( child.visible ) {
                h += child.height
            }
        }
        return h
    }

    Rectangle{
        anchors.fill: parent
        id: background
        color: "#DDDDDD"
        visible: parent.containsMouse ? true : false
    }

    Column {
        id: container

        anchors.left: parent.left
        anchors.right: parent.right

        height: rootItem.getHeight(container)

        Item {
            id: marginTop
            width: parent.width
            height: 16
        }
        Text {
            id: messageText

            anchors.left: message_received ? parent.left : undefined
            anchors.right: message_received ? undefined : parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            width: Math.min(textWidthCalc.width, 358)

            font.pixelSize: fonts.b_size
            wrapMode: Text.Wrap
            color: message_received ? "#333333" : "#999999"
            textFormat: Text.RichText

            text: message_text

            onLinkActivated: {
                dataHandler.linkClicked(link);
            }

        }
        Text {
            id: textWidthCalc
            font.pixelSize: fonts.b_size
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            visible: false
            text: message_text
        }
        Item {
            width: parent.width
            height: 16
        }
        Text {
            id: messageTime
            anchors.left: message_received ? messageText.left : undefined
            anchors.right: message_received ? undefined : messageText.right

            font.pixelSize: fonts.d_size
            horizontalAlignment: message_received ? Text.AlignLeft : Text.AlignRight
            color: "#A5A5A5"

            text: dataHandler.createConversationTimeString(message_created_at)

            Connections {
                target: dataHandler
                onUpdateTimestamp: {
                    messageTime.text = dataHandler.createConversationTimeString(message_created_at);
                }
            }
        }
        Item {
            id: marginBottom
            width: parent.width
            height: 16
        }
        Rectangle {
            id: tweet_separator_line
            width: parent.width
            height: 1
            color: "#E3E3E3"
        }
    }
}
