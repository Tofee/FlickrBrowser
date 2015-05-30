import QtQuick 2.0
import QtQuick.Window 2.1

import org.flickrbrowser.services 1.0

Window {
    width: 900
    height: 550

    FlickrBrowser {
        anchors.fill: parent
    }

    Component.onCompleted: {
        show();
    }
}

