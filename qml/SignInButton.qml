import QtQuick 1.1
import com.nokia.meego 1.0

Button {
    property bool isBlue: false

    platformStyle: ButtonStyle{
        textColor: isBlue ? "white" : "black"

        background: isBlue ? "qrc:///resources/images/twitter-button-sign-in-blue.png" : "qrc:///resources/images/twitter-button-sign-in-grey.png"
        pressedBackground: "qrc:///resources/images/twitter-button-sign-in-pressed.png"
    }
}
