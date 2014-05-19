import QtQuick 2.0
import QtQuick.Controls 1.1

import "FlickrAPI.js" as FlickrAPI

Item {
    id: flickrBrowserRoot

    property ListModel rootCollectionTreeModel;
    property ListModel rootPhotosetListModel;

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "black"
    }

    // Navigation pane
    NavigationPath {
        id: navigationPathItem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        onElementClicked: {
                navigationPathItem.pop();
                stackView.pop();
        }
    }

    // Main collection view
    StackView {
        id: stackView
        anchors.top: navigationPath.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        property NavigationPath navigationPath: navigationPathItem

        initialItem: CollectionCollectionGridPage {
            width: parent.width
            height: parent.height

            collectionTreeModel: rootCollectionTreeModel
            photoSetListModel: rootPhotosetListModel
        }
    }
}

