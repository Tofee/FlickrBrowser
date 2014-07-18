import QtQuick 2.0
import QtQuick.Controls 1.1
import QtWebKit 3.0
import "OAuthCore.js" as OAuth
import "DBAccess.js" as DBAccess

import "../Singletons"

Item {
    id: dialog

    property string title : qsTr("Authorisation For Flickr")

    Component.onCompleted: {
        DBAccess.checkToken(function (tmp) {
            if( tmp && tmp.token ) {
                console.log("Token already existing. Checking token...");
                checkFlickrToken(tmp.token);
            }
            else {
                console.log("No token found. Requesting new token.");
                dialog.state = "signout";
            }
        });
    }

    signal authorised

    state: "checkToken"

    states: [
        State {
            name: "checkToken"
        },
        State {
            name: "signout"
            StateChangeScript {
                script: {
                    webViewSignout.url = "https://www.flickr.com/logout.gne";
                }
            }
        },
        State {
            name: "needNewToken"
            StateChangeScript {
                script: {
                    getFlickrRequestToken();
                }
            }
        },
        State {
            name: "authorized"
            StateChangeScript {
                script: {
                    dialog.authorised();
                }
            }
        }
    ]

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        color: "white"
        text: title
    }

    BusyIndicator {
        anchors.centerIn: parent;
        running: dialog.state !== "needNewToken" && dialog.state !== "signout"
    }
    Flickable {
        id: webFlicker

        visible: (dialog.state === "needNewToken" || dialog.state === "signout")

        anchors { fill: parent; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: 10 }
        contentWidth: 800
        contentHeight: 1280
        boundsBehavior: Flickable.DragOverBounds
        clip: true

        WebView {
            id: webViewSignin

            width: 800
            height: 1280

            visible: dialog.state === "needNewToken"
            opacity:(webViewSignin.progress < 1) ? 0 : 1
            onUrlChanged: {
                console.log(webViewSignin.url.toString());
                checkUrlForToken();
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }
        WebView {
            id: webViewSignout

            width: 800
            height: 1280

            visible: dialog.state === "signout"

            opacity:(webViewSignout.progress < 1) ? 0 : 1
            onUrlChanged: {
                console.log(webViewSignout.url.toString());
                dialog.state = "needNewToken";
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }
    }

    /* private section */

    property string _flickrRequestToken
    property string _flickrRequestSecret

    function checkUrlForToken() {
        var url = webViewSignin.url.toString();
        if (/oauth_verifier=/.test(url)) {
            var flickrVerifier = url.split("=")[2].split("&")[0];
            getFlickrAccessToken(flickrVerifier); // authorization agreement detected, exchange the request token against an access token
        }
        else if (/error/.test(url)) {
            messages.displayMessage(qsTr("Error obtaining flickr authorisation"));
        }
    }

    function checkFlickrTokenReply(response) {
        if( response.stat && response.stat === "ok" ) {
            console.log("Token valid.");
            dialog.state = "authorized";
        }
        else {
            console.log("Token not valid. Requesting new token.");
            dialog.state = "needNewToken";
        }
    }
    function checkFlickrToken(token) {
        var flickrReply = FlickrBrowserApp.callFlickr("flickr.auth.oauth.checkToken", null);
        if(flickrReply) {
            flickrReply.received.connect(checkFlickrTokenReply);
        }
    }

    function getFlickrRequestToken() {
        //busyDialog.show = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                var response = doc.responseText;
                if (/oauth_token/i.test(response)) {
                    console.log(response);
                    var tSplit = response.split('&');
                    _flickrRequestToken = tSplit[1].split('=')[1];
                    _flickrRequestSecret = tSplit[2].split('=')[1];
                    // go to the authorization page
                    webViewSignin.url = "https://www.flickr.com/services/oauth/authorize?perms=write&oauth_token=" + _flickrRequestToken;
                }
                else {
                    console.error(qsTr("Unable to obtain flickr request token"));
                    Qt.quit();

                }
                //busyDialog.show = false;
            }
        }
        var credentials = { "callback": "http://localhost" };
        var oauthData = OAuth.createOAuthHeader("flickr", "GET", "https://www.flickr.com/services/oauth/request_token", credentials);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }

    function getFlickrAccessToken(verifier) {
        //busyDialog.show = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                var response = doc.responseText;
                if (/oauth_token/i.test(response)) {
                    var tSplit = response.split('&');
                    var token = tSplit[1].split('=')[1];
                    var secret = tSplit[2].split('=')[1];
                    DBAccess.saveToken(token, secret);
                    dialog.state = "authorized";
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain flickr access token"));
                    Qt.quit();
                }
                //busyDialog.show = false;
            }
        }
        var credentials = { "token": _flickrRequestToken, "secret": _flickrRequestSecret, "verifier": verifier };
        var oauthData = OAuth.createOAuthHeader("flickr", "GET", "https://www.flickr.com/services/oauth/access_token", credentials);
        doc.open("GET", oauthData.url);
        doc.setRequestHeader("Authorization", oauthData.header);
        doc.send();
    }
}
