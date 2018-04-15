import QtQuick 2.9
import QtQuick.Controls 2.2

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: removePhotosetForm

    signal clearForm();
    signal validateForm();

    function removeCollectionSelection() {
        // now move the selected collections under that one
        if( FlickrBrowserApp.currentSelection.hasSelection ) {
            var iSel;
            var selectedIndices = FlickrBrowserApp.currentSelection.selectedIndexes;
            for( iSel = 0; iSel < selectedIndices.length; ++iSel ) {
                var removeArgs = [];
                removeArgs.push([ "photoset_id", FlickrBrowserApp.currentSelection.model.get(selectedIndices[iSel].row).id ]);

                var flickrReplyRemovePhotoset = FlickrBrowserApp.callFlickr("flickr.photosets.delete", removeArgs);
                if( flickrReplyRemovePhotoset ) {
                    flickrReplyRemovePhotoset.received.connect(function(response) {
                        if(response && response.stat && response.stat === "ok")
                        {
                            console.log("Photoset removed !");
                        }
                    });
                }
            }
        }
    }

    onClearForm: {
    }
    onValidateForm: {
        removeCollectionSelection();
    }

    Text {
        width: parent.width
        text: "This will permanently remove the selected photoset !"
    }

    Button {
        anchors.right: parent.right
        text: "Delete"
        onClicked: removePhotosetForm.validateForm();
    }
}

