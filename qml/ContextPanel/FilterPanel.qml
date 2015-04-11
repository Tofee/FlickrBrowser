import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "../Singletons"

Item {
    height: filterRow.height

    RowLayout {
        id: filterRow
        width: parent.width

        Label {
            text: "Filter :"
        }
        TextField {
            Layout.fillWidth: true;

            onTextChanged: FlickrBrowserApp.contextualFilter.setFilter("title", text);
        }
    }
}
