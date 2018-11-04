import QtQuick 2.9
import QtQuick.Controls 2.2

import org.flickrbrowser.services 1.0

import "../Singletons"
import "../Core"

// Display the actions for the root browser view.
Column {
    Button {
        width: parent.width
        text: "Get all coordinates"
        onClicked: {
            aggregatedAnwser = new Array;
            getAllCoordinates(1);
        }
    }

    Button {
        width: parent.width
        text: "Logout"
        onClicked: FlickrBrowserApp.logout();
    }

    property FlickrReply flickrReply;
    property var aggregatedAnwser;

    function getAllCoordinates(pageNum) {
        // Query Flickr to retrieve the list of the photos
        console.log("Retrieving page " + pageNum + " ...");
        var searchParams = [];
        searchParams.push( [ "user_id", "me" ] ); // only search our photos
        searchParams.push( [ "extras", "geo, tags" ] );
        searchParams.push( [ "media", "all" ] );
        searchParams.push( [ "content_type", "7" ] );
        searchParams.push( [ "perpage", "250" ] );
        searchParams.push( [ "page", pageNum ] );
        flickrReply = FlickrBrowserApp.callFlickr("flickr.photos.getWithGeodata", searchParams);
    }
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.photos && response.photos.photo)
            {
                var i;
                for( i=0; i<response.photos.photo.length; ++i) {
                    aggregatedAnwser.push(response.photos.photo[i]);
                }
                if(response.photos.page < response.photos.pages) {
                    // go to next page
                    getAllCoordinates(response.photos.page+1);
                }
                else
                {
                    FlickrServices.writeToFile("/home/chris/BackupStrategy/Flickr/GeoLocations.json", JSON.stringify(aggregatedAnwser));
                }
            }
        }
    }
}
