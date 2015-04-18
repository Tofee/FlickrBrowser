import QtQuick 2.0
import QtPositioning 5.2
import QtLocation 5.3
import "functions.js" as F

import "../Singletons"
import "../Core"

Item {
    id: tabMap
    property int buttonSize: 72

    property ListModel photosOnMap: ListModel {}

    function refreshModel() {
        // Query Flickr to retrieve the list of the photos
        var searchParams = [];
        var bbox = map.getLonLatBBox();
        searchParams.push( [ "bbox", bbox.toString() ] );
        searchParams.push( [ "user_id", "me" ] ); // only search our photos
        searchParams.push( [ "extras", "geo" ] );
        flickrReply = FlickrBrowserApp.callFlickr("flickr.photos.search", searchParams);
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.photos && response.photos.photo)
            {
                photosOnMap.clear();

                var i;
                for( i=0; i<response.photos.photo.length; i++ ) {
                    photosOnMap.append(response.photos.photo[i]);
                }
            }
        }
    }

    function showOnMap(lat, lon) {
        pinchmap.setCenterLatLon(lat, lon);
        tabGroup.currentTab = tabMap
    }

    property bool center : true

    Plugin {
        id: myPlugin
        name: "osm"
        //specify plugin parameters if necessary
        //PluginParameter {...}
        //PluginParameter {...}
        //...
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: myPlugin;
        center: QtPositioning.coordinate(48.875949, 2.382140);
        zoomLevel: 13

        MapItemView {
            model: photosOnMap
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(model.latitude, model.longitude);

                anchorPoint.x: image.width * 0.5
                anchorPoint.y: image.height

                sourceItem: Image {
                    id: image
                    source: Qt.resolvedUrl("../images/marker.png");
                }
            }
        }

        Connections {
            target: map.gesture
            onFlickFinished: refreshModel();
            onPanFinished: refreshModel();
        }

        function getLonLatBBox() {
            var start = map.toCoordinate(Qt.point(0,0));
            var end = map.toCoordinate(Qt.point(map.width,map.height));
            return [ Math.min(start.longitude, end.longitude),
                     Math.min(start.latitude, end.latitude),
                     Math.max(start.longitude, end.longitude),
                     Math.max(start.latitude, end.latitude) ];
        }
    }
}
