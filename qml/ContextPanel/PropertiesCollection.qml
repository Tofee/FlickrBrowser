import QtQuick 2.0
import QtQuick.Controls 1.1
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

    Label {
        text: "Properties of this collection";
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
        text: "Content : " + nbChildren + " items";
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Description : " + description;
        wrapMode: Text.Wrap
    }
}
