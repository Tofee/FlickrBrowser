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
                                     id: folderListModel.get(i, "filePath"),
                                     filePath: folderListModel.get(i, "filePath"),
                                     fileName: folderListModel.get(i, "fileName"),
                                     fileIsDir: folderListModel.get(i, "fileIsDir")
                                 });
            }
        }
    }

    property string folderPath: FlickrBrowserApp.localPhotoFolderRoot

    Utils.FlowList {
        anchors.fill: parent
        id: flowList

        itemType: "file"

        model: pageModel
        delegate:
            Utils.FlowListDelegate {

                imageSource: fileIsDir ? "../images/folder_image.png" : filePath
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
                    var stackView = localFolderPage.Stack.view;
                    var myModelItem = pageModel.get(index)

                    stackView.navigationPath.push(myModelItem.fileName);
                    if( myModelItem.fileIsDir ) {
                        stackView.push({item: Qt.resolvedUrl("LocalFolderPage.qml"),
                                        properties: {"folderPath": localFolderPage.folderPath + "/" + myModelItem.fileName }});
                    }
                    else {
                        stackView.push({item: Qt.resolvedUrl("PhotoPage.qml"),
                                        properties: {"pageItemId": "", "photoUrl": myModelItem.filePath}});
                    }
                }
            }
    }
}
