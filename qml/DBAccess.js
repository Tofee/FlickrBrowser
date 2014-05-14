.pragma library

.import QtQuick.LocalStorage 2.0 as Sql

function saveToken(token, secret) {
    console.log("Saving...")
    var db = Sql.LocalStorage.openDatabaseSync("FlickrBrowserDB", "1.0", "The FlickrBrowser DB", 10);
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS FlickrToken(token TEXT, secret TEXT)');
        var dataStr = "INSERT INTO FlickrToken VALUES(?, ?)";
        tx.executeSql(dataStr, [token, secret]);
    });
}

function checkToken() {
    var ret = new Object;

    var db = Sql.LocalStorage.openDatabaseSync("FlickrBrowserDB", "1.0", "The FlickrBrowser DB", 10);
    var dataStr = "SELECT * FROM FlickrToken";
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS FlickrToken(token TEXT, secret TEXT)');
        var rs = tx.executeSql(dataStr);
        if (rs.rows.item(0)) {
            ret.token = rs.rows.item(0).token
            ret.secret = rs.rows.item(0).secret
            console.log("Auth already done.")
        } else {
            console.log("Auth not yet done.")
        }
    });
}



