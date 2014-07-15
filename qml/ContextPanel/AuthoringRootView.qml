import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Singletons"

// Display the actions for the root browser view.
Column {
    Button {
        width: parent.width
        text: "Logout"
        onClicked: FlickrBrowserApp.logout();
    }
}
