.pragma library

function fillModelWithCollections(listModel, collectionTreeRoot, forPhotoset, depth) {
    if( !depth ) depth = 0;

    // some filtering, because mixed collections are not supported in Flickr
    var forbiddenContent = forPhotoset ? "collection" : "set";
    var subContent =       forPhotoset ? "set" : "collection";

    for( var i=0; i<collectionTreeRoot.count; ++i ) {
        var item = collectionTreeRoot.get(i);
        if( item[forbiddenContent] &&
            item[forbiddenContent].count > 0 )
            continue;

        var shitedTitle = "";
        for (; shitedTitle.length < depth;)
            shitedTitle += " ";
        shitedTitle += item.title;

        listModel.append({ colId: item.id, title: shitedTitle });

        // recurse
        if( item[subContent] &&
            item[subContent].count > 0 )
            fillModelWithCollections(listModel, item[subContent], forPhotoset, depth+1);
    }
}

