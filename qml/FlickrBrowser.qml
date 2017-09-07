import QtQuick 2.9
import QtQuick.Window 2.1

import QtQuick.Controls 2.2

import Qt.labs.settings 1.0

import "Core/OAuthCore.js" as OAuth
import "Core/DBAccess.js" as DBAccess

import "Singletons"
import "Core"

ApplicationWindow {
    id: flickrBrowserRoot

    width: 900
    height: 550

    color: "black"

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

    property Settings flickrKeysSettings: Settings {
        category: "FlickrKeys"
        property string consumerKey: ""
        property string consumerSecret: ""
    }
    property Settings localFolderSyncSettings: Settings {
        category: "LocalSync"
        property string localPhotoFolderRoot: ""
    }

    // Initial config page
    Component {
        id: initialConfigComp
        InitialConfigPage {
            consumerKey: flickrBrowserRoot.flickrKeysSettings.consumerKey
            consumerSecret: flickrBrowserRoot.flickrKeysSettings.consumerSecret

            onSettingsDone: {
                flickrBrowserRoot.flickrKeysSettings.consumerKey = consumerKey;
                flickrBrowserRoot.flickrKeysSettings.consumerSecret = consumerSecret;

                initializerItem.setupDone();
            }
        }
    }

    // login page
    Component {
        id: loginPageComp
        LoginPage {
            Component.onCompleted: checkToken();
            onAuthorized: {
                initializerItem.loginDone();
            }
        }
    }

    // main view (for touch screens)
    Component {
        id: mainViewTouchComp
        MainViewTouch {
        }
    }

    Loader {
        id: rootLoader
        anchors.fill: parent
    }

    Item {
        id: initializerItem

        signal setupDone();
        signal loginDone();

        Component.onCompleted: {
            // setup already done ?
            if(flickrBrowserRoot.flickrKeysSettings.consumerKey &&
               flickrBrowserRoot.flickrKeysSettings.consumerSecret) {
                initializerItem.setupDone();
            } else {
                initializerItem.state = "setup";
            }
        }

        property FlickrReply flickrReplyPhotosetList;
        Connections {
            target: initializerItem.flickrReplyPhotosetList
            onReceived: {
                FlickrBrowserApp.fillPhotosetListModel(response.photosets.photoset);
            }
        }
        Connections {
            target: FlickrBrowserApp
            onLogout: {
                DBAccess.clearToken();
                initializerItem.state = "login";
            }
        }

        onSetupDone: {
            // Read the configuation
            if( flickrKeysSettings.consumerKey && flickrKeysSettings.consumerSecret ) {

                OAuth.setConsumerKey(flickrKeysSettings.consumerKey, flickrKeysSettings.consumerSecret);
                FlickrBrowserApp.localPhotoFolderRoot = localFolderSyncSettings.localPhotoFolderRoot;

                initializerItem.state = "login";
            }
            else {
                console.log("Couldn't read consumer key and secret from settings");
            }
        }

        onLoginDone: {
            initializerItem.flickrReplyPhotosetList = FlickrBrowserApp.callFlickr("flickr.photosets.getList", [ [ "primary_photo_extras", "url_sq,url_s" ] ]);
            initializerItem.state = "logged";
        }

        states: [
            State {
                name: "setup"
                PropertyChanges { target: rootLoader; sourceComponent: initialConfigComp }
            },
            State {
                name: "login"
                PropertyChanges { target: rootLoader; sourceComponent: loginPageComp }
            },
            State {
                name: "logged"
                PropertyChanges { target: rootLoader; sourceComponent: mainViewTouchComp }
            }
        ]
    }
}
