import QtQuick 2.0
import QtLocation 5.2

MapQuickItem {
    id: carrousselMapItem
    property Map parentMap
    property alias photoList: carroussel.pathModel
    property alias carrousselWidth: carroussel.width
    property alias carrousselHeight: carroussel.height
    anchorPoint: Qt.point(0, 0);

    sourceItem: PathView {
        id: carroussel

        Rectangle {
            z: -100
            opacity: 0.8
            color: "black"
            anchors.fill: parent
        }

        property ListModel pathModel: ListModel {}

        model: pathModel

        path:  Path {
            id: myPath
            startX: 0; startY: carrousselHeight/2-40
            PathAttribute {name: "rotateY"; value: 50.0}
            PathAttribute {name: "scalePic"; value: 0.5}
            PathAttribute {name: "zOrder"; value: 1}

            PathLine{x:carrousselWidth/4+20; relativeY: 0}
            PathPercent {value: 0.44}
            PathAttribute {name: "rotateY"; value: 50.0}
            PathAttribute {name: "scalePic"; value: 0.5}
            PathAttribute {name: "zOrder"; value: 10}

            PathQuad{x:carrousselWidth/2; relativeY: 40; controlX: carrousselWidth/2-30; controlY: carrousselHeight/2}
            PathPercent {value: 0.50}
            PathAttribute {name: "rotateY"; value: 0.0}
            PathAttribute {name: "scalePic"; value: 1.0}
            PathAttribute {name: "zOrder"; value: 50}

            PathQuad{relativeX:carrousselWidth/4-20; relativeY: 0; controlX: carrousselWidth*0.75+50; controlY: carrousselHeight/2-40}
            PathPercent {value: 0.56}
            PathAttribute {name: "rotateY"; value: -50.0}
            PathAttribute {name: "scalePic"; value: 0.5}
            PathAttribute {name: "zOrder"; value: 10}

            PathLine{x:carrousselWidth; relativeY: -40}
            PathPercent {value: 1.00}
            PathAttribute {name: "rotateY"; value: -50.0}
            PathAttribute {name: "scalePic"; value: 0.5}
            PathAttribute {name: "zOrder"; value: 1}
        }
        pathItemCount: 7

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        clip: true

        delegate: Image {
            width: model.width_s
            height: model.height_s
            source: model.url_s

            property real zOrder: PathView.zOrder
            property real scalePic: PathView.scalePic
            property real rotateY: PathView.rotateY

            z: zOrder

            transform:[
                            Rotation{
                                angle: rotateY
                                origin.x: model.width_s/2
                                axis { x: 0; y: 1; z: 0 }
                            },
                            Scale {
                                xScale:scalePic; yScale:scalePic
                                origin.x: model.width_s/2;   origin.y: model.height_s/2
                            }
            ]
        }

        Component.onCompleted: parentMap.gesture.enabled = false;

        MouseArea {
            anchors.fill: parent
            onClicked: {
                parentMap.overlayMapItem = null;
                parentMap.removeMapItem(carrousselMapItem);
            }
        }
    }
}

