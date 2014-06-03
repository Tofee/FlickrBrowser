import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI
import "AuthoringServices.js" as AuthoringServices

import "../Singletons"

Column {
    id: createPhotosetCollectionTreeForm

    signal cancelTriggered();
    signal okTriggered();

    function _nextStep1(photoSetId, nameToCreate, colId, collectionTreeSubset, depth) {
        if( nameToCreate.length === 0 || depth === 1 ) {
            // the road is ending here: put the photoset in colId
            var moveSetsArgs = [];
            moveSetsArgs.push([ "collection_id", colId ]);

            var photoSetsId = photoSetId;
            if( collectionTreeSubset ) {
                for( var iSet = 0; iSet < collectionTreeSubset.count; ++iSet ) {
                    if( photoSetId === collectionTreeSubset.get(iSet).id ) return; // already in the sets
                    photoSetsId += "," + collectionTreeSubset.get(iSet).id;
                }
                collectionTreeSubset.append({"id": photoSetId});
            }

            moveSetsArgs.push([ "photoset_ids", photoSetsId ]);

            FlickrAPI.callFlickrMethod("flickr.collections.editSets", moveSetsArgs, function(response) {
                if(response && response.stat && response.stat === "ok")
                {
                    console.log("Sets added to the new collection !");
                }
            });
        }
        else {
            // look for the first "/" character
            var parentColName = nameToCreate.split('/',1)[0];
            var relativeNameToCreate = nameToCreate.substring(parentColName.length + 1);

            // let's go one level deeper
            putPhotosetUnderCollection(photoSetId, relativeNameToCreate, parentColName, colId, collectionTreeSubset, depth+1);
        }
    }

    // create the photoset (photoSetId), with given relative path name "nameToCreate", into the collection "parentColName",
    // considering that we currently are in collection "currentColId" with its subtree "collectionTreeSubset"
    function putPhotosetUnderCollection(photoSetId, nameToCreate, parentColName, currentColId, collectionTreeSubset, depth) {
        // role: find the id of parentColName --> if it doesn't exist, then create it in currentColId
        var indexCol;
        var foundColId = "";
        var subtree;
        if( collectionTreeSubset && collectionTreeSubset.count ) {
            for( indexCol = 0; indexCol < collectionTreeSubset.count; ++indexCol ) {
                var collectionItem = collectionTreeSubset.get(indexCol);
                if( collectionItem.title === parentColName ) {
                    if( collectionItem.notInSync ) return; // abort, sir
                    foundColId = collectionItem.id;
                    if( collectionItem.set )
                        subtree = collectionItem.set
                    else
                        subtree = collectionItem.collection;
                    break;
                }
            }
        }
        if( foundColId.length > 0 ) {
            _nextStep1(photoSetId, nameToCreate, foundColId, subtree, depth);
        }
        else {
            // collection not found -> create it

            // mark it as unsafe for usage
            if( collectionTreeSubset )
                collectionTreeSubset.append({"title": parentColName, "notInSync": true});

            createCollection(parentColName, currentColId,
                             function(colId) {
                                 if( !collectionTreeSubset ) return; // no need to go further if no subtree
                                 _nextStep1(photoSetId, nameToCreate, colId, subtree, depth);
                             });
        }
    }

    function createCollection(title, underColId, successCB) {
        if( title.length === 0 ) return;

        var createArgs = [];
        createArgs.push([ "title", title ])
        if( underColId && underColId.length>0 )
            createArgs.push([ "parent_id", underColId ]);

        FlickrAPI.callFlickrMethod("flickr.collections.create", createArgs, function(response) {
            var newColId = "";
            if(response && response.stat && response.stat === "ok")
            {
                newColId = response.collection.id;
                console.log("Collection created !");

                successCB(newColId);
            }
            else {
                console.log(JSON.stringify(response));
            }
        });
    }

    function createCollectionTree(photoSetId, photoSetName) {
        var parentColName;
        var nameToCreate = photoSetName.substring(photoSetName.indexOf('/') + 1);

        // See if the name begins with "YYYY-"
        var year = parseInt(photoSetName.substr(0,4));
        if( year > 1980 && year < 3000 && photoSetName.charAt(4) === '-' ) {
            // yes, so put it under the collection that has the same name
            parentColName = photoSetName.substr(0,4);
            nameToCreate = photoSetName;
        }
        else {
            // no, then look for the first "/" character
            parentColName = photoSetName.split('/',1)[0];
        }

        putPhotosetUnderCollection(photoSetId, nameToCreate, parentColName, "", FlickrBrowserApp.collectionTreeModel, 0);
    }

    onCancelTriggered: {
    }
    onOkTriggered: {
        var i = 0;
        for( i = 0; i < FlickrBrowserApp.photosetListModel.count; ++i )
        {
            createCollectionTree(FlickrBrowserApp.photosetListModel.get(i).id, FlickrBrowserApp.photosetListModel.get(i).title._content);
        }
    }

    Label {
        width: parent.width
        text: "This will create a tree of collections corresponding to the entire list of albums."
        wrapMode: Text.Wrap
    }
    RowLayout {
        width: parent.width
        Button {
            Layout.alignment: Qt.AlignLeft
            text: "Cancel"
            onClicked: createPhotosetCollectionTreeForm.cancelTriggered();
        }
        Button {
            Layout.alignment: Qt.AlignRight
            text: "OK"
            onClicked: createPhotosetCollectionTreeForm.okTriggered();
        }
    }
}
