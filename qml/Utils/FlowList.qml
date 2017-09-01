import QtQuick 2.6
import QtQml.Models 2.2

import "../Singletons"

Flickable {
    id: flickableItem

    property alias model: flowRepeater.model
    property alias delegate: flowRepeater.delegate
    property alias spacing: flowItem.spacing
    property string itemType;

    contentWidth: width
    contentHeight: flowItem.height
    clip: true
    flickableDirection: Flickable.VerticalFlick

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
        var modelIndex = model.index(index, 0);
        if( modifiers & Qt.ControlModifier ) {
            FlickrBrowserApp.currentSelection.select(modelIndex, ItemSelectionModel.Toggle);
        }
        else if( modifiers & Qt.ShiftModifier ) {
            if( FlickrBrowserApp.currentSelection.currentIndex.valid && FlickrBrowserApp.currentSelection.currentIndex !== modelIndex ) {
                var currentIndexRow = FlickrBrowserApp.currentSelection.currentIndex.row;
                var selectedIndexRow = modelIndex.row;
                var incr = (currentIndexRow > selectedIndexRow) ? -1 : 1;

                FlickrBrowserApp.currentSelection.clearSelection();
                for( var idxSel = currentIndexRow; idxSel !== selectedIndexRow+incr; idxSel += incr ) {
                    FlickrBrowserApp.currentSelection.select(model.index(idxSel, 0), ItemSelectionModel.Select);
                }
            }
        }
        else {
            FlickrBrowserApp.currentSelection.select(modelIndex, ItemSelectionModel.ClearAndSelect);
            FlickrBrowserApp.currentSelection.setCurrentIndex(modelIndex, ItemSelectionModel.Current);
        }
    }
}
