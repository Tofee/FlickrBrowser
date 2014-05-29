.pragma library

.import "DBAccess.js" as DBAccess
.import "OAuthCore.js" as OAuth

var authorizedCallbacks = []

function authorizeCallbacks(objectName) {
    if( authorizedCallbacks.indexOf(objectName) < 0 ) {
        authorizedCallbacks.push(objectName);
    }
}

function disableCallbacks(objectName) {
    for(var idxCB = authorizedCallbacks.length-1; idxCB >= 0; --idxCB ) {
        if( authorizedCallbacks[idxCB] === objectName ) {
            authorizedCallbacks.splice(idxCB, 1);
            break;
        }
    }
}

function isAlive(objectName) {
    return (objectName.length === 0 || authorizedCallbacks.indexOf(objectName) >= 0);
}

function callFlickrMethod(method, args, objectName, callback) {
    authorizeCallbacks(objectName);

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            if( callback && isAlive(objectName) ) {
                var responseJSON = {};
                if( doc.responseText.length>0 && doc.responseText[0] === '{' )
                    responseJSON = JSON.parse(doc.responseText);
                callback(responseJSON);
            }
        }
    }
    var parameters = new Array();
    parameters.push( ["nojsoncallback", 1] );
    parameters.push( ["format", "json"] );
    parameters.push( ["method", method] );
    var parametersWithArgs = parameters;
    if( args )
        parametersWithArgs = parameters.concat(args);

    DBAccess.checkToken(function(credentials) {
        if( credentials && credentials.token && credentials.secret ) {
            var oauthData = OAuth.createOAuthHeader("flickr", "GET", "https://api.flickr.com/services/rest/", credentials, null, parametersWithArgs);
            doc.open("GET", oauthData.url);
            doc.setRequestHeader("Authorization", oauthData.header);
            doc.send();
        }
        else {
            callback({});
        }
    });
}

