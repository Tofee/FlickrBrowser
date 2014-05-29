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
            spacing: 3

            Repeater {
                model: smoothlyFilledModel
                delegate:
                    Utils.FlowListDelegate {
                        id: delegateItem

                        property variant photoSetInfos: getPhotosetInfos(id)
                        imageSource: photoSetInfos ? photoSetInfos.primary_photo_extras.url_s : ""
                        textContent: photoSetInfos ? photoSetInfos.title._content + "(" + String(parseInt(photoSetInfos.photos)+parseInt(photoSetInfos.videos)) + ")" : "Retrieving data...";

                        imageHeight: 180
                        imageWidth: 180
                        imageFillMode: Image.PreserveAspectCrop
                        isSelected: (photoSetInfos && photoSetInfos.selected) ? true : false
                        textPixelSize: 14

                        function getPhotosetInfos(myId) {
                            // Find the size of that album
                            for( var i = 0; i <= photosetListModel.count; i++ ) {
                                if( photosetListModel.get(i).id === myId ) {
                                    return photosetListModel.get(i);
                                }
                            }
                        }

                        onClicked: {
                            if( !(mouse.modifiers & Qt.ControlModifier) )
                                FlickrBrowserApp.currentSelection.clear();

                            if( !delegateItem.selected )
                            {
                                FlickrBrowserApp.currentSelection.addToSelection({ "type": "set", "id": id, "object": delegateItem.photoSetInfos });
                            }
                        }
                        onDoubleClicked: {
                            // We are opening a photoset album
                            var stackView = collectionGridPage.Stack.view;
                            stackView.navigationPath.push(delegateItem.textContent);
                            stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                            properties: {"photosetId": id}});
                        }
                    }
            }
        }
    }
}
