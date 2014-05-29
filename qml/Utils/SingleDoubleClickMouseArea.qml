import QtQuick 2.0

MouseArea {
    id: cellMouseArea
    signal realClicked(variant mouse);
    signal realDoubleClicked(variant mouse);
    Timer {
        id: clickTimer
        property variant mouseArg;
        interval: 350
        running: false; repeat: false
        onTriggered: cellMouseArea.realClicked(clickTimer.mouseArg);
    }
    anchors.fill: collectionCell
    onClicked: {
        clickTimer.mouseArg = { modifiers: mouse.modifiers,
                                button: mouse.button,
                                buttons: mouse.buttons,
                                x: mouse.x,
                                y: mouse.y,
                                wasHeld: mouse.wasHeld };
        clickTimer.start();
    }
    onDoubleClicked: {
        clickTimer.stop();
        realDoubleClicked(mouse);
    }
}
