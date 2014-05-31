import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI

// Display the properties of a photoset.
ColumnLayout {
    id: propertiesSet

    Component.onCompleted: {
        // Query Flickr to retrieve the informations on the photoset
        FlickrAPI.callFlickrMethod("flickr.photosets.getInfo", [ [ "photoset_id", currentItemId ] ], propertiesSet.toString(), function(response) {
            if(response && response.photoset)
            {
                nbPhotos = response.photoset.count_photos;
                nbVideos = response.photoset.count_videos;
                title = response.photoset.title._content;
                description = response.photoset.description._content;

                var dateCreateValue = new Date(response.photoset.date_create * 1000);
                creationDate = dateCreateValue.toLocaleString();
                var dateUpdateValue = new Date(response.photoset.date_update * 1000);
                updateDate = dateUpdateValue.toLocaleString();
            }
        });
    }
    Component.onDestruction: {
        // safe-guard: be sure the item was not deleted during this async call to Flickr
        FlickrAPI.disableCallbacks(propertiesSet.toString());
    }

    property string title;
    property string description;
    property int nbPhotos;
    property int nbVideos;
    property string creationDate;
    property string updateDate;

    Label {
        text: "Properties of this album";
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "ID : " + currentItemId;
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Title : " + title;
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Content : " + nbPhotos + " photos " + nbVideos + " videos";
        wrapMode: Text.Wrap
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Description : " + description;
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
