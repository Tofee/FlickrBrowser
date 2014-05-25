pragma Singleton

import QtQuick 2.0

import "../Utils" as Utils

Item {
    id: flickrBrowserAppSingleton

    /*------ Global lists: collects and photosets -------*/
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

    /*------ Current selection -------*/
    property alias currentSelection: _currentSelection

    /*------ Currently shown model -------*/
    property variant currentShownModel;

    /*------ Contextual filter -------*/
    property alias contextualFilter: _contextualFilter

    //////// private
    ListModel {
        id: rootCollectionTreeModel
    }
    ListModel {
        id: rootPhotosetListModel
    }

    Utils.Selection {
        id: _currentSelection
    }

    Utils.Filter {
        id: _contextualFilter
    }
}
