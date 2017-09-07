import QtQuick 2.0

import "../Core"
import "../Singletons"
import "../Utils" as Utils

BrowserPage {
    id: collectionGridPage

    pageModelType: "CollectionCollection"
    pageModel: ListModel {}
    modelForSelection: flowList.model

    Utils.SortedListModel {
        id: sortedModel
        originModel: pageModel
        sortAscendent: true
        sortKey: "title"
    }

    onRemoteModelChanged: refreshModel();
    Component.onCompleted: refreshModel();
    function refreshModel() {
        // Query Flickr to retrieve the list of the photos
        flickrReply = FlickrBrowserApp.callFlickr("flickr.collections.getTree", [ [ "collection_id", pageItemId ] ] );
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.collections && response.collections.collection)
            {
                pageModel.clear();

                var jsonArray = response.collections.collection;
                if( pageItemId !== "0" ) {
                    jsonArray = response.collections.collection[0].collection;
                }
                if( jsonArray ) {
                    var i;
                    for( i=0; i<jsonArray.length; i++ ) {
                        pageModel.append(jsonArray[i]);
                    }
                }

                sortedModel.syncModel();
            }
        }
    }

    Utils.FlowList {
        anchors.fill: parent
        id: flowList

        itemType: "collection"

        model: sortedModel
        delegate:
            Utils.FlowListDelegate {
                id: flowListDelegate

                imageSource: (iconlarge && iconlarge[0] !== '/') ? iconlarge : Qt.resolvedUrl("../images/collection_default_l.gif")
                textContent: getCollectionTitle();

                imageFillMode: Image.PreserveAspectFit
                imageHeight: 150
                imageWidth: 150
                textPixelSize: 10

                // little trick here to make it re-evaluate the property each time the selection changes
                isSelected: { FlickrBrowserApp.currentSelection.selectedIndexes; return FlickrBrowserApp.currentSelection.isSelected(modelForSelection.index(index,0)) }

                function getCollectionTitle() {
                    // We have to be careful here:
                    // the "collection" property could very well not
                    // exist at all in the model, and therefore
                    // not being defined as an attached property
                    // in the current context
                    var myModelItem = sortedModel.get(index)
                    if( myModelItem.collection ) {
                        return myModelItem.title + "(" + myModelItem.collection.count + ")"
                    }
                    else if( myModelItem.set ) {
                        return myModelItem.title + "(" + myModelItem.set.count + ")"
                    }

                    return myModelItem.title + "(0)"
                }

                onClicked: {
                    flowList.selected(index, mouse.modifiers);
                }
                onDoubleClicked: {
                    var myModelItem = sortedModel.get(index)
                    if( myModelItem.collection ) {
                        collectionGridPage.pushNewPage(Qt.resolvedUrl("CollectionCollectionGridPage.qml"), myModelItem.title, {"pageItemId": myModelItem.id});
                    }
                    else if( myModelItem.set ) {
                        collectionGridPage.pushNewPage(Qt.resolvedUrl("PhotosetCollectionGridPage.qml"), myModelItem.title, {"pageItemId": myModelItem.id});
                    }
                }
            }
    }
}
