///// Code copied from https://github.com/hash-bang/simpleJSONFilter
///// Under MIT license.

var defaultEquals = true; // If we can't find a valid handler default to key==val behaviour (i.e. {'foo': 'bar'} tests that the key 'foo' is the value 'bar')
var silent = false; // Shut up if we cant find a suitable handler

var handlers = [];

var myFilter = null;
var myData = null;
var myLimit = null;
var myWantArray = false;

var __initialized = function () {
    addHandler(/^(.*?) ={1,2}$/, function(key, val, data) { // {'foo =': 'bar'} or {'foo ==': 'bar'}
        return (data[key] == val);
    });
    addHandler(/^(.*?) >$/, function(key, val, data) { // {'foo >': 'bar'}
        return (data[key] > val);
    });
    addHandler(/^(.*?) <$/, function(key, val, data) { // {'foo <': 'bar'}
        return (data[key] < val);
    });
    addHandler(/^(.*?) (?:>=|=>)$/, function(key, val, data) { // {'foo >=': 'bar'} (or '=>')
        return (data[key] >= val);
    });
    addHandler(/^(.*?) (?:<=|=<)$/, function(key, val, data) { // {'foo <=': 'bar'} or ('=<')
        return (data[key] <= val);
    });

    return true;
}

// Simple setters {{{
function setFilter(iFilter) {
    myFilter = iFilter;
}

function setData(iData) {
    myData = iData;
}

function setLimit(iLimit) {
    myLimit = iLimit;
}

function setWantArray(iWantArray) {
    myWantArray = iWantArray === undefined ? true : iWantArray;
}
// }}}

function reset() {
    myData = null;
    myFilter = null;
    myWantArray = false;
    myLimit = 0;
}

function addHandler(re, callback) {
    handlers.push([re, callback]);
}

function exec(filter, data, limit) {
    var out = myWantArray ? [] : {};
    var found = 0;
    if (!filter)
        filter = myFilter;
    if (!data)
        data = myData;
    if (!limit)
        limit = myLimit;

    if( data &&
        data.toString && data.toString().substr(0,13) === "QQmlListModel" ) {

        var realData = data;
        data = [];

        var i;
        for( i = 0; i < realData.count; ++i ) {
            data.push(realData.get(i));
        }
    }

    for (var id in data) {
        var row = data[id];
        if (matches(filter, row)) {
            if (myWantArray) {
                out.push(row);
            } else
                out[id] = row;

            if (limit && ++found >= limit)
                break;
        }
    }
    return out;
}

function matches(filter, data) {
    for (var key in filter) {
        var handled = false;
        for (var h in handlers) {
            var matches = handlers[h][0].exec(key);
            if (matches) { // Use this handler
                handled = true;
                if (handlers[h][1](matches[1], filter[key], data)) {
                    // console.log('OK');
                } else {
                    return false;
                }
            }
        }
        if (!handled)
            if (defaultEquals) {
                if (data[key] != filter[key])
                    return false;
            } else {
                if (!silent)
                    console.warn('No filter matching incomming string "' + key + '". Defaulting to no-match');
                return false;
            }
    }
    return true;
}

