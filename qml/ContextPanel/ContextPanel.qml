import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../Utils" as Utils

Pane {
    // the column of panels
    ColumnLayout {
        id: panelsColumn
        anchors.fill: parent

        FilterPanel {
            anchors { left: parent.left; right: parent.right }
        }
        PropertiesPanel {
            anchors { left: parent.left; right: parent.right }
        }
        AuthoringPanel {
            anchors { left: parent.left; right: parent.right }
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter|Qt.AlignTop
        }
    }
}
