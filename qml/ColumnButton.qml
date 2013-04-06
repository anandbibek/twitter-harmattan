import QtQuick 1.1
import com.nokia.meego 1.0




BorderImage {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right

    signal clicked

    width: 150
    height: 70

    border.top: 21
    border.left: 21
    border.right: 21
    border.bottom: 21

    MouseArea{
        id: mouseArea

        anchors.fill: parent

        onClicked: root.clicked()
    }

    source: {
        if(!parent)
            return ""

        var pressed = mouseArea.pressed ? "-pressed" : ""

        if(parent.children.length == 1){
            return "../images/twitter-list-frame" + pressed + ".png"
        }

        if(parent.children[0] == root){
            return "../images/twitter-list-frame" + pressed + "-top.png"
        }else if(parent.children[parent.children.length - 1] == root){
            return "../images/twitter-list-frame" + pressed + "-bottom.png"
        }else{
            return "../images/twitter-list-frame" + pressed + "-center.png"
        }
    }
}

