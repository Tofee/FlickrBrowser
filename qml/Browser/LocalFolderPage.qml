import QtQuick 2.0
import QtQuick.Controls 1.1

import Qt.labs.folderlistmodel 2.1

import "../Core"
import "../Singletons"
import "../Utils" as Utils

BrowserPage {
    id: localFolderPage

    pageModelType: "LocalFolder"
    pageModel: ListModel {}

    FolderListModel {
        id: folderListModel
        rootFolder: FlickrBrowserApp.localPhotoFolderRoot
        folder: folderPath

        onCountChanged: {
            // re-sync pageModel
            pageModel.clear();
            for( var i = 0; i < folderListModel.count; ++i ) {
                pageModel.append({
                                     filePath: folderListModel.get(i, "filePath"),
                                     fileName: folderListModel.get(i, "fileName")
                                 });
            }
        }
    }

    property string folderPath: FlickrBrowserApp.localPhotoFolderRoot

    Utils.FlowList {
        anchors.fill: parent
        id: flowList

        itemType: "collection"

        model: pageModel
        delegate:
            Utils.FlowListDelegate {

                imageSource: filePath
                textContent: fileName

                imageFillMode: Image.PreserveAspectFit
                imageHeight: 150
                imageWidth: 150
                textPixelSize: 10

                isSelected: (pageModel.get(index).selected) ? true : false

                onClicked: {
                    flowList.selected(index, mouse.modifiers);
                }
                onDoubleClicked: {
                    var stackView = collectionGridPage.Stack.view;
                    var myModelItem = sortedModel.get(index)

                    if( myModelItem.collection ) {
                        stackView.navigationPath.push(myModelItem.title);
                        stackView.push({item: Qt.resolvedUrl("CollectionCollectionGridPage.qml"),
                                        properties: {"pageItemId": myModelItem.id}});
                    }
                    else if( myModelItem.set ) {
                        stackView.navigationPath.push(myModelItem.title);
                        stackView.push({item: Qt.resolvedUrl("PhotosetCollectionGridPage.qml"),
                                        properties: {"pageItemId": myModelItem.id}});
                    }
                }
            }
    }
}
