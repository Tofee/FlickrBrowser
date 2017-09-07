import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: formAddPhotoSetToCollection

    signal clearForm();
    signal validateForm();

    function addPhotoSetToCollection(photoSetId) {
        // now move the selected collections under that one
        var moveSetsArgs = [];
        moveSetsArgs.push([ "collection_id", FlickrBrowserApp.currentShownPage.pageItemId ]);

        // BUG: looks like FlickrBrowserApp.currentShownPage.pageModel is always empty!
        var listSets = photoSetId;
        for( var iExistingSets = 0; iExistingSets < FlickrBrowserApp.currentShownPage.pageModel.count; ++iExistingSets ) {
            listSets += ",";
            listSets += FlickrBrowserApp.currentShownPage.pageModel.get(iExistingSets).id;
        }
        moveSetsArgs.push([ "photoset_ids", photoSetId ]);

        console.log("addPhotoSetToCollection: moveSetsArgs = " + JSON.stringify(moveSetsArgs));
        var flickrReplyEditSets; // = FlickrBrowserApp.callFlickr("flickr.collections.editSets", moveSetsArgs);
        if( flickrReplyEditSets ) {
            flickrReplyEditSets.received.connect(function(response) {
                if(response && response.stat && response.stat === "ok")
                {
                    console.log("Album added to the collection !");

                    FlickrBrowserApp.remoteModelChanged(FlickrBrowserApp.currentShownPage.pageItemId);
                }
            });
        }
    }

    function clearValues() {
        collectionPlacementCombo.currentIndex = 0;
    }

    onClearForm: {
        clearValues();
    }
    onValidateForm: {
        var selectedAlbum = collectionPlacementCombo.model.get(collectionPlacementCombo.currentIndex);
        addPhotoSetToCollection(selectedAlbum.setId);
        clearValues();
    }

    property ListModel listPhotoSets: ListModel {}
    onVisibleChanged: {
        listPhotoSets.clear(); // clear in all case
        if( visible ) {
            for( var iSet=0; iSet < FlickrBrowserApp.photosetListModel.count; ++iSet ) {
                var setItem = FlickrBrowserApp.photosetListModel.get(iSet);
                listPhotoSets.append({ setId: setItem.id, title: setItem.title._content});
            }
        }
    }

    Text {
        width: parent.width
        text: "Album to add :"
    }
    ComboBox {
        id: collectionPlacementCombo
        width: parent.width
        Layout.fillWidth: true

        model: listPhotoSets

        textRole: "title"
    }
    Button {
        anchors.right: parent.right
        text: "Add"
        onClicked: formAddPhotoSetToCollection.validateForm();
    }
}

