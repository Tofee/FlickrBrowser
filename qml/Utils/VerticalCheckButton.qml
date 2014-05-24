import QtQuick 2.0
import QtQuick.Controls 1.1

Item {
    width: button.height
    height: button.width

    property alias text: button.text
    property alias style: button.style
    property alias iconSource: button.iconSource
    property alias checked: button.checked

    Button {
        id: button

        x: 0
        y: width
        rotation: -90
        transformOrigin: Item.TopLeft

        checkable: true
    }
}
