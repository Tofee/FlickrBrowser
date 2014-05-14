import QtQuick 2.0
import "OAuthCore.js" as OAuth
import "DBAccess.js" as DBAccess

Item {
    id: root

    width: 360
    height: 360

    QtObject {
        id: sessionProperties

        property variant credentials;
    }

    OAuthDialog {
        id: flickrOAuthDialog

        anchors.fill: parent;
        visible: true
        onAuthorised: {
            root.state = "Authorized";
            sessionProperties.credentials = credentials;
            var response = callFlickrMethod("flickr.photosets.getList", null, cb);
        }

        function cb(response) {
            console.log(response);
        }
    }

    states: [
        State {
            name: "Login"
        },
        State {
            name: "Authorized"

            PropertyChanges {
                target: flickrOAuthDialog
                visible: false
            }
        }
    ]

    function callFlickrMethod(method, args, callback) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if( callback )
                    callback(JSON.parse(doc.responseText));
            }
        }
        var parameters = new Array();
        parameters.push( ["nojsoncallback", 1] );
        parameters.push( ["format", "json"] );
        parameters.push( ["method", method] );
        if( args )
            parameters.concat(args);
        var oauthData = OAuth.createOAuthHeader("flickr", "GET", "https://api.flickr.com/services/rest/", sessionProperties.credentials, null, parameters);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }

    Component.onCompleted: {
        state: "Login";
    }
}

