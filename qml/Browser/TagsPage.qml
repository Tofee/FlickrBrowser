import QtQuick 2.0

import "../Core"
import "../Singletons"

BrowserPage {
    id: tagsPage

    pageModel: tagsListModel
    pageModelType: "Tags"

    ListModel {
        id: tagsListModel
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.who && response.who.tags)
            {
                var i;
                var pts = tagCanvas.pointsOnSphere(response.who.tags.tag.length,tagCanvas.sphereRadius,tagCanvas.sphereRadius,tagCanvas.sphereRadius);
                if( response.who.tags.tag.length !== pts.length ) return;

                for( i=0; i<response.who.tags.tag.length; i++ ) {
                    var tagRawText = response.who.tags.tag[i].raw[0]._content;
                    if( tagRawText[0] !== '#' ) {
                        tagsListModel.append({ tag: tagRawText, pos: { x: pts[i][0], y: pts[i][1], z:  pts[i][2] } });
                    }
                }

                tagCanvas.requestPaint();
            }
        }
    }
    Component.onCompleted: {
        if( 1 ) {
            // Query Flickr to retrieve the list of the photos
            flickrReply = FlickrBrowserApp.callFlickr("flickr.tags.getListUserRaw", null);
        }
        else {
            // Do a fake fill of the tags
            console.log("adding test tags");
            var i;
            var nbTags = 202;
            var pts = tagCanvas.pointsOnSphere(nbTags,tagCanvas.sphereRadius,tagCanvas.sphereRadius,tagCanvas.sphereRadius);
            for( i=0; i < pts.length; i++ ) {
                tagsListModel.append({ tag: ("Tag " + i), pos: { x: pts[i][0], y: pts[i][1], z:  pts[i][2] } });
            }

            tagCanvas.requestPaint();
        }
    }

    TagCanvas {
        id: tagCanvas
        width: parent.width
        height: parent.height

        tags: tagsListModel
    }
}
