import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../Singletons"

Pane {
    height: filterRow.height

    RowLayout {
        id: filterRow
        width: parent.width

        Text {
            text: "Filter :"
        }
        TextField {
            Layout.fillWidth: true;

            onTextChanged: FlickrBrowserApp.contextualFilter.setFilter("title", text);
        }
    }
}
