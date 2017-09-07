import QtQuick 2.9
import QtQuick.Controls 2.2

import "../Singletons"

// Display the actions for the map view.
Column {
    Button {
        width: parent.width
        text: "Geotag selection"
        onClicked: {
            console.log("Let's do geotagging !");
            geotagSelection();
        }
    }

    function _applyGeoTag(listPhotos, lat, lon) {
        var applyGeoTagArgs = [];
        applyGeoTagArgs.push([ "photo_ids", listPhotos.join(",") ]);
        applyGeoTagArgs.push([ "lat", lat ]);
        applyGeoTagArgs.push([ "lon", lon ]);

        console.log(JSON.stringify(applyGeoTagArgs));

        var flickrReplyApplyGeoTag = FlickrBrowserApp.callFlickr("flickr.photos.geo.setLocation", applyGeoTagArgs);
        if( flickrReplyApplyGeoTag ) {
            flickrReplyApplyGeoTag.received.connect(function(response) {
                if(response && response.stat && response.stat === "ok") {
                    console.log("Photoset geotag applied for "+listPhotos.length+" photos !");
                }
                else {
                    console.log("Error during geotagging of a photo: " + response.message);
                }
            });
        }
    }

    function _applyGeoTagOneByOne(listPhotos, lat, lon) {
        var applyGeoTagArgs;
        for( var iCall=0; iCall<listPhotos.length; ++iCall ) {
            applyGeoTagArgs = [];
            applyGeoTagArgs.push([ "photo_id", listPhotos[iCall] ]);
            applyGeoTagArgs.push([ "lat", lat ]);
            applyGeoTagArgs.push([ "lon", lon ]);

            var flickrReplyApplyGeoTag = FlickrBrowserApp.callFlickr("flickr.photos.geo.setLocation", applyGeoTagArgs);
            if( flickrReplyApplyGeoTag ) {
                flickrReplyApplyGeoTag.received.connect(function(response) {
                    if(response && response.stat && response.stat !== "ok") {
                        console.log("Error during geotagging of a photo: " + response.message);
                    }
                });
            }
        }
    }

    function geotagSelection() {

        for( var iSel = 0; iSel < FlickrBrowserApp.currentSelection.count; ++iSel ) {
            var photoIdsToGeotag = [];

            var selectedItem = FlickrBrowserApp.currentSelection.get(iSel);
            if( selectedItem.type === "collection" ) {
                // Get all the photos of that collection recursively
            }
            else if( selectedItem.type === "set" ) {
                // Get all the photos of that photoset
                var flickrReplyGetPhotoSet = FlickrBrowserApp.callFlickr("flickr.photosets.getPhotos", [ [ "photoset_id", selectedItem.id ] ]);
                if( flickrReplyGetPhotoSet ) {
                    flickrReplyGetPhotoSet.received.connect(function(response) {
                        if(response && response.photoset && response.photoset.photo)
                        {
                            var i;
                            for( i=0; i<response.photoset.photo.length; i++ ) {
                                photoIdsToGeotag.push(response.photoset.photo[i].id);
                            }

                            if( photoIdsToGeotag.length > 0 && FlickrBrowserApp.currentTargetOnMap ) {
                                _applyGeoTagOneByOne(photoIdsToGeotag, String(FlickrBrowserApp.currentTargetOnMap.latitude), String(FlickrBrowserApp.currentTargetOnMap.longitude));
                            }
                        }
                    });
                }
            }
            else if( selectedItem.type === "photo" ) {
                // Geotag only that photo
                photoIdsToGeotag.push(selectedItem.id);
                if( photoIdsToGeotag.length > 0 && FlickrBrowserApp.currentTargetOnMap ) {
                    _applyGeoTagOneByOne(photoIdsToGeotag, String(FlickrBrowserApp.currentTargetOnMap.latitude), String(FlickrBrowserApp.currentTargetOnMap.longitude));
                }
            }
        }
    }
}
