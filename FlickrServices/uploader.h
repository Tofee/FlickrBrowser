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

#ifndef UPLOADER_UPLOADER_H
#define UPLOADER_UPLOADER_H

#include <QObject>

class QByteArray;
class QStringList;

namespace Uploader {

class UploaderPrivate;
class Uploader: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)

public:
    explicit Uploader(QObject *parent = 0);
    ~Uploader();

    void setKeys(const QByteArray &consumerKey,
                 const QByteArray &consumerSecret,
                 const QByteArray &token,
                 const QByteArray &tokenSecret);

    bool isBusy() const;
    QString fileName() const;
    int progress() const;

    QString uploadedPhotoId() const;
    QString errorMessage() const;

public Q_SLOTS:
    void uploadImage(const QString &fileName,
                     const QString &title,
                     const QString &description,
                     const QStringList &tags,
                     bool isPublic, bool isFriend, bool isFamily,
                     bool isHidden);

Q_SIGNALS:
    void progressChanged();
    void finished();

private:
    Q_DECLARE_PRIVATE(Uploader)
    UploaderPrivate *d_ptr;
};

} // namespace

#endif // UPLOADER_UPLOADER_H
