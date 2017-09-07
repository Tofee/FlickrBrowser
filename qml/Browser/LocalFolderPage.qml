import QtQuick 2.0

import Qt.labs.folderlistmodel 2.1

import org.flickrbrowser.services 1.0

import "../Core"
import "../Singletons"
import "../Utils" as Utils

BrowserPage {
    id: localFolderPage

    pageModelType: "LocalFolder"
    pageModel: ListModel {}
    modelForSelection: flowList.model

    FolderListModel {
        id: folderListModel
        rootFolder: FlickrBrowserApp.localPhotoFolderRoot
        folder: folderPath

        onCountChanged: {
            // re-sync pageModel
            pageModel.clear();
            for( var i = 0; i < folderListModel.count; ++i ) {
                pageModel.append({
                                     id: folderListModel.get(i, "filePath"),
                                     filePath: folderListModel.get(i, "filePath"),
                                     fileName: folderListModel.get(i, "fileName"),
                                     fileBaseName: folderListModel.get(i, "fileBaseName"),
                                     fileIsDir: folderListModel.get(i, "fileIsDir")
                                 });
            }
        }
    }

    property string folderPath: FlickrBrowserApp.localPhotoFolderRoot
    property string localFilePath: folderPath.substring(FlickrBrowserApp.localPhotoFolderRoot.length+1);

    onLocalFilePathChanged: flickrList.fillFlickrList();
    // subscribe to changes of global photoset list
    Component.onCompleted: FlickrBrowserApp.photosetListChanged.connect(flickrList.fillFlickrList);

    // Example: "/mnt/photos/FlickrRoot/2015-05 Florida Beach/Anna/photo005.jpg"
    // Should give:
    // localFilePath = "2015-05 Florida Beach/Anna/photo005.jpg"
    // collection = "2015", subcollection = "2015-05 Florida Beach"
    // album = "2015-05 Florida Beach/Anna"
    // tagId = "#/2015-05 Florida Beach/Anna/photo005.jpg"
    ListModel {
        id: flickrList
        signal flickrListRefreshed();

        function fillFlickrList() {
            var photosetListModel = FlickrBrowserApp.photosetListModel;
            var i,j,k,l;

            flickrList.clear();

            // First case: we are at the root
            if( localFilePath.length === 0 ) {
                // Then we list the albums that should be at that level locally
                // i.e. all albums that are not sub-albums
                for( i = 0; i < photosetListModel.count; i++ ) {
                    var photoSet = photosetListModel.get(i);
                    if( photoSet.title._content.indexOf("/") === -1 ) {
                        flickrList.append({ "name": photoSet.title._content });
                    }
                }

                flickrList.flickrListRefreshed();
            }
            // Second case: we are in an album/collection or sub-album
            else {
                var foundPhotoSet = false;
                for( i = 0; i < photosetListModel.count && !foundPhotoSet; i++ ) {
                    if( photosetListModel.get(i).title._content === localFilePath ) {
                        foundPhotoSet = true;
                        var flickrReply = FlickrBrowserApp.callFlickr("flickr.photosets.getPhotos", [ [ "photoset_id", photosetListModel.get(i).id ] ]);
                        flickrReply.received.connect(function(response) {
                            if(response && response.photoset && response.photoset.photo)
                            {
                                for( j=0; j<response.photoset.photo.length; j++ ) {
                                    flickrList.append({ "name": response.photoset.photo[j].title });
                                }

                                flickrList.flickrListRefreshed();
                            }
                        });
                    }
                }

                // We found no such album, therefore it has to be a collection
                if( !foundPhotoSet && localFilePath.indexOf("/") === -1) {
                    var collectionYear = localFilePath.substring(0,4);

                    // Our collection tree is organized like this:
                    // [YEAR] (collection)/[YEAR]-[MONTH] [Album name] (collection)/[YEAR]-[MONTH] [Album name/subname] (set)

                    flickrReply = FlickrBrowserApp.callFlickr("flickr.collections.getTree", [ [ "collection_id", "0" ] ] );
                    flickrReply.received.connect(function(response) {
                        if(response && response.collections && response.collections.collection)
                        {
                            for( j=0; j<response.collections.collection.length; j++ ) {
                                var tmpCollectionYear = response.collections.collection[j];

                                if( tmpCollectionYear.title === collectionYear ) {
                                    for( k=0; k<tmpCollectionYear.collection.length; k++ ) {
                                        var tmpCollectionAlbum = tmpCollectionYear.collection[k];

                                        if( tmpCollectionAlbum.title === localFilePath ) {
                                            for( l=0; l<tmpCollectionAlbum.set.length; l++ ) {
                                                flickrList.append({ "name": tmpCollectionAlbum.set[l].title });
                                            }

                                            flickrList.flickrListRefreshed();

                                            break;
                                        }
                                    }

                                    break;
                                }
                            }
                        }
                    });
                }
            }
        }
    }

    Utils.FlowList {
        anchors.fill: parent
        id: flowList

        itemType: "file"

        model: pageModel
        delegate:
            Utils.FlowListDelegate {

                imageSource: fileIsDir ? "../images/folder_image.png" : filePath
                textContent: fileName

                imageFillMode: Image.PreserveAspectFit
                imageHeight: 150
                imageWidth: 150
                textPixelSize: 10

                flickrSyncStatus: getFlickrSyncStatus(fileBaseName);
                Connections {
                    target: flickrList
                    onFlickrListRefreshed: {
                        flickrSyncStatus = getFlickrSyncStatus(fileBaseName);
                        console.log("fileBaseName: " + fileBaseName + ", status = " + flickrSyncStatus);
                    }
                }

                // little trick here to make it re-evaluate the property each time the selection changes
                isSelected: { FlickrBrowserApp.currentSelection.selectedIndexes; return FlickrBrowserApp.currentSelection.isSelected(modelForSelection.index(index,0)) }

                onClicked: {
                    flowList.selected(index, mouse.modifiers);
                }
                onDoubleClicked: {
                    var myModelItem = pageModel.get(index)
                    if( myModelItem.fileIsDir ) {
                        localFolderPage.pushNewPage(Qt.resolvedUrl("LocalFolderPage.qml"), myModelItem.fileName,
                                                    {"folderPath": localFolderPage.folderPath + "/" + myModelItem.fileName });
                    }
                    else {
                        var photoHeight = FlickrServices.getExifProperty(myModelItem.filePath, "height");
                        var photoWidth  = FlickrServices.getExifProperty(myModelItem.filePath, "width");

                        localFolderPage.pushNewPage(Qt.resolvedUrl("PhotoPage.qml"), myModelItem.fileName,
                                                    {"pageItemId": "", "photoUrl": myModelItem.filePath,
                                                     "photoWidth": photoWidth, "photoHeight": photoHeight});
                    }
                }

                function getFlickrSyncStatus(fileBaseName)
                {
                    var status = "onlyLocal";

                    for(var i = 0; i<flickrList.count; ++i) {
                        if( flickrList.get(i).name === fileBaseName ) {
                            status = "synced";
                            break;
                        }
                    }

                    return status;
                }
        }
    }
}
