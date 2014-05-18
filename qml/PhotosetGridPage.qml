import QtQuick 2.0
import QtQuick.Controls 1.1

import "FlickrAPI.js" as FlickrAPI

Item {
    id: photosetGridPage

    property string pagePath: "/"

    property string photosetId;

    ListModel {
        id: photosetModel;
    }

    Component.onCompleted: {
        // Query Flickr to retrieve the list of the photos
        FlickrAPI.callFlickrMethod("flickr.photosets.getPhotos", [ [ "photoset_id", photosetId ], [ "extras", "url_s, url_t" ] ], function(response) {
            if(response && response.photoset && response.photoset.photo)
            {
                var i;
                for( i=0; i<response.photoset.photo.length; i++ ) {
                    photosetModel.append(response.photoset.photo[i]);
                }
            }
        });
    }

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: photosGridView.height
        clip: true
        flickableDirection: Flickable.VerticalFlick

        Flow {
            id: photosGridView

            x: 0; y: 0
            width: photosetGridPage.width

            Repeater {
                model: photosetModel

                delegate:
                    Item {
                        id: photoCell
                        width: photoImage.width
                        height: photoImage.height

                        Image {
                            id: photoImage
                            height: height_s
                            width: width_s

                            fillMode: Image.PreserveAspectFit
                            source: url_s
                        }
                        Item {
                            // show title at the bottom of the image, on mouse over
                            anchors.left: photoImage.left
                            anchors.right: photoImage.right
                            anchors.bottom: photoImage.bottom
                            height: collectionTitle.height * 1.1

                            opacity:photoCellMouseArea.containsMouse ? 1.0: 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Rectangle {
                                anchors.fill: parent
                                color: "black"
                                opacity: 0.8
                            }
                            Text {
                                id: collectionTitle
                                anchors.left: parent.left
                                anchors.right: parent.right

                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap

                                text: title
                            }
                        }
                        MouseArea {
                            id: photoCellMouseArea
                            anchors.fill: photoCell

                            hoverEnabled: true

                            onClicked: {
                                // show full screen photo
                                var stackView = collectionGridPage.Stack.view;
                                stackView.navigationPath.push(title);
                                stackView.push({item: Qt.resolvedUrl("PhotoPage.qml"),
                                                properties: {"photoId": id}});
                            }
                        }
                    }
            }
        }
    }
}
