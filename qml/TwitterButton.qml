import QtQuick 1.1
import com.nokia.meego 1.0

Button {
    id: twitterButton
    property alias textColor: buttonStyle.textColor
    property alias inverted: buttonStyle.inverted

    property bool isTopButton: false
    property bool isBlueButton: false
    property bool isDialogButton: false
    property bool isPositiveAnswer: false

    platformStyle: ButtonStyle {
        id: buttonStyle

        inverted: true

        background: {
            if (isTopButton && isBlueButton) {
                return "../images/twitter-top-button-blue.png"
            } else if(isDialogButton) {
                if(isPositiveAnswer) {
                    return "image://theme/meegotouch-dialog-button-positive"
                }else{
                    return "image://theme/meegotouch-dialog-button-negative"
                }
            } else {            
                return "image://theme/meegotouch-sheet-button" + (inverted ? "-inverted" : "") + "-background"
            }
        }

        pressedBackground: {
            if (isTopButton && isBlueButton) {
                return "../images/twitter-top-button-blue-pressed.png"
            } else if(isDialogButton) {
                if(isPositiveAnswer) {
                    return "image://theme/meegotouch-dialog-button-positive-pressed"
                }else{
                    return "image://theme/meegotouch-dialog-button-negative-pressed"
                }
            } else {
                return "image://theme/meegotouch-sheet-button" + (inverted ? "-inverted" : "") + "-background-pressed"
            }
        }

        backgroundMarginTop: 20
        backgroundMarginBottom: 20
        textColor: "white"
    }

    Text {
        width: twitterButton.width - 24 // width - margins
        text: twitterButton.text
        font: twitterButton.font
        wrapMode: Text.NoWrap
        visible: false
        color: "white"

        property bool pendingScaleUpdate: false
        function scaleText() {
            if (paintedWidth == -1) {
                pendingScaleUpdate = true;
            } else {
                pendingScaleUpdate = false;
                twitterButton.font.pixelSize = 24; // reset size for updating paintedWidth
                twitterButton.font.pixelSize = Math.floor(24 * (paintedWidth > width ? width / paintedWidth : 1));
            }
        }
        onTextChanged: scaleText();
        onPaintedWidthChanged: {
            if (pendingScaleUpdate) {
                scaleText();
            }
        }
    }
}
