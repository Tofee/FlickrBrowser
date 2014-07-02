import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: removePhotosetForm

    signal clearForm();
    signal validateForm();

    function removeCollectionSelection() {
        // now move the selected collections under that one
        if( FlickrBrowserApp.currentSelection.count>0 ) {
            var iSel;
            for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                var removeArgs = [];
                removeArgs.push([ "photoset_id", FlickrBrowserApp.currentSelection.get(iSel).id ]);

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

    Label {
        width: parent.width
        text: "This will permanently remove the selected photoset !"
    }

    Button {
        anchors.right: parent.right
        text: "Delete"
        onClicked: removePhotosetForm.validateForm();
    }
}

