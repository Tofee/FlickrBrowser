pragma Singleton

import QtQuick 2.0

Item {
    id: flickrBrowserAppSingleton

    signal collectionTreeChanged();
    signal photosetListChanged();

    property alias collectionTreeModel: rootCollectionTreeModel
    property alias photosetListModel: rootPhotosetListModel

    function fillCollectionTreeModel(jsonArray) {
        rootCollectionTreeModel.clear();

        var i;
        for( i=0; i<jsonArray.length; i++ ) {
            rootCollectionTreeModel.append(jsonArray[i]);
        }

        collectionTreeChanged();
    }

    function fillPhotosetListModel(jsonArray) {
        rootPhotosetListModel.clear();

        var i;
        for( i=0; i<jsonArray.length; i++ ) {
            rootPhotosetListModel.append(jsonArray[i]);
        }

        photosetListChanged();
    }

    ListModel {
        id: rootCollectionTreeModel
    }
    ListModel {
        id: rootPhotosetListModel
    }
}
