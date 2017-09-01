import QtQuick 2.0

import "../Utils"
import org.flickrbrowser.services 1.0

CategoryButton {
    property BrowserPage browserPage;

    width: 150; height: 150
    iconSource: Qt.resolvedUrl("../images/folder_image.png");
    text: "Local Files"
    onClicked: {
        var stackView = browserPage.Stack.view;
        stackView.navigationPath.push(text);
        stackView.push({item: Qt.resolvedUrl("LocalFolderPage.qml")});
    }
}
