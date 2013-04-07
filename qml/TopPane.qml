import QtQuick 1.1
import com.nokia.meego 1.1


Image {
    source: screen.currentOrientation == Screen.Portrait ? "../images/twitter-top-pane.png"
                                                         : "../images/twitter-top-pane-landscape.png"
}
