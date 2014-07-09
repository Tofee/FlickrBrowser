import QtQuick 2.0
import QtQuick.Controls 1.1

import "../Core"
import "../Singletons"
import "../Utils" as Utils

BrowserPage {
    id: collectionGridPage

    pageModelType: "CollectionCollection"
    pageModel: ListModel {}

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

                imageSource: (iconlarge && iconlarge[0] !== '/') ? iconlarge : Qt.resolvedUrl("../images/collection_default_l.gif")
                textContent: getCollectionTitle();

                imageFillMode: Image.PreserveAspectFit
                imageHeight: 150
                imageWidth: 150
                textPixelSize: 10

                isSelected: (sortedModel.get(index).selected) ? true : false

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
                    var stackView = collectionGridPage.Stack.view;
                    var myModelItem = sortedModel.get(index)

                    if( myModelItem.collection ) {
                        stackView.navigationPath.push(myModelItem.title);
                        stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                        properties: {"pageItemId": myModelItem.id}});
                    }
                    else if( myModelItem.set ) {
                        stackView.navigationPath.push(myModelItem.title);
                        stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml"),
                                        properties: {"pageItemId": myModelItem.id}});
                    }
                }
            }
    }
}
