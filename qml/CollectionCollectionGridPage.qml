import QtQuick 2.0
import QtQuick.Controls 1.1

import "Singletons"
import "Utils" as Utils

Item {
    id: collectionGridPage

    property ListModel pageModel;

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
                model: pageModel
                delegate:
                    Utils.FlowListDelegate {

                        icon: (iconlarge && iconlarge[0] !== '/') ? iconlarge : Qt.resolvedUrl("images/collection_default_l.gif")
                        title: getCollectionTitle();

                        imageFillMode: Image.PreserveAspectFit
                        imageHeight: 150
                        imageWidth: 150
                        textPixelSize: 10

                        selected: (pageModel.get(index).selected) ? true : false

                        function getCollectionTitle() {
                            // We have to be careful here:
                            // the "collection" property could very well not
                            // exist at all in the model, and therefore
                            // not being defined as an attached property
                            // in the current context
                            var myModelItem = pageModel.get(index)
                            if( myModelItem.collection ) {
                                return myModelItem.title + "(" + myModelItem.collection.count + ")"
                            }
                            else if( myModelItem.set ) {
                                return myModelItem.title + "(" + myModelItem.set.count + ")"
                            }

                            return myModelItem.title + "(0)"
                        }

                        onClicked: {
                            if( !(mouse.modifiers & Qt.ControlModifier) )
                                FlickrBrowserApp.currentSelection.clear();
                            FlickrBrowserApp.currentSelection.addToSelection({ "type": "collection", "id": id });
                        }
                        onDoubleClicked: {
                            var stackView = collectionGridPage.Stack.view;
                            var myModelItem = pageModel.get(index)

                            if( myModelItem.collection ) {
                                stackView.navigationPath.push(title);
                                stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                                properties: {"pageModel": myModelItem.collection}});
                            }
                            else if( myModelItem.set ) {
                                stackView.navigationPath.push(title);
                                stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml"),
                                                properties: {"pageModel": myModelItem.set}});
                            }
                        }
                    }
            }
        }
    }
}
