import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import "../Utils" as Utils

Item {
    // Left part: check buttons to choose what panels to show

    property alias isFilterPanelActive: filterButton.checked
    property alias isPropertiesPanelActive: propertiesButton.checked
    property alias isEditionPanelActive: editionButton.checked

    Column {
        id: buttonsColumn
        anchors {
            left: parent.left
            top: parent.top
        }
        width: filterButton.width + 5

        Utils.VerticalCheckButton {
            id: filterButton
            text: "Filter"
        }
        Utils.VerticalCheckButton {
            id: propertiesButton
            text: "Properties"
        }
        Utils.VerticalCheckButton {
            id: editionButton
            text: "Edition"
        }
    }

    // Right part: the column of panels
    Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: buttonsColumn.right
            right: parent.right
        }

        // background
        Image {
            anchors { left: parent.left; right: parent.right }
            height: panelsColumn.height

            source: Qt.resolvedUrl("../images/panel.png");
            fillMode: Image.TileVertically

            Column {
                id: panelsColumn
                anchors { top: parent.top; left: parent.left; right: parent.right }

                move: Transition {
                    NumberAnimation { properties: "y"; duration: 200 }
                }

                FilterPanel {
                    visible: isFilterPanelActive
                    anchors { left: parent.left; right: parent.right }
                }
                PropertiesPanel {
                    visible: isPropertiesPanelActive
                    anchors { left: parent.left; right: parent.right }
                }
                AuthoringPanel {
                    visible: isEditionPanelActive
                    anchors { left: parent.left; right: parent.right }
                }
            }
        }
    }
}
