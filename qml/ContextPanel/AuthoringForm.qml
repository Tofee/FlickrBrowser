import QtQuick 2.0
import QtQuick.Controls 1.1

import "../Utils"

Column {
    property alias formComponent: formLoader.sourceComponent
    property alias buttonText: formButton.text
    property ExclusiveGroup exclusiveGroup: null

    property alias checked: formButton.checked
    onCheckedChanged: if( !checked ) formLoader.item.clearForm();

    onExclusiveGroupChanged: {
        if (exclusiveGroup)
            exclusiveGroup.bindCheckable(formButton)
    }

    Button {
        id: formButton
        width: parent.width

        checkable: true
        style: CheckButtonStyle {}
    }
    Item {
        id: formItem
        clip: true
        height: formButton.checked ? formLoader.height : 0
        width: parent.width

        Behavior on height { NumberAnimation { duration: 300 } }

        Loader {
            id: formLoader
            width: formItem.width
            visible: formButton.checked
        }
    }
}
