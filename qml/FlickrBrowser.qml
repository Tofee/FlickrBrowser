import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import "OAuthCore.js" as OAuth
import "DBAccess.js" as DBAccess
import "FlickrAPI.js" as FlickrAPI

import "Singletons"

Item {
    id: flickrBrowserRoot

    width: 700
    height: 450

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
            property bool collectionTreeRetrieved: false
            property bool photosetListRetrieved: false

            Connections {
                target: FlickrBrowserApp
                onCollectionTreeChanged: {
                    collectionTreeRetrieved = true;
                    if( collectionTreeRetrieved && photosetListRetrieved )flickrBrowserRoot.state = "logged";
                }
                onPhotosetListChanged: {
                    photosetListRetrieved = true;
                    if( collectionTreeRetrieved && photosetListRetrieved )flickrBrowserRoot.state = "logged";
                }
            }

            onAuthorised: {
                FlickrAPI.callFlickrMethod("flickr.collections.getTree", null, cb_collectionlist);
                FlickrAPI.callFlickrMethod("flickr.photosets.getList", [ [ "primary_photo_extras", "url_sq" ] ], cb_photosetlist);
            }

            function cb_collectionlist(response) {
                FlickrBrowserApp.fillCollectionTreeModel(response.collections.collection);
            }

            function cb_photosetlist(response) {
                FlickrBrowserApp.fillPhotosetListModel(response.photosets.photoset);
            }
        }
    }
    // main view
    Component {
        id: rootViewComp
        Item {
            // Navigation pane
            NavigationPath {
                id: navigationPathItem
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                onElementClicked: {
                        navigationPathItem.pop();
                        stackView.pop();
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
                }
            }
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

