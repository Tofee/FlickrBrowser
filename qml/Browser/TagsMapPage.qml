import QtQuick 2.0
import QtQuick.Controls 1.1

import "../Core"
import "../Singletons"

import "treemap-squarify.js" as Tm

BrowserPage {
    id: tagsPage

    pageModel: tagsListModel
    pageModelType: "Tags"

    ListModel {
        id: fullListTags
    }

    ListModel {
        id: tagsListModel
    }
    ListModel {
        id: treeMapComponents
    }

    property real contentHeight: 2048

    property FlickrReply flickrReplyTagsRaw;
    Connections {
        target: flickrReplyTagsRaw
        onReceived: {
            if(response && response.who && response.who.tags)
            {
                var tagArray = response.who.tags.tag;
                for( var i=0; i<tagArray.length; i++ ) {
                    fullListTags.append({ tag: tagArray[i].raw[0]._content, weight: 1, flickrTag: String(tagArray[i].clean) });
                }

                // Now, query Flickr to retrieve the list of the tags with count of photos
                flickrReplyTagsCount = FlickrBrowserApp.callFlickr("flickr.tags.getListUserPopular", [ [ "count", "-1" ] ]);
            }
        }
    }
    property FlickrReply flickrReplyTagsCount;
    Connections {
        target: flickrReplyTagsCount
        onReceived: {
            if(response && response.who && response.who.tags)
            {
                var tagArray = response.who.tags.tag;
                for( var i=0; i<tagArray.length; i++ ) {
                    var tagItem = fullListTags.get(i);
                    tagItem.weight = parseInt(tagArray[i].count);

                    // As we are looping on all those tags, take the occasion to add the non-artificial
                    // tags to the final list
                    if( tagItem.tag[0] !== '#' ) {
                        tagsListModel.append({ tag: tagItem.tag, weight: tagItem.weight, flickrTag: tagItem.flickrTag });
                    }
                }
            }

            console.log("before refreshMap..." + Date());
            refreshMap();
            console.log("after refreshMap..." + Date());
        }
    }
    Component.onCompleted: {
        if( 1 ) {
            // Query Flickr to retrieve the list of the raw tags
            flickrReplyTagsRaw = FlickrBrowserApp.callFlickr("flickr.tags.getListUserRaw", null);
        }
        else {
            // Do a fake fill of the tags
            console.log("adding test tags");
            var i;
            var nbTags = 202;
            for( i=0; i < nbTags; i++ ) {
                tagsListModel.append({ tag: ("Tag " + i), weight: 1.0 + 50*Math.random() });
            }

            refreshMap();
        }
    }

    function refreshMap() {

        var weightsArray = [];
        var i = 0;
        for( i=0; i < tagsListModel.count; ++i ) {
            weightsArray.push(1+10*Math.log(tagsListModel.get(i).weight));
        }
        var coords = Tm.Treemap.generate(weightsArray, tagsPage.width, contentHeight);
        for(var j in coords) {
            var coord = coords[j];
            var nodeConfig = {
                nodeLeft: coord[0] + 1,
                nodeTop: coord[1] + 1,
                nodeWidth: coord[2] - coord[0] - 1,
                nodeHeight: coord[3] - coord[1] - 1

            };
            treeMapComponents.append(nodeConfig);
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight:contentItem.height
        clip: true
/*
        Flow {
            id: contentItem

            x: 0; y: 0
            width: parent.width

            Repeater {
                model: tagsListModel
                delegate: Text {
                        opacity: 1-0.9/weight
                        color: "white"

                        font.pixelSize: 10+2*Math.log(weight); // try to smoothen the height
                        text: tag
                }
            }
        }
*/

        Item {
            id: contentItem

            height: tagsPage.contentHeight
            width: parent.width

            Repeater {
                model: treeMapComponents
                delegate: Rectangle {
                    x: nodeLeft
                    y: nodeTop
                    width: nodeWidth
                    height: nodeHeight

                    color: mouseArea.containsMouse ? "darkblue" : "black"
                    //border.color: "black"

                    Text {
                        width: Math.max(nodeHeight, nodeWidth)
                        height: Math.min(nodeHeight, nodeWidth)
                        anchors.centerIn: parent
                        rotation: nodeHeight > nodeWidth ? -90 : 0

                        color: "grey"

                        font.pixelSize: height
                        fontSizeMode: Text.Fit
                        wrapMode: Text.Wrap
                        text: tagsListModel.get(index).tag
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }

    }
}
