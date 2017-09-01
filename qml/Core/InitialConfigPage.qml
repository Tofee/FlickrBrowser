import QtQuick 2.6
import QtQuick.Controls 2.2

Pane {
    property alias consumerKey: consumerKeyText.text
    property alias consumerSecret: consumerSecretText.text
    signal settingsDone(string consumerKey, string consumerSecret);

    Column {
        width: parent.width
        spacing: 10

        Label {
            width: parent.width
            text: "Please enter consumer key and secret.\nIf you don't have one, visit :\n https://www.flickr.com/services/api/misc.api_keys.html"
        }

        TextField {
            id: consumerKeyText
            width: parent.width
            placeholderText: "API Key : "
        }
        TextField {
            id: consumerSecretText
            width: parent.width
            placeholderText: "API Secret : "
        }

        Button {
            enabled: consumerKeyText.text && consumerSecretText.text
            text: "Done"
            width: parent.width
            onClicked: settingsDone(consumerKeyText.text, consumerSecretText.text);
        }
    }
}
