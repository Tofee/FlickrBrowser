import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI

// Display the properties of a collection.
Column {
    move: Transition {
        NumberAnimation { properties: "y"; duration: 300 }
    }

    ExclusiveGroup { id: actionExclusiveGroup }
    Button {
        id: createCollectionButton
        width: parent.width
        exclusiveGroup: actionExclusiveGroup

        text: "Create collection..."
        checkable: true
    }
    FormCreateCollection {
        width: parent.width
        visible: createCollectionButton.checked
    }
    Button {
        id: moveCollectionButton
        width: parent.width
        exclusiveGroup: actionExclusiveGroup

        text: "Move selection..."
        checkable: true
    }
    FormMoveCollection {
        width: parent.width
        visible: moveCollectionButton.checked
    }
    Button {
        id: removeCollectionButton
        width: parent.width
        exclusiveGroup: actionExclusiveGroup

        text: "Delete collection..."
        checkable: true
    }
    Column {
        width: parent.width
        visible: removeCollectionButton.checked
        Label {
            width: parent.width
            text: "This will permanently remove the selected collections!"
            wrapMode: Text.Wrap
        }
        RowLayout {
            Button {
                text: "Cancel"
            }
            Button {
                text: "OK"
            }
        }
    }
}
