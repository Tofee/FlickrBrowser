import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "../Singletons"

Item {
    height: selectionLoader.height

    // background
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../images/panel.png");
        fillMode: Image.TileVertically
    }

    Loader {
        anchors.left: parent.left
        anchors.right: parent.right

        id: selectionLoader
        sourceComponent: FlickrBrowserApp.currentSelection.count > 1 ? multiSelectionPropertiesComp :
                         FlickrBrowserApp.currentSelection.count === 1 ? singleSelectionPropertiesComp :
                                                                          noSelectionPropertiesComp
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
        id: singleSelectionPropertiesComp
        Item {
            height: propertiesLoader.height

            property variant selectedItem: FlickrBrowserApp.currentSelection.get(0)
            property string selectedItemType: selectedItem.type
            Loader {
                id: propertiesLoader

                anchors.left: parent.left
                anchors.right: parent.right

                property string selectedItemId: selectedItem.id
            }
            onSelectedItemTypeChanged: {
                propertiesLoader.active = false; // force unload
                if( selectedItemType === "collection" )
                    propertiesLoader.source = "PropertiesCollection.qml";
                else if( selectedItemType === "set" )
                    propertiesLoader.source = "PropertiesSet.qml";
                else if( selectedItemType === "photo" )
                    propertiesLoader.source = "PropertiesPhoto.qml";
                else
                    propertiesLoader.source = "";
                propertiesLoader.active = true;
            }
        }
    }
    Component {
        id: noSelectionPropertiesComp
        ColumnLayout {
            Label {
                text: FlickrBrowserApp.currentShownModel ?
                          FlickrBrowserApp.currentShownModel.count + " items":
                          "N/A";
            }
        }
    }
}
