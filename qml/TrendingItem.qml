import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root
    property string filter: ""
    property bool match: (filter != "" && query_item != undefined && query_item.indexOf(filter) != -1) ? true : false

    signal clicked

    height: (filter == "" || match) ? 80 : 0
    visible: (filter == "" || match) ? true : false

    width: parent.width
    Rectangle {
        anchors.fill: parent
        color: "#202020"
        visible: mouse_area.containsMouse ? true : false
    }
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        visible: filter == "" ? false : true
        Repeater {
            id: rep
            model: query_item != undefined && filter != "" ? query_item.split(filter) : 0
            delegate: Row {
                Text {
                    wrapMode: Text.Wrap
                    text: modelData != undefined ? modelData : ""
                    color: "#ffffff"
                    font.pixelSize: fonts.c_size -2
                    font.bold: true
                }
                Text {
                    wrapMode: Text.Wrap
                    text: filter
                    color: "#e0e0e0"
                    font.pixelSize: fonts.c_size -2
                    font.bold: true
                    visible: index == (rep.count - 1) ? false : true
                }
            }
        }
    }
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.Wrap
        text: query_item != undefined ? query_item : ""
        color: "#ffffff"
        font.pixelSize: fonts.c_size -2
        font.bold: true
        visible: filter == "" ? true : false
    }
    MouseArea {
        id: mouse_area
        anchors.fill: parent
        onClicked: {
            dataHandler.currentSearchString = query_item;
            window.nextPage("SearchView.qml");
            root.clicked();
        }
    } 
    Rectangle {
        width: parent.width
        anchors.top: parent.bottom
        height: 1
        color: "#808080"
    }
}
