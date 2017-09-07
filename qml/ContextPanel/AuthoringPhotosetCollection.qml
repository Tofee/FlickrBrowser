import QtQuick 2.9
import QtQuick.Controls 2.2

import "../Core"
import "../Singletons"
import "../Utils"

// Display the properties of a collection of photosets.
Column {
    ButtonGroup { id: actionExclusiveGroup }
    AuthoringForm {
        width: parent.width

        buttonText: "Create collection..."
        formComponent: FormCreatePhotosetCollection {}
        exclusiveGroup: actionExclusiveGroup
    }
    AuthoringForm {
        width: parent.width

        buttonText: "(BUGGED) Add Album..."
        formComponent: FormAddPhotoSetToCollection {}
        exclusiveGroup: actionExclusiveGroup
    }
    AuthoringForm {
        width: parent.width

        buttonText: "Delete album..."
        formComponent: FormRemovePhotoset {}
        exclusiveGroup: actionExclusiveGroup
    }
}
