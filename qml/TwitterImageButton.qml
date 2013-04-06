import QtQuick 1.1
import com.nokia.meego 1.0


Image {
    property string unpressedImage: ""
    property string pressedImage: ""

    property bool checkable: false
    property bool checked: false

    signal clicked

    source: {
        var cond
        if(checkable){
            cond = checked
        }else{
            cond = mouseArea.pressed
        }
        return cond ? pressedImage : unpressedImage
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: {
            parent.clicked()
        }
    }
}
