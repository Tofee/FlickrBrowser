import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import "Singletons"
import "Browser"
import "ContextPanel"
import "Map"

/************ Main View ********************

  _____________________________
 |               |             |
 |               |_            |
 |               | |           |
 |               | |           |
 |               | |           |
 |    Browser    |_| Context   |
 |               | |  Panel    |
 |               | |           |
 |               | |           |
 |               |_|           |
 |               | |           |
 |               | |           |
 |               | |           |
 |               |_|           |
 |_______________|_____________|


 ********************************************/

/********** browser **************/
Item {
    readonly property bool inPortrait: ApplicationWindow.window.width < ApplicationWindow.window.height

    // Navigation pane
    NavigationPath {
        id: navigationPathItem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: !inPortrait ? contextPanel.width : undefined

        onElementClicked: {
            navigationPathItem.pop(depth);
            stackView.pop(stackView.get(depth));
        }
    }

    // Stacked view
    StackView {
        id: stackView
        anchors.top: navigationPath.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: !inPortrait ? contextPanel.width : undefined

        property NavigationPath navigationPath: navigationPathItem

        initialItem: MainPage {
            width: parent.width
            height: parent.height

            Component.onCompleted: navigationPathItem.push("Root");
        }

        Binding {
            target: FlickrBrowserApp
            property: "currentShownPage"
            value: stackView.currentItem
        }

        onCurrentItemChanged: {
            FlickrBrowserApp.currentSelection.clear();
        }
    }

    /********** context panel **************/
    Drawer {
        id: contextPanel
        edge: Qt.RightEdge

        width: 250
        height: parent.height

        modal: inPortrait
        interactive: inPortrait
        position: inPortrait ? 0 : 1
        visible: !inPortrait

        ContextPanel {
            anchors.fill: parent
        }
    }
}
