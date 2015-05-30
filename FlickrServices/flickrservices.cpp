#include "flickrservices.h"

FlickrServices::FlickrServices(QObject *parent):
    QObject(parent)
{
}

FlickrServices::~FlickrServices()
{
}

/*!
 * \qmlmethod real FlickrServices::sizeToPixels(string size)
 * The function calculates the pixel size of a given scale. The size scale can be
 * one of the strings specified at modularScale function. On failure returns 0.
 */
qreal FlickrServices::sizeToPixels(const QString &size)
{
    return 15.5;
}

