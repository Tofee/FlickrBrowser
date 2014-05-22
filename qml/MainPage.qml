import QtQuick 2.0
import QtQuick.Controls 1.1

import "Singletons"

Item {
    id: mainPage

    VisualItemModel {
        id: itemModel
        Button {
            width: 150; height: 150
            text: "Collections"
            onClicked: {
                // We are opening a photoset album
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                properties: { collectionTreeModel: FlickrBrowserApp.collectionTreeModel } });
            }
        }
        Button {
            width: 150; height: 150
            text: "All albums"
            onClicked: {
                // We are opening a photoset album
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml")});
            }
        }
    }
    Flow {
        anchors.fill: parent
        Repeater {
            model: itemModel
        }
    }
}
