import QtQuick 2.9
import QtQuick.Controls 2.2

import "../Singletons"

Item {
    id: rootBrowserPage

    property string pageItemId
    property ListModel pageModel
    property ListModel modelForSelection
    property string pageModelType: "Generic"

    signal remoteModelChanged();

    // forward the signal if necessary
    Connections {
        target: FlickrBrowserApp
        onRemoteModelChanged: if( pageItemId === itemId ) remoteModelChanged();
    }

    function pushNewPage(pageUrl, title, pageProperties)
    {
        var component = Qt.createComponent(pageUrl);
        if (component.status === Component.Ready) {
            stackView = rootBrowserPage.StackView.view;

            stackView.navigationPath.push(title);
            stackView.push(component, pageProperties);
        }
        else if (component.status === Component.Error) {
            // Error Handling
            console.log("Error loading component:", component.errorString());
        }
    }
}
