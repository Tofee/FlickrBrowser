#ifndef FLICKRSERVICES_H
#define FLICKRSERVICES_H

#include <QObject>

class FlickrServices : public QObject
{
    Q_OBJECT

public:
    static FlickrServices* instance()
    {
        static FlickrServices* instance = new FlickrServices;
        return instance;
    }

    Q_INVOKABLE qreal sizeToPixels(const QString &size);

protected:
    FlickrServices(QObject *parent = 0);
    ~FlickrServices();
};

#endif // FLICKRSERVICES_H

