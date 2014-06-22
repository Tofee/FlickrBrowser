import QtQuick 2.0

import "Selection.js" as Priv

QtObject {
    signal selectionChanged(variant selection)

    function addToSelection(item) {
        if( item && item.object && item.object.selected ) return;  // nothing to do

        Priv._selection.push(item);
        if( item.object )
            item.object.selected = true; // this may add eventualy a new property to the object
        selectionChanged(Priv._selection);
    }
    function removeFromSelection(criterias) {
        var nbItemsRemoved = 0;
        for (var i = Priv._selection.length - 1; i >= 0; i--) {
            var identical = true;
            for( var j in criterias ) {
                if( Priv._selection[i][j] !== criterias[j] )
                {
                    identical = false;
                    break;
                }
            }
            if( identical ) {
                if( Priv._selection[i].object )
                    Priv._selection[i].object.selected = false;
                Priv._selection.splice(i, 1);
                nbItemsRemoved++;
            }
        }
        if( nbItemsRemoved > 0 )
            selectionChanged(Priv._selection);
    }

    property int count: 0;

    function get(idx) {
        if( idx < 0 || idx >= Priv._selection.length ) return null;

        return Priv._selection[idx];
    }

    function getSelection() {
        return Priv._selection;
    }

    function clear() {
        removeFromSelection({});
    }

    ///// private
    onSelectionChanged: {
        count = Priv._selection.length;
    }
}
