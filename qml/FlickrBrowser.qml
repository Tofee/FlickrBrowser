import QtQuick 2.0
import QtQuick.Controls 1.1
import "OAuthCore.js" as OAuth
import "DBAccess.js" as DBAccess
import "FlickrAPI.js" as FlickrAPI

Item {
    id: flickrBrowserRoot

    width: 360
    height: 360

    property alias rootCollectionTreeModel: rootCollectionTreeModel
    property alias rootPhotosetListModel: rootPhotosetListModel

    ListModel {
        id: rootCollectionTreeModel
    }
    ListModel {
        id: rootPhotosetListModel
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

    // collection view
    Component {
        id: collectionsBrowserComp
        CollectionsBrowser {
            rootCollectionTreeModel: flickrBrowserRoot.rootCollectionTreeModel
            rootPhotosetListModel: flickrBrowserRoot.rootPhotosetListModel
        }
    }
    // photoset view
    Component {
        id: photosetsBrowserComp
        PhotosetsBrowser {
            rootPhotosetListModel: flickrBrowserRoot.rootPhotosetListModel
        }
    }
    // login page
    Component {
        id: loginPageComp
        LoginPage {
            property int remainingCounter: 2
            onRemainingCounterChanged: if( remainingCounter === 0 ) flickrBrowserRoot.state = "logged";

            onAuthorised: {
                FlickrAPI.callFlickrMethod("flickr.collections.getTree", null, cb_collectionlist);
                FlickrAPI.callFlickrMethod("flickr.photosets.getList", [ [ "primary_photo_extras", "url_sq" ] ], cb_photosetlist);
            }

            function cb_collectionlist(response) {
                //console.log(JSON.stringify(response));
                var i;
                for( i=0; i<response.collections.collection.length; i++ ) {
                    rootCollectionTreeModel.append(response.collections.collection[i]);
                }

                remainingCounter--;
            }

            function cb_photosetlist(response) {
                //console.log(JSON.stringify(response));
                var i;
                for( i=0; i<response.photosets.photoset.length; i++ ) {
                    rootPhotosetListModel.append(response.photosets.photoset[i]);
                }

                remainingCounter--;
            }
        }
    }
    // root tab view
    Component {
        id: tabViewComp
        TabView {
            id: rootTabView
            Component.onCompleted: {
                rootTabView.addTab("C", collectionsBrowserComp);
                rootTabView.addTab("P", photosetsBrowserComp);
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
            PropertyChanges { target: loginLoader; sourceComponent: tabViewComp }
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

