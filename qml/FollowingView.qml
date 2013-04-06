import QtQuick 1.1
import com.nokia.meego 1.0

PeopleListView {
    showFollowers: false

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            dataHandler.updateFollowingView(dataHandler.currentUser, loadedUser != dataHandler.currentUser);
            loadedUser = dataHandler.currentUser;
            dataHandler.updateProfileSubView(dataHandler.currentUser);
        }
    }
}
