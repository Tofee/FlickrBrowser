import QtQuick 2.0
import QtPositioning 5.2
import QtLocation 5.3

import "../Singletons"
import "../Core"

Item {
    id: tabMap
    property int buttonSize: 72

    property ListModel photosOnMap: ListModel {}
    property ListModel pinsOnMap: ListModel {}

    function refreshModel() {
        // Query Flickr to retrieve the list of the photos
        var searchParams = [];
        var bbox = map.getLonLatBBox();
        searchParams.push( [ "bbox", bbox.toString() ] );
        searchParams.push( [ "user_id", "me" ] ); // only search our photos
        searchParams.push( [ "extras", "geo, url_s, url_o" ] );
        flickrReply = FlickrBrowserApp.callFlickr("flickr.photos.search", searchParams);
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.photos && response.photos.photo)
            {
                photosOnMap.clear();
                pinsOnMap.clear();

                var radiusMarker = map.toCoordinate(Qt.point(0,0)).distanceTo(map.toCoordinate(Qt.point(32,32)));

                var i, j;
                for( i=0; i<response.photos.photo.length; i++ ) {
                    var currentPhoto = response.photos.photo[i];
                    photosOnMap.append(currentPhoto);

                    var isAlreadyContained = false;
                    var currentPhotoCoords = QtPositioning.coordinate(currentPhoto.latitude, currentPhoto.longitude);
                    for( j=0; j<pinsOnMap.count && !isAlreadyContained; j++ ) {
                        var currentPin = pinsOnMap.get(j);
                        if( QtPositioning.circle(QtPositioning.coordinate(currentPin.latitude, currentPin.longitude), radiusMarker).contains(currentPhotoCoords) ) {
                            currentPin.containedPhotos.append({"index": i});
                            isAlreadyContained = true;
                        }
                    }

                    if( !isAlreadyContained ) {
                        pinsOnMap.append( { "latitude": currentPhoto.latitude, "longitude": currentPhoto.longitude, "containedPhotos": [ {"index": i} ] } );
                    }
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

        property variant overlayMapItem
        onOverlayMapItemChanged: if( !map.overlayMapItem ) map.gesture.enabled = true;

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(map.overlayMapItem) {
                    map.removeMapItem(map.overlayMapItem);
                    map.overlayMapItem = null;
                }
                else {
                    // add a temporary pin for geotagging the selection
                    var componentMapGeotaggerMarker = Qt.createComponent("MapGeotaggerMarker.qml");
                    if (componentMapGeotaggerMarker.status === Component.Ready) {
                        var mapGeotaggerMarker = componentMapGeotaggerMarker.createObject(map,
                                                                                    {parentMap: map,
                                                                                      coordinate: map.toCoordinate(Qt.point(mouse.x,mouse.y)) });
                        map.addMapItem(mapGeotaggerMarker);

                        map.overlayMapItem = mapGeotaggerMarker;
                    }
                }
            }
        }

        MapItemView {
            model: pinsOnMap
            delegate: MapQuickItem {
                id: mapPinItem
                coordinate: QtPositioning.coordinate(model.latitude, model.longitude);
                anchorPoint: mapMarkerImage.anchorPoint
                sourceItem: MapMarker {
                    id: mapMarkerImage
                    nbPhotos: model.containedPhotos.count

                    onShowRelatedPhotos: {
                        if(map.overlayMapItem) {
                            map.removeMapItem(map.overlayMapItem);
                            map.overlayMapItem = null;
                        }
                        if( mapMarkerImage.nbPhotos > 1 ) {
                            var componentMapCarrousselMarker = Qt.createComponent("MapCarrousselMarker.qml");
                            if (componentMapCarrousselMarker.status === Component.Ready) {
                                var mapCarrousselMarker = componentMapCarrousselMarker.createObject(map,
                                                                                            {parentMap: map,
                                                                                              coordinate: mapPinItem.coordinate,
                                                                                              carrousselWidth: map.width/2, carrousselHeight: 200});
                                for( var i=0; i<mapMarkerImage.nbPhotos; ++i ) {
                                    mapCarrousselMarker.photoList.append( photosOnMap.get(model.containedPhotos.get(i).index) );
                                }
                                map.addMapItem(mapCarrousselMarker);

                                map.overlayMapItem = mapCarrousselMarker;
                            }
                        }
                        else if( mapMarkerImage.nbPhotos === 1 ) {
                            var photoToShow = photosOnMap.get(model.containedPhotos.get(0).index);
                            var componentMapImageMarker = Qt.createComponent("MapImageMarker.qml");
                            if (componentMapImageMarker.status === Component.Ready) {
                                var mapImageMarker = componentMapImageMarker.createObject(map,
                                                                                            {parentMap: map,
                                                                                              coordinate: mapPinItem.coordinate,
                                                                                              sourceImage: photoToShow.url_s, imageWidth: photoToShow.width_s, imageHeight: photoToShow.height_s});
                                map.addMapItem(mapImageMarker);

                                map.overlayMapItem = mapCarrousselMarker;
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: refreshModelTimer
            interval: 500; repeat: false; running: false
            onTriggered: refreshModel();
        }
        Connections {
            target: map.gesture
            onFlickFinished: refreshModelTimer.restart();
            onPanFinished: refreshModelTimer.restart();
        }
        onZoomLevelChanged: refreshModelTimer.restart();

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
