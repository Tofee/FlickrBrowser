import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
    id: control
    property url iconSource

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.pressed ? "lightgrey" : "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        color: control.pressed ? "darkblue" : "white"
        radius: 2

        Image {
            anchors.margins: 20
            anchors.fill: parent
            source: control.iconSource
            fillMode: Image.PreserveAspectFit
        }
    }
}
