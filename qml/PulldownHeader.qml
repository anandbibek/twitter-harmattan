import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    color: "darkgrey"

    Fonts { id: fonts }

    Image {
        id: arrow_image
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        source: "../images/twitter-icon-refresh-arrow.png"
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.left: arrow_image.right
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        font.pixelSize: fonts.f_size
        color: fonts.f_color
        text: qsTrId("qtn_twitter_pull_down_refresh")
    }
}
