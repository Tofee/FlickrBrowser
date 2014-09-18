import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core"
import "../Singletons"

// Display the properties of an account (root view).
ColumnLayout {
    id: propertiesSet

    property FlickrReply flickrReplyGetUserId;
    property FlickrReply flickrReplyGetInfo;
    Connections {
        target: flickrReplyGetUserId
        onReceived: {
            if(response && response.user && response.user.id )
            {
                // Query Flickr to retrieve the informations on the account details
                flickrReplyGetInfo = FlickrBrowserApp.callFlickr("flickr.people.getInfo", [ [ "user_id", response.user.id ] ]);
            }
        }
    }
    Connections {
        target: flickrReplyGetInfo
        onReceived: {
            if(response && response.person)
            {
                userid = response.person.id;
                username = response.person.username._content;
                realname = response.person.realname._content;
                nbPhotos = response.person.photos.count._content;
/*
                var dateCreateValue = new Date(response.photoset.date_create * 1000);
                creationDate = dateCreateValue.toLocaleString();
                var dateUpdateValue = new Date(response.photoset.date_update * 1000);
                updateDate = dateUpdateValue.toLocaleString();
                */
            }
        }
    }
    Component.onCompleted: {
        // Query Flickr to retrieve the informations on the account id
        flickrReplyGetUserId = FlickrBrowserApp.callFlickr("flickr.test.login", null);
    }

    property string userid: "";
    property string username: "";
    property string realname: "";
    property string nbPhotos: "n/a"

    Label {
        text: "Current account :";
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "ID : " + userid;
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Username : " + username;
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Real name : " + realname;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Photos : " + nbPhotos;
    }
}
