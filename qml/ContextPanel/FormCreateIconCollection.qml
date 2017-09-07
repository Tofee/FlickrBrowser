import QtQuick 2.9
import QtQuick.Controls 2.2

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: createIconCollectionForm

    signal clearForm();
    signal validateForm();

    function createIconCollectionSelection() {
        if( FlickrBrowserApp.currentSelection.count>0 ) {
            var iSel;
            for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                var createIconArgs = [];
                createIconArgs.push([ "collection_id", FlickrBrowserApp.currentSelection.get(iSel).id ]);

                var changedColId = FlickrBrowserApp.currentShownPage.pageItemId;
                var flickrReplyRemoveCollection = FlickrBrowserApp.callFlickr("flickr.collections.createIcon", createIconArgs);
                if( flickrReplyRemoveCollection ) {
                    flickrReplyRemoveCollection.received.connect(function(response) {
                        if(response && response.stat && response.stat === "ok")
                        {
                            console.log("Icon created !");

                            FlickrBrowserApp.remoteModelChanged(changedColId);
                        }
                    });
                }
            }
        }
    }

    function clearValues() {
    }

    onClearForm: {
        clearValues();
    }
    onValidateForm: {
        createIconCollectionSelection();
        clearValues();
    }

    Button {
        anchors.right: parent.right
        text: "Create"
        onClicked: createIconCollectionForm.validateForm();
    }
}

