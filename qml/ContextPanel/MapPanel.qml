import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "../Singletons"

// Display the actions for the map view.
Column {
    Button {
        width: parent.width
        text: "Geotag selection"
        onClicked: console.log("Let's do geotagging !");
    }
}
