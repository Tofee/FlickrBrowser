.pragma library

.import "DBAccess.js" as DBAccess
.import "OAuthCore.js" as OAuth

function callFlickrMethod(method, args, callback) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            if( callback ) {
                console.log("doc.responseText=" + doc.responseText);
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

