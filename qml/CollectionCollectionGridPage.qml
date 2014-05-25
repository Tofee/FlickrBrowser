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
                    Item {
                        id: delegateItem

                        height: collectionCell.height
                        width: collectionCell.width

                        property string collectionTitleText: getCollectionTitle();

                        Connections {
                            target: FlickrBrowserApp.contextualFilter
                            onFilterChanged: {
                                delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.collectionTitleText });
                            }
                        }
                        Component.onCompleted: {
                            delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.collectionTitleText });
                        }

                        function getCollectionTitle() {
                            // We have to be careful here:
                            // the "collection" property could very well not
                            // exist at all in the model, and therefore
                            // not being defined as an attached property
                            // in the current context
                            var myModelItem = pageModel.get(index)
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
                                source: (iconlarge && iconlarge[0] !== '/') ? iconlarge : Qt.resolvedUrl("images/collection_default_l.gif")
                            }
                            Text {
                                id: collectionTitle
                                anchors.left: parent.left
                                anchors.right: parent.right

                                color: "white"

                                text: collectionTitleText
                            }
                        }
                        Utils.SingleDoubleClickMouseArea {
                            anchors.fill: collectionCell
                            onRealClicked: {
                                if( !(mouse.modifiers & Qt.ControlModifier) )
                                    FlickrBrowserApp.currentSelection.clear();
                                FlickrBrowserApp.currentSelection.addToSelection({ "type": "collection", "id": id });
                            }
                            onRealDoubleClicked: {
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
}
