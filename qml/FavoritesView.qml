import QtQuick 1.1
import com.nokia.meego 1.0

TweetsView {
    showFavorites: true

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateUserFavorites(dataHandler.currentUser, loadedUser != dataHandler.currentUser);
            loadedUser = dataHandler.currentUser;
            dataHandler.updateProfileSubView(dataHandler.currentUser);
        }
    }
}
