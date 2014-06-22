import QtQuick 2.0

import "../Singletons"

Item {
    property string pageItemId
    property ListModel pageModel
    property string pageModelType: "Generic"

    signal remoteModelChanged();

    // forward the signal if necessary
    Connections {
        target: FlickrBrowserApp
        onRemoteModelChanged: if( pageItemId === itemId ) remoteModelChanged();
    }
}
