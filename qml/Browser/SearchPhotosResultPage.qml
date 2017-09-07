import QtQuick 2.0

import "../Core"
import "../Singletons"
import "../Utils" as Utils

BrowserPage {
    id: searchPhotosResultGridPage

    pageModel: searchPhotosResultModel
    pageModelType: "SearchPhotosResult"
    modelForSelection: flowList.model

    property variant searchParams;

    property real spacing : 5;

    ListModel {
        id: searchPhotosResultModel;

        // taken from Utils/SortedListModel.qml
        function getValuesForProperty(prop) {
            var ret = [];
            for( var i=0; i<searchPhotosResultModel.count; i++ ) {
                var obj = searchPhotosResultModel.get(i);
                ret.push(obj[prop]);
            }

            return ret;
        }
    }

    onRemoteModelChanged: refreshModel();
    Component.onCompleted: refreshModel();
    function refreshModel() {
        // Query Flickr to retrieve the list of the photos
        flickrReply = FlickrBrowserApp.callFlickr("flickr.photos.search", searchParams);
    }

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.photos && response.photos.photo)
            {
                var i;
                for( i=0; i<response.photos.photo.length; i++ ) {
                    var currentPhoto = response.photos.photo[i];
                    currentPhoto.scaling = 1.0;
                    searchPhotosResultModel.append(currentPhoto);
                }

                doJustifyFlow();
            }
        }
    }

    onWidthChanged: doJustifyFlow();

    function doJustifyFlow() {
        // recompute the preferred scaling of each photo
        var idx_endLine = 0, idx_startLine = 0;
        var maxWidth = searchPhotosResultGridPage.width;
        var wantedHeight = 320;
        var currentWidth=0;
        for(idx_endLine=0; idx_endLine<searchPhotosResultModel.count; idx_endLine++) {
            var currentPhoto = searchPhotosResultModel.get(idx_endLine);
            var currentHeightScaling = wantedHeight / currentPhoto.height_s;
            currentWidth += searchPhotosResultGridPage.spacing*2 + currentPhoto.width_s * currentHeightScaling;
            if( currentWidth > maxWidth ) {
                // now, change the scaling of these photos to make them fit nicely on the line
                var widthScaling = maxWidth/currentWidth;

                // change the scaling
                var j;
                for( j=idx_startLine; j<=idx_endLine; j++ ) {
                    searchPhotosResultModel.get(j).scaling=widthScaling * (wantedHeight / searchPhotosResultModel.get(j).height_s);
                }

                // reset counters
                currentWidth = 0;
                idx_startLine = idx_endLine+1;
                wantedHeight = 300 + 40*Math.random(); // a bit at random
            }
        }
    }

    Utils.FlowList {
        anchors.fill: parent
        id: flowList

        itemType: "photo"
        spacing: searchPhotosResultGridPage.spacing

        model: searchPhotosResultModel
        delegate:
            Utils.FlowListDelegate {
                id: delegateItem

                imageSource: url_s
                textContent: title;

                imageHeight: height_s * scaling
                imageWidth: width_s * scaling
                imageFillMode: Image.PreserveAspectFit
                textPixelSize: 14

                // little trick here to make it re-evaluate the property each time the selection changes
                isSelected: { FlickrBrowserApp.currentSelection.selectedIndexes; return FlickrBrowserApp.currentSelection.isSelected(modelForSelection.index(index,0)) }

                showText: false
                hoverEnabled: true

                Item {
                    // show title at the bottom of the image, on mouse over
                    anchors.left: delegateItem.left
                    anchors.right: delegateItem.right
                    anchors.bottom: delegateItem.bottom
                    height: photoTitle.height * 1.1

                    opacity:delegateItem.containsMouse ? 1.0: 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.8
                    }
                    Text {
                        id: photoTitle
                        anchors.left: parent.left
                        anchors.right: parent.right

                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap

                        text: delegateItem.textContent
                    }
                }

                onClicked: {
                    flowList.selected(index, mouse.modifiers);
                }

                onDoubleClicked: {
                    // show full screen photo
                    searchPhotosResultGridPage.pushNewPage(Qt.resolvedUrl("PhotoPage.qml"), delegateItem.textContent,
                                                           {"pageItemId": id, "photosList": searchPhotosResultModel.getValuesForProperty("id")});

                    FlickrBrowserApp.currentSelection.clear();
                    FlickrBrowserApp.currentSelection.addToSelection({ "type": "photo", "id": id, "object": searchPhotosResultModel.get(index) });
                }
            }
    }
}
