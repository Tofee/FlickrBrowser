import QtQuick 2.0
import QtQuick.Window 2.1

import "Core/OAuthCore.js" as OAuth
import "Core/DBAccess.js" as DBAccess

import "Singletons"
import "Core"

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
        MainView {
        }
    }

    property FlickrReply flickrReplyPhotosetList;
    Connections {
        target: flickrReplyPhotosetList
        onReceived: {
            FlickrBrowserApp.fillPhotosetListModel(response.photosets.photoset);
        }
    }
    Connections {
        target: FlickrBrowserApp
        onLogout: {
            DBAccess.clearToken();
            flickrBrowserRoot.state = "login";
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
