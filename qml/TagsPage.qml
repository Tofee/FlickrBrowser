import QtQuick 2.0
import QtQuick.Controls 1.1

import "FlickrAPI.js" as FlickrAPI

Item {
    id: photoPage

    property alias tags: tagCanvas.tags

    Component.onCompleted: {
        // Query Flickr to retrieve the list of the photos
        if( 1 ) {
            FlickrAPI.callFlickrMethod("flickr.tags.getListUserRaw", null, function(response) {
                if(response && response.who && response.who.tags)
                {
                    var i;
                    var pts = tagCanvas.pointsOnSphere(response.who.tags.tag.length,tagCanvas.sphereRadius,tagCanvas.sphereRadius,tagCanvas.sphereRadius);
                    if( response.who.tags.tag.length !== pts.length ) return;

                    for( i=0; i<response.who.tags.tag.length; i++ ) {
                        var tagRawText = response.who.tags.tag[i].raw[0]._content;
                        if( tagRawText[0] !== '#' ) {
                            tags.append({ tag: tagRawText, pos: { x: pts[i][0], y: pts[i][1], z:  pts[i][2] } });
                        }
                    }

                    tagCanvas.requestPaint();
                }
            });
        }
        else {
            console.log("adding test tags");
            var i;
            var nbTags = 202;
            var pts = tagCanvas.pointsOnSphere(nbTags,tagCanvas.sphereRadius,tagCanvas.sphereRadius,tagCanvas.sphereRadius);
            for( i=0; i < pts.length; i++ ) {
                tags.append({ tag: ("Tag " + i), pos: { x: pts[i][0], y: pts[i][1], z:  pts[i][2] } });
            }

            tagCanvas.requestPaint();
        }
    }

    TagCanvas {
        id: tagCanvas
        width: parent.width
        height: parent.height
    }
}
