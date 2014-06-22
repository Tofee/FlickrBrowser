import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import "Core/OAuthCore.js" as OAuth
import "Core/DBAccess.js" as DBAccess

import "Singletons"
import "Core"
import "ContextPanel"
import "Browser"

Item {
    id: flickrBrowserRoot

    width: 900
    height: 550

/*
    HoverMenu {
        id: bottomHoverMenu

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        minimunHeight: 10
        maximunHeight: 50

        Rectangle {
            anchors.fill: parent
            color: "grey"
            opacity: 0.2

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    stackView.navigationPath.push("Photosets (all)");
                    stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml"),
                                    properties: {"photoSetListModel": rootPhotosetListModel}});
                }
            }
        }
    }
*/

    // login page
    Component {
        id: loginPageComp
        LoginPage {
            onAuthorised: {
                flickrBrowserRoot.state = "logged";
            }
        }
    }
    // main view
    Component {
        id: rootViewComp
        SplitView {
            id: mainSplitView

            orientation: Qt.Horizontal
            handleDelegate: Item {
                property bool panelShown: true
                width: 10
                MouseArea {
                    // this MouseArea prevents dragging when the side panel
                    // is hidden
                    anchors.fill: parent
                    enabled: contextPanel.contentVisible === false
                }
                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("images/SplitPaneDividerBG.png");

                    fillMode: Image.TileVertically
                }
                Image {
                    anchors.centerIn: parent
                    source: Qt.resolvedUrl("images/SplitPaneDividerArrows.png");

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            contextPanel.contentVisible = !contextPanel.contentVisible;
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true

                // Navigation pane
                NavigationPath {
                    id: navigationPathItem
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    onElementClicked: {
                        navigationPathItem.pop(depth);
                        stackView.pop(stackView.get(depth));
                    }
                }

                // Stacked view
                StackView {
                    id: stackView
                    anchors.top: navigationPath.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right

                    property NavigationPath navigationPath: navigationPathItem

                    initialItem: MainPage {
                        width: parent.width
                        height: parent.height

                        Component.onCompleted: navigationPathItem.push("Root");
                    }

                    Binding {
                        target: FlickrBrowserApp
                        property: "currentShownPage"
                        value: stackView.currentItem
                    }

                    onCurrentItemChanged: {
                        FlickrBrowserApp.currentSelection.clear();
                    }
                }
            }
            Rectangle {
                id: contextPanel
                color: "grey"

                // manage width of the panel depending on its visibility
                Layout.minimumWidth: 250
                property bool contentVisible: true

                SequentialAnimation {
                    id: showPanelAnimation
                    NumberAnimation { target: contextPanel; property: "width"; to: 250; duration: 200 }
                    PropertyAction { target: contextPanel; property: "Layout.minimumWidth"; value: 250 }
                }
                SequentialAnimation {
                    id: hidePanelAnimation
                    PropertyAction { target: contextPanel; property: "Layout.minimumWidth"; value: 0 }
                    NumberAnimation { target: contextPanel; property: "width"; to: 0; duration: 200 }
                }

                onContentVisibleChanged: {
                    if( contentVisible ) {
                        showPanelAnimation.start();
                    }
                    else {
                        hidePanelAnimation.start();
                    }
                }

                ContextPanel {
                    visible: contextPanel.contentVisible && width >= 250
                    anchors.fill: parent
                }
            }
        }
    }

    property FlickrReply flickrReplyPhotosetList;
    Connections {
        target: flickrReplyPhotosetList
        onReceived: {
            FlickrBrowserApp.fillPhotosetListModel(response.photosets.photoset);
        }
    }


    states: [
        State {
            name: "login"
            PropertyChanges { target: loginLoader; sourceComponent: loginPageComp }
        },
        State {
            name: "logged"
            PropertyChanges { target: loginLoader; sourceComponent: rootViewComp }
            StateChangeScript {
                script: {
                    flickrReplyPhotosetList = FlickrBrowserApp.callFlickr("flickr.photosets.getList", [ [ "primary_photo_extras", "url_sq,url_s" ] ]);
                }
            }
        }
    ]

    Component.onCompleted: state = "login";

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "black"
    }

    Loader {
        id: loginLoader
        anchors.fill: parent
    }
}
