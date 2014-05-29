import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI
import "AuthoringServices.js" as AuthoringServices

import "../Singletons"

Column {
    id: moveCollectionForm

    property string moveDestination: collectionPlacementCombo.model.get(collectionPlacementCombo.currentIndex).colId

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

                FlickrAPI.callFlickrMethod("flickr.collections.moveCollection", moveArgs, moveCollectionForm.toString(), function(response) {
                    if(response && response.stat && response.stat === "ok")
                    {
                        console.log("Collection moved !");
                    }
                });
            }
        }
    }
    Component.onDestruction: {
        FlickrAPI.disableCallbacks(moveCollectionForm.toString());
    }

    function clearValues() {
        collectionPlacementCombo.currentIndex = 0;
    }

    onCancelTriggered: {
        clearValues();
    }
    onOkTriggered: {
        moveCollectionSelection(moveDestination);
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

            ListElement {
                colId: ""
                title: "Root"
            }

            Component.onCompleted: {
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

