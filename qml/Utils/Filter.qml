import QtQuick 2.0

QtObject {
    signal filterChanged(variant filter)

    function setFilter(key, text) {
        _filter[key] = text;
        filterChanged(_filter);
    }
    function unsetFilter(key) {
        _filter[key] = undefined;
        filterChanged(_filter);
    }

    function matches(data) {
        if( !_filter ) return true; // no filter, then it's fine
        if( !data ) return false;              // no data, no match

        var doesMatch = true;
        for( var filterKey in _filter ) {
            if( _filter[filterKey] && data[filterKey] ) {
                try {
                    doesMatch = doesMatch && ( 0 <= data[filterKey].search(_filter[filterKey]) );
                }
                catch(e) { } // avoid "Invalid regular expression" spamming when user types in his filter
            }
        }

        return doesMatch;
    }

    ///// private
    property var _filter; // each { key, value } pair is a filtering set
}
