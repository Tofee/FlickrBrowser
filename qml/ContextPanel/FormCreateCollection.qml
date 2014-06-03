import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "AuthoringServices.js" as AuthoringServices

import "../Core"
import "../Singletons"

Column {
    id: createCollectionForm

    property alias collectionName: collectionNameField.text
    property alias moveSelection: moveSelectionCheckBox.checked

    signal cancelTriggered();
    signal okTriggered();

    function createCollection(title, moveSelection, underColId) {
        if( title.length === 0 ) return;

        var createArgs = [];
        createArgs.push([ "title", title ])
        if( underColId && underColId.length>0 )
            createArgs.push([ "parent_id", underColId ]);

        var flickrReplyCreateCollection = FlickrBrowserApp.callFlickr("flickr.collections.create", createArgs);
        if( flickrReplyCreateCollection ) {
            flickrReplyCreateCollection.received.connect(function(response) {
                var newColId = "";
                if(response && response.stat && response.stat === "ok")
                {
                    newColId = response.collection.id;
                    console.log("Collection created !");
                }

                // now move the selected collections under that one
                if( moveSelection && newColId.length>0 && FlickrBrowserApp.currentSelection.count>0 ) {
                    var iSel;
                    for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                        var moveArgs = [];
                        moveArgs.push([ "collection_id", FlickrBrowserApp.currentSelection.get(iSel).id ]);
                        moveArgs.push([ "parent_collection_id", newColId ]);

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
            });
        }
    }

    function clearValues() {
        collectionName = "";
        moveSelection = false;
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
    CheckBox {
        id: moveSelectionCheckBox
        width: parent.width
        text: "Move selection to new collection"
    }
    RowLayout {
        width: parent.width
        Button {
            Layout.alignment: Qt.AlignLeft
            text: "Cancel"
            onClicked: createCollectionForm.cancelTriggered();
        }
        Button {
            Layout.alignment: Qt.AlignRight
            text: "OK"
            onClicked: createCollectionForm.okTriggered();
        }
    }
}
