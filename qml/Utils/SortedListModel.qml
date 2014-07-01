import QtQuick 2.0

ListModel {
    id: sortedModel;

    property ListModel originModel
    property string sortKey
    property bool sortAscendent

    onOriginModelChanged: updateSortedModel(true);

    Connections {
        target: originModel
        onDataChanged: updateSortedModel(false);
    }

    function updateSortedModel(fromScratch)
    {
    }
}
