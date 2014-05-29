import QtQuick 2.0
import QtQuick.Controls 1.1

import "Singletons"
import "Utils" as Utils

Item {
    id: collectionGridPage

    property ListModel pageModel
    property ListModel photosetListModel: FlickrBrowserApp.photosetListModel

    // Little trick to avoid feeding the Repeater and the Flow with too many items at the same time.
    // This avoids a crash on windows, so...
    ListModel {
        id: smoothlyFilledModel
    }
    Timer {
        property int i: 0
        interval: 10
        running: i<pageModel.count
        onTriggered: smoothlyFilledModel.append(pageModel.get(i++));
        repeat: true
    }
    /// end of little trick

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
                model: smoothlyFilledModel
                delegate:
                    Item {
                        id: delegateItem

                        height: collectionCell.height
                        width: collectionCell.width

                        property variant photoSetInfos: getPhotosetInfos(id)
                        property string photosetIcon: photoSetInfos ? photoSetInfos.primary_photo_extras.url_s : ""
                        property string photosetTitle: photoSetInfos ? photoSetInfos.title._content + "(" + String(parseInt(photoSetInfos.photos)+parseInt(photoSetInfos.videos)) + ")" : "Retrieving data...";

                        Connections {
                            target: FlickrBrowserApp.contextualFilter
                            onFilterChanged: {
                                delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.photosetTitle });
                            }
                        }
                        Component.onCompleted: {
                            delegateItem.visible = FlickrBrowserApp.contextualFilter.matches({ "title": delegateItem.photosetTitle });
                        }

                        function getPhotosetInfos(myId) {
                            // Find the size of that album
                            for( var i = 0; i <= photosetListModel.count; i++ ) {
                                if( photosetListModel.get(i).id === myId ) {
                                    return photosetListModel.get(i);
                                }
                            }
                        }

                        Column {
                            id: collectionCell
                            width: collectionImage.width

                            Image {
                                id: collectionImage
                                height: 180
                                width: 180

                                fillMode: Image.PreserveAspectCrop
                                source: photosetIcon

                                Rectangle {
                                    id: selectionRect
                                    anchors.fill: parent
                                    opacity: 0.3
                                    color: "blue"

                                    visible: delegateItem.photoSetInfos.selected ? true : false
                                }
                            }
                            Text {
                                id: collectionTitle
                                anchors.left: parent.left
                                anchors.right: parent.right

                                font.pixelSize: 14
                                color: "white"

                                text: photosetTitle
                                wrapMode: Text.Wrap
                            }
                        }
                        Utils.SingleDoubleClickMouseArea {
                            id: collectionCellMouseArea
                            anchors.fill: collectionCell

                            onRealClicked: {
                                if( !(mouse.modifiers & Qt.ControlModifier) )
                                    FlickrBrowserApp.currentSelection.clear();

                                if( !delegateItem.photoSetInfos.selected )
                                {
                                    FlickrBrowserApp.currentSelection.addToSelection({ "type": "set", "id": id, "object": delegateItem.photoSetInfos });
                                }
                            }
                            onRealDoubleClicked: {
                                // We are opening a photoset album
                                console.log("showing photoset id = " + id);
                                var stackView = collectionGridPage.Stack.view;
                                stackView.navigationPath.push(delegateItem.photosetTitle);
                                stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                                properties: {"photosetId": id}});
                            }
                        }
                    }
            }
        }
    }
}
