import QtQuick 1.1
import com.nokia.meego 1.0

TweetsView {
    showList: true

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateListTweets(dataHandler.currentListId, loadedUser != dataHandler.currentListId);
            loadedUser = dataHandler.currentListId;
        }
    }
}
