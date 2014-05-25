import QtQuick 2.0

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

        delegate: Item {
            height: ListView.view.height
            width: pathElementText.contentWidth

            Rectangle {
                anchors.fill: parent
                color: "#122d91"
            }
            Text {
                id: pathElementText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: "white"

                text: content
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    elementClicked(index);
                }
            }
        }
    }
}
