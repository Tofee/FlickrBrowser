import QtQuick 2.0

import "../Singletons"

Item {
    id: delegateItem

    height: delegateColumn.height
    width: delegateColumn.width

    property bool selected
    property string icon
    property string title
    property alias imageHeight: delegateImage.height
    property alias imageWidth: delegateImage.width
    property alias imageFillMode: delegateImage.fillMode
    property alias textPixelSize: delegateText.font.pixelSize

    signal clicked(variant mouse)
    signal doubleClicked(variant mouse)

    Connections {
        target: FlickrBrowserApp.contextualFilter
        onFilterChanged: {
            delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.title });
        }
    }
    Component.onCompleted: {
        delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.title });
    }

    Column {
        id: delegateColumn
        width: delegateImage.width

        Image {
            id: delegateImage
            height: 180
            width: 180

            fillMode: Image.PreserveAspectCrop
            source: icon

            Rectangle {
                id: selectionRect
                anchors.fill: parent
                opacity: 0.3
                color: "blue"

                visible: delegateItem.selected
            }
        }
        Text {
            id: delegateText
            anchors.left: parent.left
            anchors.right: parent.right

            color: "white"

            text: title
            wrapMode: Text.Wrap
        }
    }
    SingleDoubleClickMouseArea {
        id: collectionCellMouseArea
        anchors.fill: delegateColumn

        onRealClicked: {
            delegateItem.clicked(mouse);
        }
        onRealDoubleClicked: {
            delegateItem.doubleClicked(mouse);
        }
    }
}
