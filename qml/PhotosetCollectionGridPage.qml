import QtQuick 2.0
import QtQuick.Controls 1.1

Item {
    id: collectionGridPage

    property ListModel collectionTreeModel;
    property ListModel photoSetListModel;

    property string pagePath: "/"

    GridView {
        id: collectionsGridView

        cellWidth: 150
        cellHeight: 150

        anchors.fill: parent
        model: collectionTreeModel

        delegate:
            Item {
                function getPhotosetTitle() {
                    // We are showing a photoset icon, so let's find the size of that album
                    var i;
                    for( i = 0; i <= photoSetListModel.count; i++ ) {
                        var photoSetInfo = photoSetListModel.get(i);
                        if( photoSetInfo && photoSetInfo.id === id ) {
                            return title + "(" + String(parseInt(photoSetInfo.photos)+parseInt(photoSetInfo.videos)) + ")";
                        }
                    }
                }
                function getPhotosetIcon() {
                    // We are showing a photoset icon, so let's find the size of that album
                    var i;
                    for( i = 0; i <= photoSetListModel.count; i++ ) {
                        var photoSetInfo = photoSetListModel.get(i);
                        if( photoSetInfo && photoSetInfo.id === id ) {
                            return photoSetInfo.primary_photo_extras.url_sq;
                        }
                    }
                }

                Column {
                    id: collectionCell
                    width: collectionsGridView.cellWidth
                    Image {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        fillMode: Image.PreserveAspectFit
                        source: getPhotosetIcon()
                    }
                    Text {
                        id: collectionTitle
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: getPhotosetTitle()
                    }
                }
                MouseArea {
                    anchors.fill: collectionCell
                    onClicked: {
                        // We are opening a photoset album
                        stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                        properties: {"photosetId": id, "pagePath": pagePath + "/" + title}});
                    }
                }
            }
    }
}
