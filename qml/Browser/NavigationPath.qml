import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    height: 30

    ListModel {
        id: navigationElements
    }

    function push(content) {
        navigationElements.append({"content": content});
    }
    function pop(downTo) {
        if( null === downTo ) downTo = Math.max(0, navigationElements.count-1);
        while(navigationElements.count-1 > downTo) {
            navigationElements.remove(navigationElements.count-1);
        }
    }

    signal elementClicked(int depth);

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#333333"
    }

    ListView {
        orientation: ListView.Horizontal
        anchors.fill: parent
        anchors.margins: 3

        model: navigationElements
        spacing: 3

        delegate: Button {
                      id: control
                      enabled: index !== (navigationElements.count-1)
                      text: content
                      //tooltip: "Go back to " + content
                      onClicked: elementClicked(index);

                      background: Rectangle {
                          border.width: 1
                          border.color: control.pressed ? "#b6dafc" : "4a9af8"
                          radius: 6
                          gradient: Gradient {
                              GradientStop { position: 0.0; color:  control.pressed ? "#4a9af8" : "#b6dafc" }
                              GradientStop { position: 0.67; color: control.pressed ? "#b6dafc" :  control.enabled ? "#4a9af8":"#b6dafc" }
                          }
                      }
                  }
    }
}
