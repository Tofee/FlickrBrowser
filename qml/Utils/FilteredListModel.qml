import QtQuick 2.0

ListModel {
    id: filteredListModel;

    property variant originJSONModel;
    property JSONFilter filter;

    Component.onCompleted: {
        update();
    }
    onOriginJSONModelChanged: {
        update();
    }
    onFilterChanged: {
        update();
    }

    function update() {
        filter.setData(originJSONModel);
        clear();
        if( !originModel ) return; // nothing to fill in

        var filteredResult = originJSONModel;  // if no filter, just copy the whole model
        if( filter ) {
            // use filter
            filteredResult = filter.exec();
        }

        var i;
        for( i = 0; i < filteredResult.length; ++i ) {
            filteredListModel.append(filteredResult[i]);
        }
    }
}
