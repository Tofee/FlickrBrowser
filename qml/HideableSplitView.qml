import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

SplitView {
    id: root
    orientation: Qt.Vertical

    property bool contentVisible: true

    Component {
        id: separatorHandleHorizontal
        Item {
            height: 10
            MouseArea {
                // this MouseArea prevents dragging when the side panel
                // is hidden
                anchors.fill: parent
                enabled: root.contentVisible === false
            }
            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("images/SplitPaneHDividerBG.png");

                fillMode: Image.TileHorizontally
            }
            Image {
                anchors.centerIn: parent
                source: Qt.resolvedUrl("images/SplitPaneHDividerArrows.png");

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.contentVisible = !root.contentVisible;
                    }
                }
            }
        }
    }
    Component {
        id: separatorHandleVertical
        Item {
            width: 10
            MouseArea {
                // this MouseArea prevents dragging when the side panel
                // is hidden
                anchors.fill: parent
                enabled: root.contentVisible === false
            }
            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("images/SplitPaneVDividerBG.png");

                fillMode: Image.TileVertically
            }
            Image {
                anchors.centerIn: parent
                source: Qt.resolvedUrl("images/SplitPaneVDividerArrows.png");

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.contentVisible = !root.contentVisible;
                    }
                }
            }
        }
    }

    handleDelegate: root.orientation === Qt.Horizontal ? separatorHandleVertical : separatorHandleHorizontal

}
