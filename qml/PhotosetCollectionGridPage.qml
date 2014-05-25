import QtQuick 2.0
import QtQuick.Controls 1.1

import "Singletons"
import "Utils" as Utils

Item {
    id: collectionGridPage

    property ListModel pageModel
    property ListModel photoSetListModel: FlickrBrowserApp.photosetListModel

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: collectionsGridView.height
        clip: true
        flickableDirection: Flickable.VerticalFlick

        Flow {
            id: collectionsGridView

            x: 0; y: 0
            width: collectionGridPage.width

            Repeater {
                model: pageModel
                delegate:
                    Item {
                        id: delegateItem

                        height: collectionCell.height
                        width: collectionCell.width

                        property string photosetTitle: getPhotosetTitle()
                        property string photosetIcon: getPhotosetIcon()

                        Connections {
                            target: FlickrBrowserApp.contextualFilter
                            onFilterChanged: {
                                delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.photosetTitle });
                            }
                        }
                        Component.onCompleted: {
                            delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.photosetTitle });
                        }

                        function getPhotosetTitle() {
                            // Find the size of that album
                            var i;
                            for( i = 0; i <= photoSetListModel.count; i++ ) {
                                var photoSetInfo = photoSetListModel.get(i);
                                if( photoSetInfo && photoSetInfo.id === id ) {
                                    return photoSetInfo.title._content + "(" + String(parseInt(photoSetInfo.photos)+parseInt(photoSetInfo.videos)) + ")";
                                }
                            }
                        }
                        function getPhotosetIcon() {
                            // Find the icon of that album
                            var i;
                            for( i = 0; i <= photoSetListModel.count; i++ ) {
                                var photoSetInfo = photoSetListModel.get(i);
                                if( photoSetInfo && photoSetInfo.id === id ) {
                                    return photoSetInfo.primary_photo_extras.url_sq;
                                }
                            }
                        }

                        Column {
                            id: collectionCell
                            width: collectionImage.width

                            Image {
                                id: collectionImage
                                height: 150
                                width: 150

                                fillMode: Image.PreserveAspectFit
                                source: photosetIcon
                            }
                            Text {
                                id: collectionTitle
                                anchors.left: parent.left
                                anchors.right: parent.right

                                color: "white"

                                text: photosetTitle
                                wrapMode: Text.Wrap
                            }
                        }
                        Utils.SingleDoubleClickMouseArea {
                            anchors.fill: collectionCell
                            onRealClicked: {
                                if( !(mouse.modifiers & Qt.ControlModifier) )
                                    FlickrBrowserApp.currentSelection.clear();
                                FlickrBrowserApp.currentSelection.addToSelection({ "type": "set", "id": id });
                            }
                            onRealDoubleClicked: {
                                // We are opening a photoset album
                                console.log("showing photoset id = " + id);
                                var stackView = collectionGridPage.Stack.view;
                                stackView.navigationPath.push(collectionTitle.text);
                                stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                                properties: {"photosetId": id}});
                            }
                        }
                    }
            }
        }
    }
}
