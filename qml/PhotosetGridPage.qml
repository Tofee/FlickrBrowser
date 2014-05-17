import QtQuick 2.0
import QtQuick.Controls 1.1

Item {
    id: collectionGridPage

    property string photosetId;
    property ListModel photosetModel;

    property string pagePath: "/"

    Component.onCompleted: {
        // Query Flickr to retrieve the list of the photos
        FlickrAPI.callFlickrMethod("flickr.photosets.getInfo", null, function(response) {
            if(response && response.photoset)
            {
                console.log(JSON.stringify(response.photoset));
            }
        });
    }

    GridView {
        id: collectionsGridView

        anchors.fill: parent
        model: collectionTreeModel

        delegate:
            Item {
                function getCollectionTitle() {
                    // We have to be careful here:
                    // the "collection" property could very well not
                    // exist at all in the model, and therefore
                    // not being defined as an attached property
                    // in the current context
                    var myModelItem = collectionTreeModel.get(index)
                    if( myModelItem.collection ) {
                        return title + "(" + myModelItem.collection.count + ")"
                    }
                    else if( myModelItem.set ) {
                        return title + "(" + myModelItem.set.count + ")"
                    }

                    return title + "(0)"
                }

                Column {
                    id: collectionCell
                    width: collectionsGridView.cellWidth
                    Image {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        fillMode: Image.PreserveAspectFit
                        source: iconlarge[0] == '/' ? Qt.resolvedUrl("images/collection_default_l.gif") : iconlarge
                    }
                    Text {
                        id: collectionTitle
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: getCollectionTitle()
                    }
                }
                MouseArea {
                    anchors.fill: collectionCell
                    onClicked: {
                        var stackView = collectionGridPage.Stack.view;
                        var myModelItem = collectionTreeModel.get(index)
                        if( myModelItem.collection ) {
                            stackView.push({item: Qt.resolvedUrl("CollectionGridPage.qml"),
                                            properties: {"collectionTreeModel": collection, "pagePath": pagePath + "/" + title}});
                        }
                        else if( myModelItem.set ) {
                            stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                            properties: {"photosetModel": set, "pagePath": pagePath + "/" + title}});
                        }
                    }
                }
            }
    }
}
