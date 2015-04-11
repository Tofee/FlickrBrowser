import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "../Singletons"

Item {
    height: selectionLoader.height

    Loader {
        anchors.left: parent.left
        anchors.right: parent.right

        id: selectionLoader
        sourceComponent: FlickrBrowserApp.currentSelection.count > 1 ? multiSelectionPropertiesComp : simplePropertiesComp
    }
    Component {
        id: multiSelectionPropertiesComp
        ColumnLayout {
            Label {
                text: FlickrBrowserApp.currentSelection.count + " items";
            }
        }
    }
    Component {
        id: simplePropertiesComp
        Item {
            height: propertiesLoader.height

            property variant currentItem: FlickrBrowserApp.currentSelection.count===1 ?
                                               FlickrBrowserApp.currentSelection.get(0) :
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
                if( currentItem.pageModelType === "RootView" )
                {
                    propertiesLoader.currentItemId = "";
                    propertiesLoader.source = "PropertiesRootView.qml";
                }
                else if( currentItem.type === "collection" )
                {
                    propertiesLoader.currentItemId = currentItem.id;
                    propertiesLoader.source = "PropertiesCollection.qml";
                }
                else if( currentItem.pageModelType === "CollectionCollection" ||
                         currentItem.pageModelType === "PhotosetCollection" )
                {
                    propertiesLoader.currentItemId = currentItem.pageItemId;
                    propertiesLoader.source = "PropertiesCollection.qml";
                }
                else if( currentItem.type === "set" )
                {
                    propertiesLoader.currentItemId = currentItem.id;
                    propertiesLoader.source = "PropertiesSet.qml";
                }
                else if( currentItem.pageModelType === "Photoset" )
                {
                    propertiesLoader.currentItemId = currentItem.pageItemId;
                    propertiesLoader.source = "PropertiesSet.qml";
                }
                else if( currentItem.type === "photo" )
                {
                    propertiesLoader.currentItemId = currentItem.id;
                    propertiesLoader.source = "PropertiesPhoto.qml";
                }
                else if( currentItem.pageModelType === "Photo" )
                {
                    propertiesLoader.currentItemId = currentItem.pageItemId;
                    propertiesLoader.source = "PropertiesPhoto.qml";
                }
                else
                {
                    propertiesLoader.source = "";
                }
                propertiesLoader.active = true;
            }
        }
    }
    Component {
        id: noSelectionPropertiesComp
        ColumnLayout {
            Label {
                text: FlickrBrowserApp.currentShownPage ?
                          FlickrBrowserApp.currentShownPage.pageModel.count + " items":
                          "N/A";
            }
        }
    }
}
