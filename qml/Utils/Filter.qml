import QtQuick 2.0

QtObject {
    signal filterChanged(string filter)

    function setFilter(text) {
        _filter = text;
        filterChanged(_filter);
    }

    function matches(data) {
        if( _filter.length === 0 ) return true; // no filter, then it's fine
        if( !data ) return false;              // no data, no match

        if( data.title ) {
            try {
                return ( 0 <= data.title.search(_filter) );
            }
            catch(e) { } // avoid "Invalid regular expression" spamming when user types in his filter
        }

        return false;
    }

    ///// private
    property string _filter: "";
}
