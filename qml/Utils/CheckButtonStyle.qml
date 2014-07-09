import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

ButtonStyle
{
    background: Rectangle {
        id: backgroundRect

        property color color1: "#eee"
        property color color2: "#ccc"

        implicitWidth: 100
        implicitHeight: 25
        border.width: 1
        border.color: control.checked ? "black" : "#888"
        radius: 6
        gradient: Gradient {
            GradientStop { position: 0.0; color:  control.pressed ? color2 : color1 }
            GradientStop { position: 0.67; color: control.pressed ? color1 : color2 }
        }

        states: [
            State {
                when: control.checked
                PropertyChanges { target:backgroundRect; color1: "#116a06"; color2: "#22c70d" }
            }
        ]
    }
}
