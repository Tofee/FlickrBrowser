import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: moveCollectionForm

    signal clearForm();
    signal validateForm();

    function moveCollectionSelection(underColId) {
        // now move the selected collections under that one
        if( FlickrBrowserApp.currentSelection.hasSelection ) {
            var iSel;
            var selectedIndices = FlickrBrowserApp.currentSelection.selectedIndexes;
            for( iSel = 0; iSel < selectedIndices.length; ++iSel ) {
                var moveArgs = [];
                moveArgs.push([ "collection_id", FlickrBrowserApp.currentSelection.model.get(selectedIndices[iSel].row).id ]);
                moveArgs.push([ "parent_collection_id", underColId ]);

                var flickrReplyMoveCollection = FlickrBrowserApp.callFlickr("flickr.collections.moveCollection", moveArgs);
                if( flickrReplyMoveCollection ) {
                    flickrReplyMoveCollection.received.connect(function(response) {
                        if(response && response.stat && response.stat === "ok")
                        {
                            console.log("Collection moved !");

                            FlickrBrowserApp.remoteModelChanged(FlickrBrowserApp.currentShownPage.pageItemId);
                        }
                    });
                }
            }
        }
    }

    property alias listCollections: collectionPlacementCombo.model
    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.collections && response.collections.collection)
            {
                listCollections.append({ colId: "", title: "Root" });
                AuthoringServices.fillModelWithCollections(listCollections, response.collections.collection, false, 0);
            }
        }
    }

    onVisibleChanged: {
        listCollections.clear(); // clear in all case
        if( visible ) {
            // Query Flickr to retrieve the list of the collections
            flickrReply = FlickrBrowserApp.callFlickr("flickr.collections.getTree", [ [ "collection_id", "0" ] ] );
        }
    }

    function clearValues() {
        collectionPlacementCombo.currentIndex = 0;
    }


    onClearForm: {
        clearValues();
    }
    onValidateForm: {
        moveCollectionSelection(collectionPlacementCombo.model.get(collectionPlacementCombo.currentIndex).colId);
        clearValues();
    }

    Text {
        width: parent.width
        text: "Move selection to :"
    }
    ComboBox {
        id: collectionPlacementCombo
        width: parent.width
        Layout.fillWidth: true

        model: ListModel {}

        textRole: "title"
    }

    Button {
        anchors.right: parent.right
        text: "Move"
        onClicked: moveCollectionForm.validateForm();
    }
}

