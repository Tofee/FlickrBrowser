import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI
import "AuthoringServices.js" as AuthoringServices

import "../Singletons"

Column {
    id: createPhotosetCollectionForm

    property alias collectionName: collectionNameField.text

    signal cancelTriggered();
    signal okTriggered();

    function createCollection(title, moveSelection, underColId) {
        if( title.length === 0 ) return;

        var createArgs = [];
        createArgs.push([ "title", title ])
        if( underColId && underColId.length>0 )
            createArgs.push([ "parent_id", underColId ]);

        FlickrAPI.callFlickrMethod("flickr.collections.create", createArgs, createPhotosetCollectionForm.toString(), function(response) {
            var newColId = "";
            if(response && response.stat && response.stat === "ok")
            {
                newColId = response.collection.id;
                console.log("Collection created !");
            }

            // now move add the selected sets under that one
            if( newColId.length>0 && FlickrBrowserApp.currentSelection.count>0 ) {
                var moveSetsArgs = [];
                moveSetsArgs.push([ "collection_id", newColId ]);
                var iSel;
                var listSets = "";
                for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                    if( iSel > 0 ) listSets += ",";
                    listSets += FlickrBrowserApp.currentSelection.get(iSel).id;
                }

                moveSetsArgs.push([ "photoset_ids", listSets ]);

                FlickrAPI.callFlickrMethod("flickr.collections.editSets", moveSetsArgs, createPhotosetCollectionForm.toString(), function(response) {
                    if(response && response.stat && response.stat === "ok")
                    {
                        console.log("Sets added to the new collection !");
                    }
                });
            }
        });
    }
    Component.onDestruction: {
        FlickrAPI.disableCallbacks(createPhotosetCollectionForm.toString());
    }

    function clearValues() {
        collectionName = "";
    }

    onCancelTriggered: {
        clearValues();
    }
    onOkTriggered: {
        createCollection(collectionName, moveSelection, FlickrBrowserApp.currentShownPage.pageItemId);
        clearValues();
    }

    RowLayout {
        width: parent.width
        Label {
            text: "Title :"
        }
        TextField {
            id: collectionNameField
            Layout.fillWidth: true
        }
    }
    RowLayout {
        width: parent.width
        Button {
            Layout.alignment: Qt.AlignLeft
            text: "Cancel"
            onClicked: createPhotosetCollectionForm.cancelTriggered();
        }
        Button {
            Layout.alignment: Qt.AlignRight
            text: "OK"
            onClicked: createPhotosetCollectionForm.okTriggered();
        }
    }
}
