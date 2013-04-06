import QtQuick 1.1
import com.nokia.meego 1.0

TweetsView {
    showFavorites: false

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateUserTweets(dataHandler.currentUser, loadedUser != dataHandler.currentUser);
            loadedUser = dataHandler.currentUser;
            dataHandler.updateProfileSubView(dataHandler.currentUser);
        }
    }
}
