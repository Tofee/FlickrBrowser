import QtQuick 2.0

Rectangle {
    width: 10
    height: 10
    property string title
    property variant targetPoint
    property int verticalSpacing: 1
    x: targetPoint[0] - width/2
    y: targetPoint[1] - height/2
    border.width: 3
    border.color: "#88ff00ff"
    radius: 7
    Text {
        anchors.left: parent.right
        anchors.leftMargin: 12
        y: (24 * verticalSpacing) - 12
        text: title
        style: Text.Outline
        styleColor: "white"
        font.pixelSize: 24
    }
}
