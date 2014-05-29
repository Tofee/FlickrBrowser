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
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: filterButton.width

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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: buttonsColumn.right
        anchors.right: parent.right

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            FilterPanel {
                visible: isFilterPanelActive

                anchors.left: parent.left
                anchors.right: parent.right
            }
            PropertiesPanel {
                visible: isPropertiesPanelActive

                anchors.left: parent.left
                anchors.right: parent.right
            }
            Rectangle {
                visible: isEditionPanelActive

                anchors.left: parent.left
                anchors.right: parent.right
                height: 150

                color: "red"

/*

Official API:
flickr.collections.getTree Optional user_id
flickr.collections.getInfo Required collection_id
NOT official:
flickr.collections.create Optional description, Optional parent_id, Required title, Optional after_new_coll
flickr.collections.sortCollections Optional child_collection_ids, Optional collection_id, Optional no_move
flickr.collections.editSets Required collection_id, Optional do_remove, Required photoset_ids
flickr.collections.createIcon Required collection_id, Required photo_ids
flickr.collections.removeSet Required collection_id, Required photoset_id
flickr.collections.delete Required collection_id, Optional recursive
flickr.collections.moveCollection Required collection_id, Required parent_collection_id
flickr.collections.editMeta Optional collection_id, Optional description, Optional title

*/
            }
        }
    }
}
