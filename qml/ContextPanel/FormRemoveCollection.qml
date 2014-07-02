import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: removeCollectionForm

    property alias recursive: recursiveCheckBox.checked

    signal clearForm();
    signal validateForm();

    function removeCollectionSelection(recursive) {
        // now move the selected collections under that one
        if( FlickrBrowserApp.currentSelection.count>0 ) {
            var iSel;
            for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                var removeArgs = [];
                removeArgs.push([ "collection_id", FlickrBrowserApp.currentSelection.get(iSel).id ]);
                removeArgs.push([ "recursive", recursive?"true":"false" ]);

                var flickrReplyRemoveCollection = FlickrBrowserApp.callFlickr("flickr.collections.delete", removeArgs);
                if( flickrReplyRemoveCollection ) {
                    flickrReplyRemoveCollection.received.connect(function(response) {
                        if(response && response.stat && response.stat === "ok")
                        {
                            console.log("Collection removed !");
                        }
                    });
                }
            }
        }
    }

    function clearValues() {
        recursive = false;
    }

    onClearForm: {
        clearValues();
    }
    onValidateForm: {
        removeCollectionSelection(recursive);
        clearValues();
    }

    Label {
        width: parent.width
        text: "This will permanently remove the selected collections !"
        wrapMode: Text.Wrap
    }
    CheckBox {
        id: recursiveCheckBox
        width: parent.width
        text: "Delete recursively"
    }

    Button {
        anchors.right: parent.right
        text: "Delete"
        onClicked: removeCollectionForm.validateForm();
    }
}

