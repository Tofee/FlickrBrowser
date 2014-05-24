/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

Qt.include("sha1.js");

function getValidator(resource, password)
{
    return b64_sha1(resource + password) + "=";
}

function getDigest(validator, timestamp, nonce)
{
    return b64_sha1(nonce + timestamp + validator) + "=";
}

function getTimestamp()
{
    return parseInt((new Date).valueOf() / 1000);
}

function getNonce()
{
    var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
    var result = "";
    for (var i = 0; i < 41; ++i) {
        var rnum = Math.floor(Math.random() * chars.length);
        result += chars.substring(rnum, rnum+1);
    }
    return result;
}

function url_encode(string) {
    var encodedString = encodeURIComponent(string)
        .replace( /!/g, '%21' )
        .replace( /\(/g, '%28' )
        .replace( /\)/g, '%29' )
        .replace( /\*/g, '%2A' )
        .replace( /'/g, '%27' );

    return encodedString;
}

function createOAuthHeader(site, type, url, credentials, authParameters, parameters, body)
{
    // FlickrBrowser API keys
    var consumer_key = "a1c5db5c8eca7c23e3b8e8ac825e4225";
    var consumer_secret = "ad935d350269787a";

    var timestamp =  getTimestamp();
    var nonce = getNonce();

    var parameterlist = new Array();
    parameterlist.push( ["oauth_consumer_key", consumer_key] );
    parameterlist.push( ["oauth_nonce", nonce] );
    parameterlist.push( ["oauth_timestamp", timestamp] );
    parameterlist.push( ["oauth_signature_method", "HMAC-SHA1"] );
    parameterlist.push( ["oauth_version", "1.0"] );
    if (credentials) {
        if (credentials.token) {
            parameterlist.push( ["oauth_token", credentials.token] );
        }
        if (credentials.verifier) {
            parameterlist.push( ["oauth_verifier", credentials.verifier] );
        }
        if (credentials.callback) {
            parameterlist.push( ["oauth_callback", credentials.callback] );
        }
    }

    if (authParameters)
        parameterlist = parameterlist.concat(authParameters);

    if (parameters)
        parameterlist = parameterlist.concat(parameters);

    parameterlist.sort(function(a,b) {
                           if (a[0] < b[0]) return  -1;
                           if (a[0] > b[0]) return 1;
                           if (a[1] < b[1]) return -1;
                           if (a[1] > b[1]) return 1;
                           return 0;
                           });

    var normalized = "";

    for (var ii = 0; ii < parameterlist.length; ++ii) {
        if (ii != 0) normalized += "&";
        normalized += parameterlist[ii][0] + "=" + encodeURIComponent(parameterlist[ii][1]);
    }
    if (body)
        normalized += "&" + body;
    var basestring = type + "&" + encodeURIComponent(url) + "&" + encodeURIComponent(normalized);

    var keystring = encodeURIComponent(consumer_secret) + "&";
    if (credentials) {
        if (credentials.secret) {
            keystring += encodeURIComponent(credentials.secret);
        }
    }

    var signature = b64_hmac_sha1(keystring, basestring);

    var authHeader = "OAuth ";
    authHeader += "oauth_consumer_key=\"" + encodeURIComponent(consumer_key) + "\"";
    authHeader += ", oauth_nonce=\"" + encodeURIComponent(nonce) + "\"";
    authHeader += ", oauth_timestamp=\"" + encodeURIComponent(timestamp) + "\"";
    authHeader += ", oauth_signature=\"" + encodeURIComponent(signature) + "\"";
    authHeader += ", oauth_signature_method=\"HMAC-SHA1\"";
    authHeader += ", oauth_version=\"1.0\"";
    if(authParameters)
        for (var ii = 0; ii < authParameters.length; ii++)
            authHeader += ", " + authParameters[ii][0] + "=\"" + encodeURIComponent(authParameters[ii][1]) + "\"";

    if (credentials) {
        if (credentials.token) {
            authHeader += ", oauth_token=\"" + encodeURIComponent(credentials.token) + "\"";
        }
        if (credentials.verifier) {
            authHeader += ", oauth_verifier=\"" + encodeURIComponent(credentials.verifier) + "\"";
        }
        if (credentials.callback) {
           authHeader += ", oauth_callback=\"" + encodeURIComponent(credentials.callback) + "\"";
        }
    }

    var requrl = url;
    if (parameters) {
        for (var ii = 0; ii < parameters.length; ++ii) {
            if (ii == 0) requrl += "?";
            else requrl += "&";
            // console.log("sending parameters: " + parameters[ii][0] + "=" + encodeURIComponent(parameters[ii][1]));
            requrl += parameters[ii][0] + "=" + escape(parameters[ii][1]);
        }
    }
    var oauthData = { "url": requrl, "header": authHeader };
    return oauthData;
}
