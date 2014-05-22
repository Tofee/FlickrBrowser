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
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                properties: { collectionTreeModel: FlickrBrowserApp.collectionTreeModel } });
            }
        }
        Button {
            width: 150; height: 150
            text: "Albums"
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml")});
            }
        }
        Button {
            width: 150; height: 150
            text: "Tags"
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("TagsPage.qml")});
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
