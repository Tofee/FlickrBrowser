import QtQuick 2.0
import QtQuick.Controls 1.1
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

    Label {
        text: "Properties of this file";
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "ID : " + currentItemId;
    }
    Label {
        Layout.preferredWidth: parent.width
        text: "Name : " + fileName;
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
