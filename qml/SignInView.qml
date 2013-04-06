import QtQuick 1.1
import com.nokia.meego 1.0

TwitterPage {
    id: mainview

    orientationLock: window.orientationLock

    Fonts {
        id: fonts
    }

    TopPane {
        id: topPane
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        Image {
            anchors.centerIn: parent

            source: "../images/twitter_logo_with_bird.png"
        }
    }

    Rectangle {
        id: signInInfo

        anchors.top: topPane.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true

        color: "#101010"

        Column {
            id: signInInfoColumn

            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 32

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.leftMargin: 24
                anchors.rightMargin: 24

                text: qsTrId("qtn_twitter_first_run_intro")
                wrapMode: Text.WordWrap

                font.pixelSize: fonts.c_size
                color: "#ffffff"

                horizontalAlignment: Text.AlignHCenter
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 16

                SignInButton {
                    text: qsTrId("qtn_twitter_first_run_sign_in")

                    onClicked: {
                        dataHandler.createNewAccount()
                    }
                }

                SignInButton {
                    isBlue: true

                    text: qsTrId("qtn_twitter_first_run_sign_up")

                    onClicked: {
                        dataHandler.linkClicked("https://mobile.twitter.com/signup")
                    }
                }
            }
        }
    }
}
