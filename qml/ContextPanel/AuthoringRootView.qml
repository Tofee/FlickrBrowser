import QtQuick 2.9
import QtQuick.Controls 2.2

import "../Singletons"

// Display the actions for the root browser view.
Column {
    Button {
        width: parent.width
        text: "Logout"
        onClicked: FlickrBrowserApp.logout();
    }
}
