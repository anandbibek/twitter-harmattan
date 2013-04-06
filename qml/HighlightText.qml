import QtQuick 1.1
import com.nokia.meego 1.0

Flow {
    id: tweet_text

    property string text: ""
    property int fontSize: fonts.c_size+2
    property string fontColor: fonts.c_color
    property bool split: true
    property bool alignRight: false
    property int paintedHeight: childrenRect.height
    layoutDirection: alignRight || dataHandler.hasRightToLeftText(text) ? Qt.RightToLeft : Qt.LeftToRight
    function resetHighlight() {
        reset()
    }

    signal reset

    Repeater {
        model: split ? dataHandler.splitText(text, tweet_text.alignRight) : text.split()
        delegate: Text {
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            font.pixelSize: fontSize
            color: fontColor
            width: Math.min(width_calc.width, tweet_text.width)
            text: modelData

            onLinkActivated: {
                dataHandler.linkClicked(link);
                link_highlight.visible = false;
            }

            Text {
                id: width_calc
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.pixelSize: fontSize
                text: modelData == " " ? "i" : modelData // Hack since Text element cannot calculate width of space
                visible: false
            }

            Rectangle {
                id: link_highlight
                anchors.fill: parent
                anchors.margins: -4
                color: "#000000"
                radius: 5
                opacity: modelData.indexOf("<a href=") != -1 ? 0.5 : 0
                visible: false
            }

            Connections {
                target: tweet_text
                onReset: link_highlight.visible = false;
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    link_highlight.visible = true;
                    mouse.accepted = false;
                }
            }
        }
    }
}
