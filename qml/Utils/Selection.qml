import QtQuick 2.0

import "Selection.js" as Priv

QtObject {
    signal selectionChanged(variant selection)

    function addToSelection(item) {
        Priv._selection.push(item);
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
        if( Priv._selection.length > 0 ) {
            Priv._selection = [];
            selectionChanged(Priv._selection);
        }
    }

    ///// private
    onSelectionChanged: {
        count = Priv._selection.length;
    }
}
