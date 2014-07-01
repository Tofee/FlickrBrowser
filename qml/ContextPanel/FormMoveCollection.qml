import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: moveCollectionForm

    signal cancelTriggered();
    signal okTriggered();

    function moveCollectionSelection(underColId) {
        // now move the selected collections under that one
        if( FlickrBrowserApp.currentSelection.count>0 ) {
            var iSel;
            for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                var moveArgs = [];
                moveArgs.push([ "collection_id", FlickrBrowserApp.currentSelection.get(iSel).id ]);
                moveArgs.push([ "parent_collection_id", underColId ]);

                var flickrReplyMoveCollection = FlickrBrowserApp.callFlickr("flickr.collections.moveCollection", moveArgs);
                if( flickrReplyMoveCollection ) {
                    flickrReplyMoveCollection.received.connect(function(response) {
                        if(response && response.stat && response.stat === "ok")
                        {
                            console.log("Collection moved !");
                        }
                    });
                }
            }
        }
    }

    function clearValues() {
        collectionPlacementCombo.currentIndex = 0;
    }

    onCancelTriggered: {
        clearValues();
    }
    onOkTriggered: {
        moveCollectionSelection(collectionPlacementCombo.model.get(collectionPlacementCombo.currentIndex).colId);
        clearValues();
    }

    Label {
        width: parent.width
        text: "Move selection to :"
    }
    ComboBox {
        id: collectionPlacementCombo
        width: parent.width
        Layout.fillWidth: true

        model: ListModel {
            id: listCollections
        }

        onVisibleChanged: {
            listCollections.clear(); // clear in all case
            if( visible && FlickrBrowserApp.collectionTreeModel ) {
                listCollections.append({ colId: "", title: "Root" });
                AuthoringServices.fillModelWithCollections(listCollections, FlickrBrowserApp.collectionTreeModel, false, 0);
            }
        }

        textRole: "title"
    }
    RowLayout {
        width: parent.width
        Button {
            Layout.alignment: Qt.AlignLeft
            text: "Cancel"
            onClicked: moveCollectionForm.cancelTriggered();
        }
        Button {
            Layout.alignment: Qt.AlignRight
            text: "OK"
            onClicked: moveCollectionForm.okTriggered();
        }
    }
}

