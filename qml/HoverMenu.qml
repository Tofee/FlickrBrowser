import QtQuick 2.0

Item {
    id: hoverMenu

    property real minimunHeight: 10
    property real maximunHeight: 50

    default property variant menuData;

    height: minimunHeight
    opacity: 0.5

    state: "hidden";

    states: [
        State {
            name: "visible"
            PropertyChanges { target: hoverMenu; height: maximunHeight; opacity: 1.0 }
        },
        State {
            name: "hidden"
            PropertyChanges { target: hoverMenu; height: minimunHeight; opacity: 0.5 }
        }
    ]

    Behavior on height { NumberAnimation { duration: 100 } }
    Behavior on opacity { NumberAnimation { duration: 100 } }

    data: [
        MouseArea {
            z: 100 // over the content
            anchors.fill: parent

            property bool activatedByClick: false

            propagateComposedEvents: true

            hoverEnabled: true
            onEntered: {
                if( !activatedByClick ) {
                    hideMenuTimer.stop();
                    hoverMenu.state = "visible";
                }
            }
            onExited: {
                if( !activatedByClick ) {
                    hideMenuTimer.start()
                }
            }
            /*
            onClicked: {
                if( !activatedByClick ) {
                    activatedByClick = true; // clicked to be shown permanently
                    hideMenuTimer.stop();
                    hoverMenu.state = "visible";
                    hoverEnabled = false;
                }
                else {
                    activatedByClick = false; // back to hover show
                    hoverEnabled = true;
                }
            }
            */
        },
        Timer {
            id: hideMenuTimer
            onTriggered: state = "hidden"
            running: false
            interval: 1000
        },

        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: hoverMenu.maximunHeight

            data: parent.menuData
        }
    ]
}
