.pragma library

.import QtQuick.LocalStorage 2.0 as Sql

var cachedToken = new Object;

function clearToken() {
    console.log("Saving...")
    var db = Sql.LocalStorage.openDatabaseSync("FlickrBrowserDB", "1.0", "The FlickrBrowser DB", 10);
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS FlickrToken(token TEXT, secret TEXT)');
        tx.executeSql('DELETE FROM FlickrToken');

        cachedToken = new Object;
    });
}

function saveToken(token, secret) {
    console.log("Saving...")
    var db = Sql.LocalStorage.openDatabaseSync("FlickrBrowserDB", "1.0", "The FlickrBrowser DB", 10);
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS FlickrToken(token TEXT, secret TEXT)');
        tx.executeSql('DELETE FROM FlickrToken');
        var dataStr = "INSERT INTO FlickrToken VALUES(?, ?)";
        tx.executeSql(dataStr, [token, secret]);

        cachedToken.token = token;
        cachedToken.secret = secret;
    });
}

function checkToken(cb) {
    if( cachedToken && cachedToken.token && cachedToken.secret ) {
        cb(cachedToken);
    }
    else {
        var db = Sql.LocalStorage.openDatabaseSync("FlickrBrowserDB", "1.0", "The FlickrBrowser DB", 10);
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS FlickrToken(token TEXT, secret TEXT)');
            var rs = tx.executeSql("SELECT * FROM FlickrToken");
            if (rs.rows.item(0)) {
                cachedToken.token = rs.rows.item(0).token
                cachedToken.secret = rs.rows.item(0).secret
            }

            //console.debug("token = " + cachedToken.token);
            //console.debug("secret = " + cachedToken.secret);

            cb(cachedToken);
        });
    }
}



