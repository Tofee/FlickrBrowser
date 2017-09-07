import QtQuick 2.0

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
            onClicked: mainPage.pushNewPage(Qt.resolvedUrl("CollectionCollectionGridPage.qml"), text, { pageItemId: "0" });
        }
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/albums.png");
            text: "Albums"
            onClicked: mainPage.pushNewPage(Qt.resolvedUrl("PhotosetCollectionGridPage.qml"), text, { pageItemId: "0" });
        }
/*        Button {
            width: 150; height: 150
            text: "Tags"
            onClicked: mainPage.pushNewPage(Qt.resolvedUrl("TagsPage.qml"), text, {});
        }*/
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/tag.png");
            text: "Tags Map"
            onClicked: mainPage.pushNewPage(Qt.resolvedUrl("TagsMapPage.qml"), text, {});
        }
        CategoryButton {
            width: 150; height: 150
            iconSource: Qt.resolvedUrl("../images/search.png");
            text: "Search..."
            onClicked: mainPage.pushNewPage(Qt.resolvedUrl("SearchPhotosPage.qml"), text, {});
        }
        // File system collection analyser: available only if C++ plugin is there
        Loader {
            source: "LocalFolderPageButton.qml"
            property BrowserPage browserPage: mainPage;
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
