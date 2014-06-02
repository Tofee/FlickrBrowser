import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI
import "AuthoringServices.js" as AuthoringServices

import "../Singletons"

Column {
    id: removeCollectionForm

    property alias recursive: recursiveCheckBox.checked

    signal cancelTriggered();
    signal okTriggered();

    function removeCollectionSelection(recursive) {
        // now move the selected collections under that one
        if( FlickrBrowserApp.currentSelection.count>0 ) {
            var iSel;
            for( iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
                var removeArgs = [];
                removeArgs.push([ "collection_id", FlickrBrowserApp.currentSelection.get(iSel).id ]);
                removeArgs.push([ "recursive", recursive?"true":"false" ]);

                FlickrAPI.callFlickrMethod("flickr.collections.delete", removeArgs, removeCollectionForm.toString(), function(response) {
                    if(response && response.stat && response.stat === "ok")
                    {
                        console.log("Collection removed !");
                    }
                });
            }
        }
    }
    Component.onDestruction: {
        FlickrAPI.disableCallbacks(removeCollectionForm.toString());
    }

    function clearValues() {
        recursive = false;
    }

    onCancelTriggered: {
        clearValues();
    }
    onOkTriggered: {
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
    RowLayout {
        width: parent.width
        Button {
            Layout.alignment: Qt.AlignLeft
            text: "Cancel"
            onClicked: removeCollectionForm.cancelTriggered();
        }
        Button {
            Layout.alignment: Qt.AlignRight
            text: "OK"
            onClicked: removeCollectionForm.okTriggered();
        }
    }
}

