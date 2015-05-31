#ifndef FLICKRSERVICES_H
#define FLICKRSERVICES_H

#include <QObject>
#include <QVariant>
#include <QString>

class FlickrServices : public QObject
{
    Q_OBJECT

public:
    static FlickrServices* instance()
    {
        static FlickrServices* instance = new FlickrServices;
        return instance;
    }

    Q_INVOKABLE QVariant getFileProperty(const QString &filePath, const QString &prop);

    Q_INVOKABLE QVariant getExifProperty(const QString &filePath, const QString &prop);

protected:
    FlickrServices(QObject *parent = 0);
    ~FlickrServices();
};

#endif // FLICKRSERVICES_H

