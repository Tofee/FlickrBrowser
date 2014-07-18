import QtQuick 2.0

import "../Singletons"

/*

Official API:
flickr.collections.getTree Optional user_id
flickr.collections.getInfo Required collection_id
NOT official:
flickr.collections.create Optional description, Optional parent_id, Required title, Optional after_new_coll
flickr.collections.sortCollections Optional child_collection_ids, Optional collection_id, Optional no_move
flickr.collections.editSets Required collection_id, Optional do_remove, Required photoset_ids
flickr.collections.createIcon Required collection_id, Required photo_ids
flickr.collections.removeSet Required collection_id, Required photoset_id
flickr.collections.delete Required collection_id, Optional recursive
flickr.collections.moveCollection Required collection_id, Required parent_collection_id
flickr.collections.editMeta Optional collection_id, Optional description, Optional title
*/

Column {
    id: root
    property string pageModelType: FlickrBrowserApp.currentShownPage.pageModelType
    Loader {
        id: propertiesLoader

        anchors.left: parent.left
        anchors.right: parent.right
    }
    onPageModelTypeChanged: {
        propertiesLoader.active = false; // force unload
        if( pageModelType != "" ) {
            propertiesLoader.source = Qt.resolvedUrl("Authoring" + pageModelType + ".qml");
            propertiesLoader.active = true;
        }
    }

    AuthoringActionsList {
        width: root.width
    }
}
