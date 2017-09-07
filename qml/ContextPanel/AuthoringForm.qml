import QtQuick 2.9
import QtQuick.Controls 2.2

import "../Utils"

Column {
    property alias formComponent: formLoader.sourceComponent
    property alias buttonText: formButton.text
    property ButtonGroup exclusiveGroup: null

    property alias checked: formButton.checked
    onCheckedChanged: if( !checked ) formLoader.item.clearForm();

    Button {
        id: formButton
        width: parent.width

        checkable: true
        ButtonGroup.group: exclusiveGroup
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
