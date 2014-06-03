import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core"
import "../Singletons"

// Display the properties of a collection of photosets.
Column {
    move: Transition {
        NumberAnimation { properties: "y"; duration: 300 }
    }

    ExclusiveGroup { id: actionExclusiveGroup }
    Button {
        id: createCollectionTreeButton
        width: parent.width
        exclusiveGroup: actionExclusiveGroup

        text: "Create collection tree from albums..."
        checkable: true
    }
    FormCreatePhotosetCollectionTree {
        width: parent.width
        visible: createCollectionTreeButton.checked
    }
    Button {
        id: createCollectionButton
        width: parent.width
        exclusiveGroup: actionExclusiveGroup

        text: "Create collection..."
        checkable: true
    }
    FormCreatePhotosetCollection {
        width: parent.width
        visible: createCollectionButton.checked
    }
    Button {
        id: removePhotosetButton
        width: parent.width
        exclusiveGroup: actionExclusiveGroup

        text: "Delete album..."
        checkable: true
    }
    FormRemovePhotoset {
        width: parent.width
        visible: removePhotosetButton.checked
    }
}
