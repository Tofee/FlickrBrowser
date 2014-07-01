import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

ButtonStyle
{
    background: Rectangle {
        border.width: control.activeFocus ? 2 : 1
        border.color: "#888"
        radius: 4
        color: control.checked ? "#ccc" : "#eee"
    }
}
