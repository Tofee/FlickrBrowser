import QtQuick 2.0
import QtQuick.Controls 1.1

import "../Core"
import "../Singletons"

BrowserPage {
    id: photoPage

    pageModelType: "Photo"

    property string photoUrl;
    property real photoHeight;
    property real photoWidth;

    property variant photoDetails;

    onRemoteModelChanged: refreshModel();
    Component.onCompleted: refreshModel();
    function refreshModel() {
        // Query Flickr to retrieve the list of the photos
        flickrReply = FlickrBrowserApp.callFlickr("flickr.photos.getInfo", [ [ "photo_id", pageItemId ] ]);
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response)
                photoDetails = response.photo;
            fitToArea();
        }
    }

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

    function fitToArea() {
        var center = Qt.point(flick.contentX + flick.width/2, flick.contentY + flick.height/2);
        flick.resizeContent(flick.width, flick.height, center);
        flick.returnToBounds();
    }
}
