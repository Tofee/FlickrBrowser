import QtQuick 2.0
import QtQuick.Controls 1.1

import "../Core"
import "../Singletons"

BrowserPage {
    id: photoPage

    pageModelType: "Photo"

    property url photoUrl: "";
    property real photoHeight: 100;
    property real photoWidth: 100;

    // this is the list of photos to navigate into.
    // it could be the content of an album, the result of a search, photos associated to a tag...
    property variant photosList: [ pageItemId ];

    onPageItemIdChanged: {
        refreshModel();
    }
    onRemoteModelChanged: refreshModel();
    Component.onCompleted: refreshModel();
    function refreshModel() {
        // Query Flickr to update the informations on the photo
        flickrReply = FlickrBrowserApp.callFlickr("flickr.photos.getSizes", [ [ "photo_id", pageItemId ] ]);
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.sizes && response.sizes.size )
            {
                var sizeArray = response.sizes.size;
                for( var i = sizeArray.length-1; i >= 0; --i ) { // "Original" is very likely to be the last item in the array
                    if( sizeArray[i].label === "Original" ) {
                        photoUrl = sizeArray[i].source;
                        photoHeight = sizeArray[i].height;
                        photoWidth = sizeArray[i].width;
                        break;
                    }
                }
            }
            fitToArea();
        }
    }

    property int _indexInPhotosList: photosList.indexOf(pageItemId)

    BusyIndicator {
        anchors.centerIn: parent; running: originalImage.status != Image.Ready
    }
    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: photoWidth
        contentHeight:photoHeight
        clip: true

        Image {
            id: originalImage; antialiasing: true;
            visible: status == Image.Ready
            source: photoUrl; cache: false; asynchronous: true
            sourceSize.height: photoHeight
            sourceSize.width: photoWidth
            width: flick.contentWidth
            height:flick.contentHeight
            fillMode: Image.PreserveAspectFit
        }

        PinchArea {
            id:pinchy
            width: Math.max(flick.contentWidth, flick.width)
            height: Math.max(flick.contentHeight, flick.height)
            enabled: true

            function distance(p1, p2) {
                var dx = p2.x-p1.x;
                var dy = p2.y-p1.y;
                return Math.sqrt(dx*dx + dy*dy);
            }

            property real initialDistance
            property real initialContentWidth
            property real initialContentHight

            onPinchStarted: {
                initialDistance = distance(pinch.point1, pinch.point2);
                initialContentWidth = flick.contentWidth;
                initialContentHight = flick.contentHeight;
            }

            onPinchUpdated: {
                // adjust content pos due to drag
                flick.contentX += pinch.previousCenter.x - pinch.center.x
                flick.contentY += pinch.previousCenter.y - pinch.center.y

                // resize content
                var currentDistance = distance(pinch.point1, pinch.point2);
                var scale = currentDistance/initialDistance;
                flick.resizeContent(initialContentWidth*scale, initialContentHight*scale, pinch.center)
                if (pinch.pointCount >= 2) {
                    currentDistance = distance(pinch.point1, pinch.point2);
                    scale = currentDistance/initialDistance;
                    flick.resizeContent(initialContentWidth*scale, initialContentHight*scale, pinch.center)

                }
            }

            onPinchFinished: {
                flick.returnToBounds();
            }// Move its content within bounds.
        }
        MouseArea {
            anchors.fill: parent
            onWheel: {
                var scale = 1 + (wheel.angleDelta.y / 800.);
                var center = Qt.point(wheel.x, wheel.y);
                flick.resizeContent(flick.contentWidth*scale, flick.contentHeight*scale, center);

                if( flick.contentWidth < flick.width ||
                    flick.contentHeight < flick.height )
                    fitToArea();
            }

            onDoubleClicked: fitToArea();
        }
    }
    // add an overlay over the flickable image, for the navigation between images
    Item {
        anchors.fill: flick

        Image {
            visible: _indexInPhotosList>0
            opacity: prevMouseArea.containsMouse ? 1.0 : 0.1
            source: Qt.resolvedUrl("../images/photo-prev-icon.png");

            Behavior on opacity { NumberAnimation { duration: 100 } }

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 71

            fillMode: Image.PreserveAspectFit

            MouseArea {
                id: prevMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: pageItemId = photosList[_indexInPhotosList-1];
            }
        }
        Image {
            visible: _indexInPhotosList<photosList.length-1
            opacity: nextMouseArea.containsMouse ? 1.0 : 0.1
            source: Qt.resolvedUrl("../images/photo-next-icon.png");

            Behavior on opacity { NumberAnimation { duration: 100 } }

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 71

            fillMode: Image.PreserveAspectFit

            MouseArea {
                id: nextMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: pageItemId = photosList[_indexInPhotosList+1];
            }
        }
    }

    function fitToArea() {
        var center = Qt.point(flick.contentX + flick.width/2, flick.contentY + flick.height/2);
        flick.resizeContent(flick.width, flick.height, center);
        flick.returnToBounds();
    }
}
