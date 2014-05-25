import QtQuick 2.0

import "JSONFilter.js" as JSONFilter

QtObject {
    function setFilter(iFilter) {
        JSONFilter.filter(iFilter);
    }

    function setData(iData) {
        JSONFilter.data(iData);
    }

    function setLimit(iLimit) {
        JSONFilter.limit(iLimit);
    }

    function setWantArray(iWantArray) {
        JSONFilter.wantArray(iWantArray);
    }

    function reset() {
        JSONFilter.reset();
    }

    function addHandler(re, callback) {
        JSONFilter.addHandler(re, callback);
    }

    function exec(filter, data, limit) {
        return JSONFilter.exec(filter, data, limit);
    }

    function matches(filter, data) {
        return JSONFilter.matches(filter, data);
    }
}
