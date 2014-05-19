import QtQuick 2.0
import QtQuick.Controls 1.1

import "FlickrAPI.js" as FlickrAPI

Item {
    id: photosetGridPage

    property string photosetId;

    property real spacing : 5;

    ListModel {
        id: photosetModel;
    }

    Component.onCompleted: {
        // Query Flickr to retrieve the list of the photos
        FlickrAPI.callFlickrMethod("flickr.photosets.getPhotos", [ [ "photoset_id", photosetId ], [ "extras", "url_s, url_o" ] ], function(response) {
            if(response && response.photoset && response.photoset.photo)
            {
                var i;
                for( i=0; i<response.photoset.photo.length; i++ ) {
                    var currentPhoto = response.photoset.photo[i];
                    currentPhoto.scaling = 1.0;
                    photosetModel.append(currentPhoto);
                }

                doJustifyFlow();
            }
        });
    }

    onWidthChanged: doJustifyFlow();

    function doJustifyFlow() {
        // recompute the preferred scaling of each photo
        var idx_endLine = 0, idx_startLine = 0;
        var maxWidth = photosetGridPage.width;
        var wantedHeight = 320;
        var currentWidth=0;
        for(idx_endLine=0; idx_endLine<photosetModel.count; idx_endLine++) {
            var currentPhoto = photosetModel.get(idx_endLine);
            var currentHeightScaling = wantedHeight / currentPhoto.height_s;
            currentWidth += photosetGridPage.spacing*2 + currentPhoto.width_s * currentHeightScaling;
            if( currentWidth > maxWidth ) {
                // now, change the scaling of these photos to make them fit nicely on the line
                var widthScaling = maxWidth/currentWidth;

                // change the scaling
                var j;
                for( j=idx_startLine; j<=idx_endLine; j++ ) {
                    photosetModel.get(j).scaling=widthScaling * (wantedHeight / photosetModel.get(j).height_s);
                }

                // reset counters
                currentWidth = 0;
                idx_startLine = idx_endLine+1;
                wantedHeight = 300 + 40*Math.random(); // a bit at random
            }
        }
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
            spacing: photosetGridPage.spacing

            Repeater {
                model: photosetModel

                delegate:
                    Item {
                        id: photoCell
                        width: photoImage.width
                        height: photoImage.height

                        Image {
                            id: photoImage
                            height: height_s * scaling
                            width: width_s * scaling

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
                                var stackView = photosetGridPage.Stack.view;
                                stackView.navigationPath.push(title);
                                stackView.push({item: Qt.resolvedUrl("PhotoPage.qml"),
                                                properties: {"photoId": id, "photoUrl": url_o, "photoHeight": height_o, "photoWidth": width_o}});
                            }
                        }
                    }
            }
        }
    }
}
