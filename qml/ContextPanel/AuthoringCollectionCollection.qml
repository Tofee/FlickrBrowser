import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core"
import "../Singletons"
import "../Utils"

// Display the properties of a collection.
Column {
    ExclusiveGroup { id: actionExclusiveGroup }
    AuthoringForm {
        width: parent.width

        buttonText: "Create collection..."
        formComponent: FormCreateCollection {}
        exclusiveGroup: actionExclusiveGroup
    }
    AuthoringForm {
        width: parent.width

        buttonText: "Move selection..."
        formComponent: FormMoveCollection {}
        exclusiveGroup: actionExclusiveGroup
    }
    AuthoringForm {
        width: parent.width

        buttonText: "Create icon..."
        formComponent: FormCreateIconCollection {}
        exclusiveGroup: actionExclusiveGroup
    }
    AuthoringForm {
        width: parent.width

        buttonText: "Delete collection..."
        formComponent: FormRemoveCollection {}
        exclusiveGroup: actionExclusiveGroup
    }
}
