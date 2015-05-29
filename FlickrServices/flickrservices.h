#ifndef FLICKRSERVICES_H
#define FLICKRSERVICES_H

#include <QObject>

class FlickrServices : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlickrServices)

    Q_INVOKABLE qreal sizeToPixels(const QString &size);

public:
    FlickrServices(QObject *parent = 0);
    ~FlickrServices();
};

#endif // FLICKRSERVICES_H

