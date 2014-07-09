import QtQuick 2.0

ListModel {
    id: sortedModel;

    property ListModel originModel
    property string sortKey
    property bool sortAscendent

    signal syncModel()

    function _getDescendantProp(obj, desc) {
        var arr = desc.split(".");
        while(arr.length && (obj = obj[arr.shift()]));
        return obj;
    }

    function _compare(a,b,reverse) {
        return reverse * ((a > b) - (b > a));
    }

    onSyncModel: {
        var _array = [];

        sortedModel.clear();

        for( var i=0; i<originModel.count; i++ ) {
            _array.push(originModel.get(i));
        }
        _array.sort(function(a,b) { return _compare(_getDescendantProp(a,sortedModel.sortKey),_getDescendantProp(b,sortedModel.sortKey),sortedModel.sortAscendent?1:-1) });
        _array.forEach(function(item) { sortedModel.append(item) });
    }
}
