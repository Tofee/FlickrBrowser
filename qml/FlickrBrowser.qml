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

    signal initialized();
    onInitialized: state = "login";

    Component.onCompleted: {
        console.log("INFO: hasExtendedFlickrPlugins = " + (typeof hasExtendedFlickrPlugins !== 'undefined'));
        state = "initialize";
    }

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
            Component.onCompleted: checkToken();
            onAuthorized: {
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
            name: "initialize"
            StateChangeScript {
                script: {
                        // Read the configuation file
                        var xhr = new XMLHttpRequest;
                        var configFilePath = Qt.resolvedUrl("../config/flickr-browser-config.json");
                        xhr.open("GET", configFilePath);
                        xhr.onreadystatechange = function() {
                            if( xhr.readyState === XMLHttpRequest.DONE ) {
                                var fullConfig = {};
                                if( xhr.responseText ) {
                                    fullConfig = JSON.parse(xhr.responseText);
                                }

                                if( fullConfig &&
                                    fullConfig.consumerKey && fullConfig.consumerSecret &&
                                    fullConfig.localPhotoFolderRoot ) {

                                    OAuth.setConsumerKey(fullConfig.consumerKey, fullConfig.consumerSecret);
                                    FlickrBrowserApp.localPhotoFolderRoot = fullConfig.localPhotoFolderRoot;

                                    flickrBrowserRoot.initialized();
                                }
                                else {
                                    console.log("Couldn't read consumer key and secret from " + configFilePath);
                                    console.log("Config file content: " + xhr.responseText);
                                    console.log("Parsed config content: " + JSON.stringify(fullConfig));

                                    Qt.quit();
                                }
                            }
                        }
                        xhr.send();
                }
            }
        },
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
