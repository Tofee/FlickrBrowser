import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../Singletons"

Pane {
    height: selectionLoader.height

    Loader {
        id: selectionLoader
        width: parent.width
        sourceComponent: FlickrBrowserApp.currentSelection.selectedIndexes.length > 1 ? multiSelectionPropertiesComp : simplePropertiesComp
    }
    Component {
        id: multiSelectionPropertiesComp
        ColumnLayout {
            Text {
                text: FlickrBrowserApp.currentSelection.selectedIndexes.length + " items";
            }
        }
    }
    Component {
        id: simplePropertiesComp
        Item {
            height: propertiesLoader.height

            property variant currentItem: FlickrBrowserApp.currentSelection.hasSelection ?
                                               FlickrBrowserApp.currentSelection.model.get(FlickrBrowserApp.currentSelection.currentIndex.row) :
                                               FlickrBrowserApp.currentShownPage
            Loader {
                id: propertiesLoader

                anchors.left: parent.left
                anchors.right: parent.right

                property string currentItemId
            }
            onCurrentItemChanged: {
                propertiesLoader.active = false; // force unload
                if( !currentItem ) return;

                if( FlickrBrowserApp.currentShownPage.pageModelType === "RootView" )
                {
                    propertiesLoader.currentItemId = FlickrBrowserApp.currentShownPage.pageItemId;
                    propertiesLoader.source = "PropertiesRootView.qml";
                }
                else if( FlickrBrowserApp.currentShownPage.pageModelType === "CollectionCollection" )
                {
                    if( FlickrBrowserApp.currentSelection.hasSelection ) {
                        propertiesLoader.currentItemId = currentItem.id;
                    } else {
                        propertiesLoader.currentItemId = FlickrBrowserApp.currentShownPage.pageItemId;
                    }
                    propertiesLoader.source = "PropertiesCollection.qml";
                }
                else if( FlickrBrowserApp.currentShownPage.pageModelType === "PhotosetCollection" )
                {
                    if( FlickrBrowserApp.currentSelection.hasSelection ) {
                        propertiesLoader.currentItemId = currentItem.id;
                        propertiesLoader.source = "PropertiesSet.qml";
                    } else {
                        propertiesLoader.currentItemId = FlickrBrowserApp.currentShownPage.pageItemId;
                        propertiesLoader.source = "PropertiesCollection.qml";
                    }
                }
                else if( FlickrBrowserApp.currentShownPage.pageModelType === "Photoset" )
                {
                    if( FlickrBrowserApp.currentSelection.hasSelection ) {
                        propertiesLoader.currentItemId = currentItem.id;
                        propertiesLoader.source = "PropertiesPhoto.qml";
                    } else {
                        propertiesLoader.currentItemId = FlickrBrowserApp.currentShownPage.pageItemId;
                        propertiesLoader.source = "PropertiesSet.qml";
                    }
                }
                else if( FlickrBrowserApp.currentShownPage.pageModelType === "Photo" )
                {
                    // keep the binding, so that prev/next photo works as expected
                    propertiesLoader.currentItemId = Qt.binding( function() { return FlickrBrowserApp.currentShownPage.pageItemId; } )
                    propertiesLoader.source = "PropertiesPhoto.qml";
                }
                else if( currentItem.type === "file" )
                {
                    propertiesLoader.currentItemId = currentItem.id;
                    propertiesLoader.source = "PropertiesFile.qml";
                }
                else
                {
                    propertiesLoader.source = "";
                }
                propertiesLoader.active = true;
            }
        }
    }
}
