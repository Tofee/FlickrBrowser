import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core"
import "../Singletons"
import "../Utils"

// Display the properties of a collection of photosets.
Column {
    ExclusiveGroup { id: actionExclusiveGroup }
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
