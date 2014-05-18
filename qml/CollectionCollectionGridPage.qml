import QtQuick 2.0
import QtQuick.Controls 1.1

Item {
    id: collectionGridPage

    property ListModel collectionTreeModel;
    property ListModel photoSetListModel;

    property string pagePath: "/"

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: collectionsGridView.height
        clip: true
        flickableDirection: Flickable.VerticalFlick

        Flow {
            id: collectionsGridView

            x: 0; y: 0
            width: collectionGridPage.width

            Repeater {
                model: collectionTreeModel
                delegate:
                    Item {
                        height: collectionCell.height
                        width: collectionCell.width

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
                            width: collectionImage.width

                            Image {
                                id: collectionImage
                                height: 150
                                width: 150

                                fillMode: Image.PreserveAspectFit
                                source: iconlarge[0] == '/' ? Qt.resolvedUrl("images/collection_default_l.gif") : iconlarge

                                onWidthChanged: console.log("width image = " + collectionImage.width);
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
                                    stackView.navigationPath.push(title);
                                    stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                                    properties: {"collectionTreeModel": myModelItem.collection, "photoSetListModel": photoSetListModel}});
                                }
                                else if( myModelItem.set ) {
                                    stackView.navigationPath.push(title);
                                    stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml"),
                                                    properties: {"collectionTreeModel": myModelItem.set, "photoSetListModel": photoSetListModel}});
                                }
                            }
                        }
                    }
            }
        }
    }
}
