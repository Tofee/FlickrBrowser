import QtQuick 2.0
import QtPositioning 5.2
import "functions.js" as F

Item {
    id: tabMap
    property int buttonSize: 72

    QtObject {
        id: gps
        property bool hasFix: false
        property QtObject lastGoodFix: QtObject {
            property real lat: -27.5
            property real lon: 153.1
            property real bearing: 1.0
            property real error: 1.0
        }
    }

    function showOnMap(lat, lon) {
        pinchmap.setCenterLatLon(lat, lon);
        tabGroup.currentTab = tabMap
    }

    property bool center : true

    Component.onCompleted : {
        pinchmap.setCenterLatLon(gps.lastGoodFix.lat, gps.lastGoodFix.lon);
    }

    PinchMap {
        id: pinchmap
        width: parent.width
        height: parent.height
        zoomLevel: 11

        clip: true

        Connections {
            target: gps
            onLastGoodFixChanged: {
                //console.log("fix changed")
                if (tabMap.center && ! updateTimer.running) {
                    //console.debug("Update from GPS position")
                    pinchmap.setCenterLatLon(gps.lastGoodFix.lat, gps.lastGoodFix.lon);
                    updateTimer.start();
                } else if (tabMap.center) {
                    console.debug("Update timer preventing another update.");
                }
            }
        }

        onDrag : {
            // disable map centering once drag is detected
            tabMap.center = false
        }

        Timer {
            id: updateTimer
            interval: 500
            repeat: false
        }

        /*
        onLatitudeChanged: {
            settings.mapPositionLat = latitude;
        }
        onLongitudeChanged: {
            settings.mapPositionLon = longitude;
        }
        onZoomLevelChanged: {
            settings.mapZoom = pinchmap.zoomLevel;
        }
        */

        // Rotating the map for fun and profit.
        // angle: -compass.azimuth
        showCurrentPosition: true
        currentPositionValid: gps.hasFix
        currentPositionLat: gps.lastGoodFix.lat
        currentPositionLon: gps.lastGoodFix.lon
        //currentPositionAzimuth: compass.azimuth
        //TODO: switching between GPS bearing & compass azimuth
        currentPositionAzimuth: gps.lastGoodFix.bearing
        currentPositionError: gps.lastGoodFix.error

    }
}
