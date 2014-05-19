import QtQuick 2.0
import QtQuick.Controls 1.1
import "OAuthCore.js" as OAuth
import "DBAccess.js" as DBAccess
import "FlickrAPI.js" as FlickrAPI

Item {
    id: flickrBrowserRoot

    width: 360
    height: 360

    ListModel {
        id: rootCollectionTreeModel
    }
    ListModel {
        id: rootPhotosetListModel
    }

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

        initialItem: LoginPage {
            width: parent.width
            height: parent.height

            onAuthorised: {
                FlickrAPI.callFlickrMethod("flickr.collections.getTree", null, cb_collectionlist);
                FlickrAPI.callFlickrMethod("flickr.photosets.getList", [ [ "primary_photo_extras", "url_sq" ] ], cb_photosetlist);
            }

            function cb_collectionlist(response) {
                //console.log(JSON.stringify(response));
                var i;
                for( i=0; i<response.collections.collection.length; i++ ) {
                    rootCollectionTreeModel.append(response.collections.collection[i]);
                }

                stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                properties: {"collectionTreeModel": rootCollectionTreeModel, "photoSetListModel": rootPhotosetListModel}});
            }

            function cb_photosetlist(response) {
                //console.log(JSON.stringify(response));
                var i;
                for( i=0; i<response.photosets.photoset.length; i++ ) {
                    rootPhotosetListModel.append(response.photosets.photoset[i]);
                }
            }
        }
    }
}

