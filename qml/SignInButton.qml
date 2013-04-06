import QtQuick 1.1
import com.nokia.meego 1.0

Button {
    property bool isBlue: false

    platformStyle: ButtonStyle{
        textColor: "white"

        background: isBlue ? "../images/twitter-button-sign-in-blue.png" : "../images/twitter-button-sign-in-grey.png"
        pressedBackground: "../images/twitter-button-sign-in-pressed.png"
    }
}
