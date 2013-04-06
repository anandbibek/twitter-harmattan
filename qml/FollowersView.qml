import QtQuick 1.1
import com.nokia.meego 1.0

PeopleListView {
    showFollowers: true

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateFollowersView(dataHandler.currentUser, loadedUser != dataHandler.currentUser);
            loadedUser = dataHandler.currentUser;
            dataHandler.updateProfileSubView(dataHandler.currentUser);
        }
    }
}
