pragma Singleton

import QtQuick 2.0

import "../Utils" as Utils
import "../Core/FlickrAPI.js" as FlickrAPI
import "../Core"

Item {
    id: flickrBrowserAppSingleton

    /*------ Global lists: collects and photosets -------*/
    signal collectionTreeChanged();
    signal photosetListChanged();

    property alias collectionTreeModel: rootCollectionTreeModel
    property alias photosetListModel: rootPhotosetListModel

    function fillCollectionTreeModel(jsonArray) {
        rootCollectionTreeModel.clear();

        if( jsonArray ) {
            var i;
            for( i=0; i<jsonArray.length; i++ ) {
                rootCollectionTreeModel.append(jsonArray[i]);
            }
        }

        collectionTreeChanged();
    }

    function fillPhotosetListModel(jsonArray) {
        rootPhotosetListModel.clear();

        if( jsonArray ) {
            var i;
            for( i=0; i<jsonArray.length; i++ ) {
                rootPhotosetListModel.append(jsonArray[i]);
            }
        }

        photosetListChanged();
    }

    /*------ Current selection -------*/
    property alias currentSelection: _currentSelection

    /*------ Currently shown page -------*/
    property Item currentShownPage;

    /*------ Contextual filter -------*/
    property alias contextualFilter: _contextualFilter

    /*------ Flickr API call -------*/
    function callFlickr(method, args) {
        var reply = flickrReplyComponent.createObject(null); // no parent: it is only held by the "reply" variable
        FlickrAPI.callFlickrMethod(method, args, "", function(response) {
            reply.received(response); // emit signal
            reply.destroy();
        });
        return reply;
    }

    //////// private
    Component {
        id: flickrReplyComponent
        FlickrReply {}
    }

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
