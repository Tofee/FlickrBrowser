import QtQuick 2.0

import "TagCanvasCache.js" as Cache

Canvas {
    id: canvas
    property real sphereRadius: 1;
    property real longitude: 0
    property real latitude: 0
    property real zoom: 1

    onLatitudeChanged: requestPaint();
    onLongitudeChanged: requestPaint();

    Behavior on longitude { NumberAnimation { duration: 1000 } }
    Behavior on latitude  { NumberAnimation { duration: 1000 } }

    property ListModel tags: ListModel {}

    function initializeCache(listTagImages) {
        var ctx = canvas.getContext('2d');

        ctx.reset();
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.font = '20px sans-serif';

        var txtRealHeight = 24;

        var transparentBlackColor = Qt.rgba(0,0.2,0,0.1);

        // these two gradient do not depend on the text's width, so let's build them once for all
        var gradTop = ctx.createLinearGradient(0,0,0,txtRealHeight/4); // top side
        gradTop.addColorStop(0, transparentBlackColor);
        gradTop.addColorStop(1, 'black');
        var gradBottom = ctx.createLinearGradient(0,3*txtRealHeight/4,0,txtRealHeight); // bottom side
        gradBottom.addColorStop(0, 'black');
        gradBottom.addColorStop(1, transparentBlackColor);

        // for each tag, write it on the canvas and take a screenshot
        var i;
        for( i = 0; i < tags.count; i++ ) {
            // Measure what width the text will be
            var textRect = ctx.measureText(tags.get(i).tag);

            // Create a background rectangle, black with a gradiant for the alpha component

            // fill in the center of the background with solid black
            ctx.fillStyle = 'black'
            ctx.fillRect(textRect.width/5,txtRealHeight/4,3*textRect.width/5,2*txtRealHeight/4);

            // draw the contour of the background
            var gradLeft = ctx.createLinearGradient(0,0,textRect.width/5,0); // left side
            gradLeft.addColorStop(0, transparentBlackColor);
            gradLeft.addColorStop(1, 'black');
            var gradRight = ctx.createLinearGradient(4*textRect.width/5,0,textRect.width,0); // right side
            gradRight.addColorStop(0, 'black');
            gradRight.addColorStop(1, transparentBlackColor);

            ctx.fillStyle = gradLeft
            ctx.fillRect(0,                  0,                 textRect.width/5,   txtRealHeight);
            ctx.fillStyle = gradRight
            ctx.fillRect(4*textRect.width/5, 0,                 textRect.width/5,   txtRealHeight);
            ctx.fillStyle = gradTop
            ctx.fillRect(textRect.width/5,   0,                 3*textRect.width/5, txtRealHeight/4);
            ctx.fillStyle = gradBottom
            ctx.fillRect(textRect.width/5,   3*txtRealHeight/4, 3*textRect.width/5, txtRealHeight/4);

            // Now write the text on top of that
            ctx.fillStyle = 'blue';
            ctx.fillText(tags.get(i).tag, 0, 20);
            var canvasImageData = ctx.getImageData(0, 0, textRect.width, txtRealHeight);
            listTagImages.push(canvasImageData);
            ctx.clearRect(0, 0, textRect.width, txtRealHeight);
        }
    }

    onPaint: {
        // Problem perfo if we use fillText: so cache the result of fillText as images...
        if( !Cache.listTagImages || Cache.listTagImages.length < tags.count ) {
            Cache.listTagImages = new Array();
            initializeCache(Cache.listTagImages);
        }

        var ctx = canvas.getContext('2d');

        ctx.reset();
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = 'blue';

        var i;
        for( i = 0; i < tags.count; i++ ) {
            // Project the point onto the canvas
            var pos = tags.get(i).pos;
            var rotatedPos = rotateVector(Qt.vector3d(pos.x,pos.y,pos.z), longitude, latitude);
            var pos2d = rotatedPos.crossProduct(Qt.vector3d(0,0,1)).toVector2d();

            var cachedTagImageData = Cache.listTagImages[i];
            if( cachedTagImageData ) {
                var scaling = 0.7+0.3*(rotatedPos.z/sphereRadius);  // scale between 0.4 and 1
                ctx.globalAlpha = 0.6+0.4*(rotatedPos.z/sphereRadius);  // alpha between 0.2 and 1

                var imgWidth = cachedTagImageData.width*scaling;
                var imgHeight = cachedTagImageData.height*scaling;

                ctx.drawImage(cachedTagImageData,
                              canvas.width*0.5*(sphereRadius+pos2d.x*zoom)-imgWidth/2,
                              canvas.height*0.5*(sphereRadius+pos2d.y*zoom)-imgHeight/2,
                              imgWidth, imgHeight);
            }
        }
    }

    // Rotate v (vector3d) when current longitude and latitude are lg and lt
    function rotateVector(v, lg, lt) {

        /*
          φ = latitude, ϑ = longitude
            x   ( cos(φ), sin(φ), 0) (  cos(ϑ), 0, sin(ϑ)) (x')
            y = (-sin(φ), cos(φ), 0).(  0     , 1, 0     ).(y')
            z   ( 0     , 0     , 1) ( -sin(ϑ), 0, cos(ϑ)) (z')
          */

        return Qt.vector3d(
            Math.cos(lt)*Math.cos(lg)*v.x + Math.sin(lg)*v.y + Math.sin(lt)*Math.cos(lg)*v.z,
           -Math.cos(lt)*Math.sin(lg)*v.x + Math.cos(lg)*v.y - Math.sin(lt)*Math.sin(lg)*v.z,
           -Math.sin(lt)*v.x              +                    Math.cos(lt)*v.z
                    );
    }

    // Returns an array of n points [x,y,z] located on a sphere of radiuses xr,yr,zr
    function pointsOnSphere(n,xr,yr,zr) {
        if(n===0) return [];

        var i, y, r, phi, pts = [], inc = Math.PI * (3-Math.sqrt(5)), off = 2/n;
        for(i = 0; i < n; ++i) {
            y = i * off - 1 + (off / 2);
            r = Math.sqrt(1 - y*y);
            phi = i * inc;
            pts.push( [ Math.cos(phi) * r * xr, y * yr, Math.sin(phi) * r * zr ] );
        }
        return pts;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: {
            var scale = 1 + (wheel.angleDelta.y / 800.);
            zoom *= scale;
            requestPaint();
        }
        onPositionChanged: {
            if( mouse.x < canvas.width*0.2 ) {
                longitude -= 0.1;
            }
            else if( mouse.x > canvas.width*0.8 ) {
                longitude -= 0.1;
            }
            if( mouse.y < canvas.height*0.2 ) {
                latitude -= 0.1;
            }
            else if( mouse.y > canvas.height*0.8 ) {
                latitude -= 0.1;
            }
        }
    }
}
