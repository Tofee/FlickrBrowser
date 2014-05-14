import QtQuick 2.0
import QtWebKit 3.0
import "OAuthCore.js" as OAuth
import "DBAccess.js" as DBAccess

Item {
    id: dialog

    property string title : qsTr("Authorisation For Flickr")

    Component.onCompleted: {
        var tmp = DBAccess.checkToken();
        if( tmp && tmp.token && tmp.secret ) {
            console.log("Token already existing.");
            authorised(tmp);
        }
        else {
            getFlickrRequestToken();
        }
    }
    signal authorised(variant credentials)
    signal close

    Text {
        id: titleText

        anchors { horizontalCenter: dialog.horizontalCenter; top: dialog.top; topMargin: 10 }
        text: title
    }

    Flickable {
        id: webFlicker

        anchors { fill: parent; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: 10 }
        contentWidth: webView.width
        contentHeight: webView.height
        boundsBehavior: Flickable.DragOverBounds
        clip: true

        WebView {
            id: webView

            width: 1024
            height: 1024

            opacity:(webView.progress < 1) ? 0 : 1
            onUrlChanged: {
                console.log(webView.url.toString());
                checkUrlForToken();
            }

            Behavior on opacity { PropertyAnimation { properties: "opacity"; duration: 500 } }
        }
    }
/*
    BusyDialog {
        id: busyDialog

        property bool show : false

        anchors.centerIn: dialog
        opacity: (busyDialog.show) || (webView.progress < 1) ? 1 : 0
    }

    CloseButton {
        onButtonClicked: close()
    }
*/

    /* private section */

    property string _flickrRequestToken
    property string _flickrRequestSecret

    function checkUrlForToken() {
        checkFlickrToken();
    }

    function checkFlickrToken() {
        var url = webView.url.toString();
        if (/oauth_verifier=/.test(url)) {
            var flickrVerifier = url.split("=")[2].split("&")[0];
            console.log(flickrVerifier)
            getFlickrAccessToken(flickrVerifier); // authorization agreement detected, exchange the request token against an access token
        }
        else if (/error/.test(url)) {
            messages.displayMessage(qsTr("Error obtaining flickr authorisation"));
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
                    webView.url = "https://www.flickr.com/services/oauth/authorize?perms=write&oauth_token=" + _flickrRequestToken;
                }
                else {
                    console.error(qsTr("Unable to obtain flickr request token"));
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
                //                console.log(response)
                if (/oauth_token/i.test(response)) {
                    var tSplit = response.split('&');
                    var token = tSplit[1].split('=')[1];
                    var secret = tSplit[2].split('=')[1];
                    DBAccess.saveToken(token, secret);
                    authorised({ "token": token, "secret": secret });
                }
                else {
                    messages.displayMessage(qsTr("Unable to obtain twitter access token"));
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
