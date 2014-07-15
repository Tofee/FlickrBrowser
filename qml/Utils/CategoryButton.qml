import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Button {
    style: ButtonStyle {
        label: Item {
            Image {
                anchors.margins: 20
                anchors.fill: parent
                source: control.iconSource
                fillMode: Image.PreserveAspectFit
            }
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                text: control.text
            }
        }
    }
}
