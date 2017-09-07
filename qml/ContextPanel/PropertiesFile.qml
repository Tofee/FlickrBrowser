import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import org.flickrbrowser.services 1.0

import "../Core"
import "../Singletons"

// Display the properties of a file.
ColumnLayout {
    id: propertiesPhoto

    property string fileName: FlickrServices.getFileProperty(currentItemId, "fileName");
    property string description: FlickrServices.getExifProperty(currentItemId, "description");
    property date dateTaken;
    property string creationDate;
    property string updateDate;
    property string comments;
    property string tags: FlickrServices.getExifProperty(currentItemId, "tagList").join(",");

    Text {
        text: "Properties of this file";
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "ID : " + currentItemId;
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Name : " + fileName;
        wrapMode: Text.Wrap
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Taken : " + dateTaken;
        wrapMode: Text.Wrap
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Description : " + description;
        wrapMode: Text.Wrap
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Comments : " + comments;
        wrapMode: Text.Wrap
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Tags : " + tags;
        wrapMode: Text.Wrap
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Creation date : " + creationDate;
        wrapMode: Text.Wrap
    }
    Text {
        Layout.preferredWidth: parent.width
        text: "Last updated  : " + updateDate;
        wrapMode: Text.Wrap
    }
}
