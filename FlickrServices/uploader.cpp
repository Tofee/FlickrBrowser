/*
 * Copyright (C) 2015 Alberto Mardegan <mardy@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "uploader.h"

#include <QCryptographicHash>
#include <QDomDocument>
#include <QDomElement>
#include <QFileInfo>
#include <QFile>
#include <QHttpMultiPart>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <ctime>

typedef QPair<QString, QString> QPairStringString_t;

namespace Uploader {

class UploaderPrivate: public QObject
{
    Q_OBJECT
    Q_DECLARE_PUBLIC(Uploader)

public:
    UploaderPrivate(Uploader *q);

    QByteArray signRequest(const QUrl &requestUrl, const QByteArray &verb,
                           const QUrlQuery &query);
    QByteArray hashHMACSHA1(const QByteArray &baseString,
                            const QByteArray &secret);
    void appendQueryItems(QHttpMultiPart *multiPart, const QUrlQuery &query);

private Q_SLOTS:
    void onUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void onFinished();

private:
    QNetworkAccessManager *m_manager;
    QByteArray m_consumerKey;
    QByteArray m_consumerSecret;
    QByteArray m_token;
    QByteArray m_tokenSecret;
    QString m_fileName;
    bool m_busy;
    int m_progress;
    QString m_photoId;
    QString m_errorMessage;
    QString m_link;
    mutable Uploader *q_ptr;
};

UploaderPrivate::UploaderPrivate(Uploader *q):
    m_manager(new QNetworkAccessManager(this)),
    m_busy(false),
    m_progress(0),
    q_ptr(q)
{
    qsrand(time(NULL));
}

QByteArray UploaderPrivate::signRequest(const QUrl &requestUrl,
                                        const QByteArray &verb,
                                        const QUrlQuery &query)
{
    QByteArray baseString = verb;

    baseString += '&';
    baseString += QUrl::toPercentEncoding(requestUrl.toString());
    // Query parameters must be sorted before signing
    QList<QPair<QString, QString> > items =
        query.queryItems(QUrl::FullyEncoded);
    std::sort(items.begin(), items.end());
    QByteArray queryString;
    Q_FOREACH(const QPairStringString_t &pair, items) {
        if (!queryString.isEmpty()) queryString += '&';
        queryString += pair.first + '=' + pair.second;
    }
    baseString += '&' + QUrl::toPercentEncoding(queryString);
    qDebug() << "Basestring is" << baseString;

    QByteArray key = m_consumerSecret + '&' + m_tokenSecret;
    return QUrl::toPercentEncoding(hashHMACSHA1(baseString, key).toBase64());
}

// Create a HMAC-SHA1 signature
QByteArray UploaderPrivate::hashHMACSHA1(const QByteArray &baseString,
                                         const QByteArray &secret)
{
    // The algorithm is defined in RFC 2104
    int blockSize = 64;
    QByteArray key(secret);
    QByteArray opad(blockSize, 0x5c);
    QByteArray ipad(blockSize, 0x36);

    // If key size is too large, compute the hash
    if (key.size() > blockSize) {
        key = QCryptographicHash::hash(key, QCryptographicHash::Sha1);
    }

    // If too small, pad with 0x00
    if (key.size() < blockSize) {
        key += QByteArray(blockSize - key.size(), 0x00);
    }

    // Compute the XOR operations
    for (int i = 0; i <= key.size() - 1; i++) {
        ipad[i] = (char) (ipad[i] ^ key[i]);
        opad[i] = (char) (opad[i] ^ key[i]);
    }

    // Append the data to ipad
    ipad += baseString;

    // Hash sha1 of ipad and append the data to opad
    opad += QCryptographicHash::hash(ipad, QCryptographicHash::Sha1);

    // Return array contains the result of HMAC-SHA1
    return QCryptographicHash::hash(opad, QCryptographicHash::Sha1);
}

void UploaderPrivate::appendQueryItems(QHttpMultiPart *multiPart, const QUrlQuery &query)
{
    QByteArray contentDisposition("form-data; name=\"");

    QList<QPair<QString, QString> > items =
        query.queryItems(QUrl::FullyDecoded);
    Q_FOREACH(const QPairStringString_t &pair, items) {
        QHttpPart part;
        part.setHeader(QNetworkRequest::ContentDispositionHeader,
                       contentDisposition + pair.first + '"');
        part.setBody(pair.second.toUtf8());
        multiPart->append(part);
    }
}

void UploaderPrivate::onUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    Q_Q(Uploader);

    int progress = (bytesTotal > 0) ? bytesSent * 100 / bytesTotal : 0;
    /* Let's keep 100% for confirmed uploads only */
    if (progress >= 100) progress = 99;
    m_progress = progress;
    Q_EMIT q->progressChanged();
}

void UploaderPrivate::onFinished()
{
    Q_Q(Uploader);

    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    reply->deleteLater();

    QByteArray data = reply->readAll();
    qDebug() << "Reply:" << data;
    QDomDocument doc;
    doc.setContent(data);
    QDomElement root = doc.documentElement();
    if (root.attribute("stat") == QStringLiteral("ok")) {
        m_photoId = root.firstChildElement("photoid").text();
    } else {
        QDomElement error = root.firstChildElement("err");
        m_errorMessage = error.attribute("msg");
        qWarning() << "Error:" << m_errorMessage;
    }

    m_busy = false;
    Q_EMIT q->finished();
}

Uploader::Uploader(QObject *parent):
    QObject(parent),
    d_ptr(new UploaderPrivate(this))
{
}

Uploader::~Uploader()
{
    delete d_ptr;
}

void Uploader::setKeys(const QByteArray &consumerKey,
                       const QByteArray &consumerSecret,
                       const QByteArray &token,
                       const QByteArray &tokenSecret)
{
    Q_D(Uploader);

    d->m_consumerKey = consumerKey;
    d->m_consumerSecret = consumerSecret;
    d->m_token = token;
    d->m_tokenSecret = tokenSecret;
}

bool Uploader::isBusy() const
{
    Q_D(const Uploader);
    return d->m_busy;
}

QString Uploader::fileName() const
{
    Q_D(const Uploader);
    return d->m_fileName;
}

int Uploader::progress() const
{
    Q_D(const Uploader);
    return d->m_progress;
}

QString Uploader::uploadedPhotoId() const
{
    Q_D(const Uploader);
    return d->m_photoId;
}

QString Uploader::errorMessage() const
{
    Q_D(const Uploader);
    return d->m_errorMessage;
}

void Uploader::uploadImage(const QString &fileName,
                           const QString &title,
                           const QString &description,
                           const QStringList &tags,
                           bool isPublic, bool isFriend, bool isFamily,
                           bool isHidden)
{
    Q_D(Uploader);

    d->m_fileName = fileName;

    QFileInfo fileInfo(fileName);

    QUrl url("https://up.flickr.com/services/upload/");

    QUrlQuery query;
    // OAuth query items
    query.addQueryItem("oauth_signature_method", "HMAC-SHA1");
    query.addQueryItem("oauth_version", "1.0");
    query.addQueryItem("oauth_consumer_key", d->m_consumerKey);
    query.addQueryItem("oauth_token", d->m_token);
    query.addQueryItem("oauth_timestamp", QString::number(time(NULL)));
    query.addQueryItem("oauth_nonce", QString::number(qrand()));
    // API-specific query items
    query.addQueryItem("title",
                       QUrl::toPercentEncoding(title.isEmpty() ?
                                               fileInfo.baseName() : title));
    query.addQueryItem("is_public", isPublic ? "1" : "0");
    query.addQueryItem("is_friend", isFriend ? "1" : "0");
    query.addQueryItem("is_family", isFamily ? "1" : "0");
    query.addQueryItem("hidden", isHidden ? "2" : "1");
    QStringList escapedTags;
    Q_FOREACH(const QString &tag, tags) {
        QString escaped(QUrl::toPercentEncoding(tag));
        escaped.replace("\"", "\\\"");
        escapedTags.append(QString("\"%1\"").arg(escaped));
    }
    query.addQueryItem("tags", escapedTags.join(" "));
    query.addQueryItem("description", QUrl::toPercentEncoding(description));

    // Compute the OAuth signature and append it to the query
    QByteArray signature = d->signRequest(url, "POST", query);
    query.addQueryItem("oauth_signature", signature);

    qDebug() << "URL: " << url;

    QHttpMultiPart *multiPart =
        new QHttpMultiPart(QHttpMultiPart::FormDataType);
    d->appendQueryItems(multiPart, query);
    QFile *file = new QFile(fileName, multiPart);
    file->open(QIODevice::ReadOnly);

    QHttpPart upload;
    QByteArray contentDisposition = "form-data; name=\"photo\"; filename=\"";
    contentDisposition += fileInfo.fileName().replace('"', '_').toUtf8();
    contentDisposition += '"';
    upload.setHeader(QNetworkRequest::ContentDispositionHeader,
                     contentDisposition);
    upload.setHeader(QNetworkRequest::ContentTypeHeader, "image/jpeg");
    upload.setBodyDevice(file);

    multiPart->append(upload);

    QNetworkRequest request(url);
    QNetworkReply *reply = d->m_manager->post(request, multiPart);
    multiPart->setParent(reply);

    d->m_progress = 0;
    d->m_busy = true;
    d->m_photoId.clear();
    d->m_errorMessage.clear();
    Q_EMIT progressChanged();

    connect(reply, &QNetworkReply::finished,
            d, &UploaderPrivate::onFinished);
    connect(reply, &QNetworkReply::uploadProgress,
            d, &UploaderPrivate::onUploadProgress);

}

} // namespace

#include "uploader.moc"
