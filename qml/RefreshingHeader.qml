import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    color: "#101010"

    Fonts { id: fonts }

    Text {
        id: refresh_header_caption
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        font.pixelSize: fonts.f_size
        color: fonts.f_color
        text: qsTrId("qtn_twitter_refreshing_contents")
    }
    BusyIndicator {
        id:refresh_animation
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        running: parent.visible
        platformStyle: BusyIndicatorStyle {inverted: true}
    }

}
