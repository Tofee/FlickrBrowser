import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import "../Singletons"
import "../Utils"

BrowserPage {
    id: mainPage

    pageModelType: "RootView"

    VisualItemModel {
        id: itemModel
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/collections-tree.png");
            text: "Collections"
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                properties: { pageItemId: "0" } });
            }
        }
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/albums.png");
            text: "Albums"
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml"),
                                properties: { pageItemId: "0" } });
            }
        }
/*        Button {
            width: 150; height: 150
            text: "Tags"
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("TagsPage.qml")});
            }
        }*/
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/tag.png");
            text: "Tags Map"
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("TagsMapPage.qml")});
            }
        }
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/search.png");
            text: "Search..."
            onClicked: {
                var stackView = mainPage.Stack.view;
                stackView.navigationPath.push(text);
                stackView.push({item: Qt.resolvedUrl("SearchPhotosPage.qml")});
            }
        }
        // File system collection analyser: only if run with C++ plugins
        Loader {
            active: typeof hasExtendedFlickrPlugins !== 'undefined'
            sourceComponent: Component {
                CategoryButton {
                    width: 150; height: 150
                    iconSource: Qt.resolvedUrl("../images/folder_image.png");
                    text: "Local Files"
                    onClicked: {
                        var stackView = mainPage.Stack.view;
                        stackView.navigationPath.push(text);
                        stackView.push({item: Qt.resolvedUrl("LocalFolderPage.qml")});
                    }
                }
            }
        }
    }
    Flow {
        anchors.fill: parent
        spacing: 2
        Repeater {
            model: itemModel
        }
    }
}
