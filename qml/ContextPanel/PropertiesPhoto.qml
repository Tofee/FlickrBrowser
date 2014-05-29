import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI

// Display the properties of a photo.
ColumnLayout {
    id: propertiesPhoto

    Component.onCompleted: {
        // Query Flickr to retrieve the informations on the photo
        FlickrAPI.callFlickrMethod("flickr.photos.getInfo", [ [ "photo_id", currentItemId ] ], propertiesPhoto.toString(), function(response) {
            if(response && response.photo)
            {
                title = response.photo.title._content;
                description = response.photo.description._content;

                dateTaken = response.photo.dates.taken;
                var dateCreateValue = new Date(response.photo.dates.posted * 1000);
                creationDate = dateCreateValue.toLocaleString();
                var dateUpdateValue = new Date(response.photo.lastupdate * 1000);
                updateDate = dateUpdateValue.toLocaleString();

                comments = response.photo.comments._content;

                if( response.photo.tags.tag ) {
                    var i;
                    for( i = 0; i < response.photo.tags.tag.length; ++i ) {
                        if( i > 0 ) tags += ", "
                        tags += '"' + response.photo.tags.tag[i].raw + '"';
                    }
                }
            }
        });
    }
    Component.onDestruction: {
        // safe-guard: be sure the item was not deleted during this async call to Flickr
        FlickrAPI.disableCallbacks(propertiesPhoto.toString());
    }

    property string title;
    property string description;
    property date dateTaken;
    property string creationDate;
    property string updateDate;
    property string comments;
    property string tags;

    Label {
        Layout.preferredWidth: parent.width
        text: "Title : " + title;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Taken : " + dateTaken;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Description : " + description;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Comments : " + comments;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Tags : " + tags;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Creation date : " + creationDate;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Last updated  : " + updateDate;
        wrapMode: Text.Wrap
    }
}
