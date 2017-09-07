import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import "../Core"
import "../Singletons"

// Display the properties of a collection.
ColumnLayout {
    id: propertiesCollection

    property FlickrReply flickrReply;
    Connections {
        target: flickrReply
        onReceived: {
            if(response && response.collection)
            {
                nbChildren = response.collection.child_count;
                title = response.collection.title._content;
                description = response.collection.description._content;
            }
        }
    }
    Component.onCompleted: {
        // Query Flickr to retrieve the informations on the collection
        flickrReply = FlickrBrowserApp.callFlickr("flickr.collections.getInfo", [ [ "collection_id", currentItemId ] ]);
    }

    property int nbChildren;
    property string title;
    property string description;

    Text {
        text: "Properties of this collection";
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "ID : " + currentItemId;
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Title : " + title;
        wrapMode: Text.Wrap
    }
    Text {
        text: "Content : " + nbChildren + " items";
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Description : " + description;
        wrapMode: Text.Wrap
    }
}
