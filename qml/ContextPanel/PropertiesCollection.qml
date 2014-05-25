import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import "../Core/FlickrAPI.js" as FlickrAPI

// Display the properties of a collection.
ColumnLayout {
    id: propertiesCollection

    Component.onCompleted: {
        // Query Flickr to retrieve the informations on the collection
        FlickrAPI.callFlickrMethod("flickr.collections.getInfo", [ [ "collection_id", selectedItemId ] ], function(response) {
            if(response && response.collection)
            {
                nbChildren = response.collection.child_count;
                title = response.collection.title._content;
                description = response.collection.description._content;
            }
        });
    }

    property int nbChildren;
    property string title;
    property string description;

    Label {
        text: "The selection is a collection";
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Title : " + title;
        wrapMode: Text.Wrap
    }
    Label {
        text: "Content : " + nbChildren + " items";
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Description : " + description;
        wrapMode: Text.Wrap
    }
}
