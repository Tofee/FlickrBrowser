import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "Singletons"
import "Browser"
import "ContextPanel"
import "Map"

/************ Main View ********************

  _______________________________________
 |                      |                |
 |                      |                |
 |      Browser         |                |
 |                      |                |
 |                      ↔                |
 |___________↕__________|   Context Panel|
 |                      |                |
 |                      |                |
 |      Map             |                |
 |                      |                |
 |______________________|________________|


 ********************************************/

HideableSplitView {
    id: mainAndContextSplitView
    orientation: Qt.Horizontal

    HideableSplitView {
        Layout.fillWidth: true

        id: browserAndMapSplitView
        orientation: Qt.Vertical
        contentVisible: false // hide Map at startup

        /********** browser **************/
        Item {
            Layout.fillHeight: true

            // Navigation pane
            NavigationPath {
                id: navigationPathItem
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

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
        }
        /********** map **************/
        Rectangle {
            id: mapArea
            color: "grey"

            // manage width of the panel depending on its visibility
            height: 0
            Layout.minimumHeight: 0
            property bool contentVisible: browserAndMapSplitView.contentVisible

            SequentialAnimation {
                id: showMapAreaAnimation
                NumberAnimation { target: mapArea; property: "height"; to: 250; duration: 200 }
                PropertyAction { target: mapArea; property: "Layout.minimumHeight"; value: 250 }
            }
            SequentialAnimation {
                id: hideMapAreaAnimation
                PropertyAction { target: mapArea; property: "Layout.minimumHeight"; value: 0 }
                NumberAnimation { target: mapArea; property: "height"; to: 0; duration: 200 }
            }

            onContentVisibleChanged: {
                if( contentVisible ) {
                    showMapAreaAnimation.start();
                }
                else {
                    hideMapAreaAnimation.start();
                }
            }

            MapView {
                visible: mapArea.contentVisible && height >= 250
                anchors.fill: parent
            }
        }
    }
    /********** context panel **************/
    Rectangle {
        id: contextPanel
        color: "grey"

        // manage width of the panel depending on its visibility
        Layout.minimumWidth: 250
        property bool contentVisible: mainAndContextSplitView.contentVisible

        SequentialAnimation {
            id: showPanelAnimation
            NumberAnimation { target: contextPanel; property: "width"; to: 250; duration: 200 }
            PropertyAction { target: contextPanel; property: "Layout.minimumWidth"; value: 250 }
        }
        SequentialAnimation {
            id: hidePanelAnimation
            PropertyAction { target: contextPanel; property: "Layout.minimumWidth"; value: 0 }
            NumberAnimation { target: contextPanel; property: "width"; to: 0; duration: 200 }
        }

        onContentVisibleChanged: {
            if( contentVisible ) {
                showPanelAnimation.start();
            }
            else {
                hidePanelAnimation.start();
            }
        }

        ContextPanel {
            visible: contextPanel.contentVisible && width >= 250
            anchors.fill: parent

            isMapActive: browserAndMapSplitView.contentVisible
        }
    }
}
