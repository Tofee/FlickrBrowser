import QtQuick 2.0

Flickable {
    id: flickableItem

    property alias model: flowRepeater.model
    property alias delegate: flowRepeater.delegate
    property string itemType;

    contentWidth: width
    contentHeight: flowItem.height
    clip: true
    flickableDirection: Flickable.VerticalFlick

    property int _lastSelectionIndex: -1;
    signal selected(int index, variant modifiers);

    Flow {
        id: flowItem

        x: 0; y: 0
        width: flickableItem.width
        spacing: 3

        Repeater {
            id: flowRepeater
        }
    }

    onSelected: {
        var nbSelected = FlickrBrowserApp.currentSelection.count;
        var itemModel = pageModel.get(index);
        if( modifiers & Qt.ControlModifier ) {
            if( itemModel.selected ) {
                FlickrBrowserApp.currentSelection.removeFromSelection({ "type": flickableItem.itemType, "id": itemModel.id });
            }
            else {
                FlickrBrowserApp.currentSelection.addToSelection({ "type": flickableItem.itemType, "id": itemModel.id, "object": itemModel });
            }
        }
        else if( mouse.modifiers & Qt.ShiftModifier ) {
            if( _lastSelectionIndex >= 0 && _lastSelectionIndex != index ) {
                var incr = (_lastSelectionIndex > index) ? -1 : 1;
                for( var idxSel = collectionsGridView.lastSelectionIndex; idxSel !== index+incr; idxSel += incr ) {
                    FlickrBrowserApp.currentSelection.addToSelection({ "type": flickableItem.itemType, "id": pageModel.get(idxSel).id, "object": pageModel.get(idxSel) });
                }
            }
        }
        else {
            var wasSelected = itemModel.selected;
            FlickrBrowserApp.currentSelection.clear();
            _lastSelectionIndex = -1;
            if( !wasSelected || nbSelected !== 1 ) {
                _lastSelectionIndex = index;
                FlickrBrowserApp.currentSelection.addToSelection({ "type": flickableItem.itemType, "id": itemModel.id, "object": itemModel });
            }
        }
    }
}
