import QtQuick 1.1
import com.nokia.meego 1.0

TimelineView {
    showRetweetedByMe: true


    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateRetweetedByMeView();
        }
    }
}
