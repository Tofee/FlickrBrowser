import QtQuick 2.0
import QtLocation 5.2

import "../Singletons"

MapQuickItem {
    id: geotaggerMapItem
    property Map parentMap

    anchorPoint: Qt.point(16,16);

    sourceItem: Image {
        source: Qt.resolvedUrl("../images/marker-target.svg");
        height: 32; width: 32
    }

    Component.onCompleted: FlickrBrowserApp.currentTargetOnMap = geotaggerMapItem.coordinate;
    Component.onDestruction: FlickrBrowserApp.currentTargetOnMap = null;
}

