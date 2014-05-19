import QtQuick 2.0
import QtQuick.Controls 1.1

Item {
    id: collectionGridPage

    property ListModel collectionTreeModel: photoSetListModel; // by default, show all the photosets
    property ListModel photoSetListModel;

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: collectionsGridView.height
        clip: true
        flickableDirection: Flickable.VerticalFlick

        Flow {
            id: collectionsGridView

            x: 0; y: 0
            width: collectionGridPage.width

            Repeater {
                model: collectionTreeModel
                delegate:
                    Item {
                        height: collectionCell.height
                        width: collectionCell.width

                        function getPhotosetTitle() {
                            // Find the size of that album
                            var i;
                            for( i = 0; i <= photoSetListModel.count; i++ ) {
                                var photoSetInfo = photoSetListModel.get(i);
                                if( photoSetInfo && photoSetInfo.id === id ) {
                                    return photoSetInfo.title._content + "(" + String(parseInt(photoSetInfo.photos)+parseInt(photoSetInfo.videos)) + ")";
                                }
                            }
                        }
                        function getPhotosetIcon() {
                            // Find the icon of that album
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
                            width: collectionImage.width

                            Image {
                                id: collectionImage
                                height: 150
                                width: 150

                                fillMode: Image.PreserveAspectFit
                                source: getPhotosetIcon()
                            }
                            Text {
                                id: collectionTitle
                                anchors.left: parent.left
                                anchors.right: parent.right

                                color: "white"

                                text: getPhotosetTitle()
                                wrapMode: Text.Wrap
                            }
                        }
                        MouseArea {
                            anchors.fill: collectionCell
                            onClicked: {
                                // We are opening a photoset album
                                console.log("showing photoset id = " + id);
                                var stackView = collectionGridPage.Stack.view;
                                stackView.navigationPath.push(collectionTitle.text);
                                stackView.push({item: Qt.resolvedUrl("PhotosetGridPage.qml"),
                                                properties: {"photosetId": id}});
                            }
                        }
                    }
            }
        }
    }
}
