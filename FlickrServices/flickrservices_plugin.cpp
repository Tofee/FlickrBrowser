#include "flickrservices_plugin.h"
#include "flickrservices.h"

#include <qqml.h>

void FlickrServicesPlugin::registerTypes(const char *uri)
{
    // @uri org.flickrbrowser.services
    qmlRegisterUncreatableType<FlickrServices>(uri, 1, 0, "FlickrServices", QString("FlickrServices can't be created in QML"));
}


