import QtQuick 2.0
import QtLocation 5.2

MapQuickItem {
    id: photoMapItem
    property Map parentMap
    property alias sourceImage: photo.source
    property alias imageWidth: photo.width
    property alias imageHeight: photo.height
    anchorPoint: Qt.point(0, 0);

    sourceItem: Image {
        id: photo

        MouseArea {
            anchors.fill: parent
            onClicked: {
                parentMap.overlayMapItem = null;
                parentMap.removeMapItem(photoMapItem);
            }
        }
    }
}

