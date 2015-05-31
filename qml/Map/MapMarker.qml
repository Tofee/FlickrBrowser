import QtQuick 2.0

Loader {
    id: markerLoader

    property int nbPhotos: 0
    property point anchorPoint: item ? item.anchorPoint : Qt.point(0,0);

    signal showRelatedPhotos()

    Component {
        id: pinMarker
        Image {
            property point anchorPoint: Qt.point(16,32);

            source: Qt.resolvedUrl("../images/marker.png");
            height: 32; width: 50
        }
    }

    Component {
        id: multipleMarker
        Image {
            property point anchorPoint: Qt.point(32,32);

            source: Qt.resolvedUrl("../images/marker-multiple.svg");
            sourceSize: Qt.size(64,64);
            height: 64; width: 64

            Text {
                anchors.centerIn: parent
                text: markerLoader.nbPhotos;
            }
        }
    }

    sourceComponent: nbPhotos > 1 ? multipleMarker : pinMarker

    MouseArea {
        anchors.fill: parent
        onClicked: {
            markerLoader.showRelatedPhotos();
        }
    }
}

