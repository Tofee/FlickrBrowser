import QtQuick 2.0

import "../Singletons"

Item {
    id: delegateItem

    height: delegateColumn.height
    width: delegateColumn.width

    property bool isSelected
    property string imageSource
    property alias imageHeight: delegateImage.height
    property alias imageWidth: delegateImage.width
    property alias imageFillMode: delegateImage.fillMode

    property alias showText: delegateText.visible
    property string textContent
    property alias textPixelSize: delegateText.font.pixelSize

    property string flickrSyncStatus: "unknown"

    property alias hoverEnabled: collectionCellMouseArea.hoverEnabled
    property alias containsMouse: collectionCellMouseArea.containsMouse

    signal clicked(variant mouse)
    signal doubleClicked(variant mouse)

    Connections {
        target: FlickrBrowserApp.contextualFilter
        onFilterChanged: {
            delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.textContent });
        }
    }
    Component.onCompleted: {
        delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.textContent });
    }

    Column {
        id: delegateColumn
        width: delegateImage.width

        Image {
            id: delegateImage
            width: 180
            height: 180

            fillMode: Image.PreserveAspectCrop
            source: imageSource
            sourceSize: Qt.size(delegateImage.width, delegateImage.height);

            Rectangle {
                id: selectionRect
                anchors.fill: parent
                opacity: 0.3
                color: "blue"

                visible: delegateItem.isSelected
            }
            Rectangle {
                visible: flickrSyncStatus !== "unknown"
                x: 10; y: 10
                width: 10; height: width
                color: (flickrSyncStatus === "onlyLocal") ? "red" :
                       (flickrSyncStatus === "onlyFlickr") ? "blue" : "green"
                border.color: "black"
                border.width: 2
                radius: width*0.5
            }
        }
        Text {
            id: delegateText
            anchors.left: parent.left
            anchors.right: parent.right

            color: "white"

            text: textContent
            wrapMode: Text.Wrap
        }
    }
    MouseArea {
        id: collectionCellMouseArea
        anchors.fill: delegateColumn

        onClicked: {
            delegateItem.clicked(mouse);
        }
        onDoubleClicked: { // warning: this means a click has been issued just before
            delegateItem.doubleClicked(mouse);
        }
    }
}
