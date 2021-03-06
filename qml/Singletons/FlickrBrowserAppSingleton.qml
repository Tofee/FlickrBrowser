pragma Singleton

import QtQuick 2.6
import QtQml.Models 2.2

import "../Utils" as Utils
import "../Core/FlickrAPI.js" as FlickrAPI
import "../Core"

Item {
    id: flickrBrowserAppSingleton

    /*------ Logout signal ----------------*/
    signal logout();

    /*------ Global list: photosets -------*/
    signal photosetListChanged();
    property alias photosetListModel: _photosetListModel

    function fillPhotosetListModel(jsonArray) {
        _photosetListModel.clear();

        if( jsonArray ) {
            var i;
            for( i=0; i<jsonArray.length; i++ ) {
                _photosetListModel.append(jsonArray[i]);
            }
        }

        photosetListChanged();
    }

    /*------ Global list: tags -------*/
    signal tagListChanged();
    property alias tagListModel: _tagListModel

    function fillTagListModel(jsonArray) {
        _tagListModel.clear();

        if( jsonArray ) {
            var i;
            for( i=0; i<jsonArray.length; i++ ) {
                _tagListModel.append(jsonArray[i]);
            }
        }

        tagListChanged();
    }

    /*------ Change signal ----------*/
    signal remoteModelChanged(string itemId);

    /*------ Current selection -------*/
    property alias currentSelection: _currentSelection

    /*------ Currently shown page -------*/
    property Item currentShownPage;

    /*------ Contextual filter -------*/
    property alias contextualFilter: _contextualFilter

    /*-------Current map target-------*/
    property variant currentTargetOnMap;

    /*-------Current map target-------*/
    property string localPhotoFolderRoot;

    /*------ Flickr API call -------*/
    signal flickrActionLaunched(QtObject reply);

    function callFlickr(method, args) {
        var reply = flickrReplyComponent.createObject(null,  // no parent: it is only held by the "reply" variable
                         {"flickrMethod": method, "flickrArgs": args});
        flickrBrowserAppSingleton.flickrActionLaunched(reply);
        FlickrAPI.callFlickrMethod(method, args, function(response) {
            reply.received(response); // emit signal
            reply.completed();
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
        id: _photosetListModel
    }

    ListModel {
        id: _tagListModel
    }

    ItemSelectionModel {
        id: _currentSelection
        model: currentShownPage ? currentShownPage.modelForSelection : null
    }

    Utils.Filter {
        id: _contextualFilter
    }
}
