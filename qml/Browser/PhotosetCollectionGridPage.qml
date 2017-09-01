import QtQuick 2.0
import QtQuick.Controls 1.1

import "../Core"
import "../Singletons"
import "../Utils" as Utils

BrowserPage {
    id: collectionGridPage

    pageModelType: "PhotosetCollection"
    pageModel: ListModel {}
    property ListModel photosetListModel: FlickrBrowserApp.photosetListModel
    modelForSelection: flowList.model

    Utils.SortedListModel {
        id: sortedModel
        originModel: pageModel
        sortAscendent: true
        sortKey: "title._content"
    }

    onRemoteModelChanged: refreshModel();
    Component.onCompleted: refreshModel();
    function refreshModel() {
        if( pageItemId === "0" ) {
            pageModel = photosetListModel;
            sortedModel.syncModel();
            // subscribe to changes of global photoset list
            FlickrBrowserApp.photosetListChanged.connect(refreshModel);
        }
        else {
            // Query Flickr to retrieve the list of the photos
            flickrReply = FlickrBrowserApp.callFlickr("flickr.collections.getTree", [ [ "collection_id", pageItemId ] ] );
        }
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.collections && response.collections.collection)
            {
                pageModel.clear();

                var jsonArray = response.collections.collection;
                if( response.collections.collection.length === 1 ) {
                    jsonArray = response.collections.collection[0].set;
                }
                if( jsonArray ) {
                    var i;
                    for( i=0; i<jsonArray.length; i++ ) {
                        pageModel.append(jsonArray[i]);
                    }
                }

                sortedModel.syncModel();
                smoothFillerTimer.i = 0; // trigger the filler timer
            }
        }
    }

    // Little trick to avoid feeding the Repeater and the Flow with too many items at the same time.
    // This avoids a crash on windows, so...
    ListModel {
        id: smoothlyFilledModel
    }
    Timer {
        id: smoothFillerTimer
        property int i: 0
        interval: 10
        running: i<sortedModel.count
        onTriggered: {
            var photoSetInfos = getPhotosetInfos(sortedModel.get(i).id);
            //photoSetInfos.originalObject = sortedModel.get(i);
            smoothlyFilledModel.append(photoSetInfos);
            i++;
        }
        repeat: true

        function getPhotosetInfos(myId) {
            // Find the size of that album
            for( var i = 0; i < photosetListModel.count; i++ ) {
                if( photosetListModel.get(i).id === myId ) {
                    return photosetListModel.get(i);
                }
            }
        }
    }
    /// end of little trick

    Utils.FlowList {
        anchors.fill: parent
        id: flowList

        itemType: "set"

        model: smoothlyFilledModel
        delegate:
            Utils.FlowListDelegate {
                id: delegateItem

                imageSource: primary_photo_extras.url_s || ""
                textContent: title._content + "(" + String(parseInt(photos)+parseInt(videos)) + ")";

                imageHeight: 180
                imageWidth: 180
                imageFillMode: Image.PreserveAspectCrop
                textPixelSize: 14

                // little trick here to make it re-evaluate the property each time the selection changes
                isSelected: { FlickrBrowserApp.currentSelection.selectedIndexes; return FlickrBrowserApp.currentSelection.isSelected(modelForSelection.index(index,0)) }

                onClicked: {
                    flowList.selected(index, mouse.modifiers);
                }
                onDoubleClicked: {
                    // We are opening a photoset album
                    var stackView = collectionGridPage.Stack.view;
                    stackView.navigationPath.push(delegateItem.textContent);
                    stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                    properties: {"pageItemId": id}});
                }
            }
    }
}
