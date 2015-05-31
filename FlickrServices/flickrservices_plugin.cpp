#include "flickrservices_plugin.h"
#include "flickrservices.h"

#include <qqml.h>

static QObject *flickrservices_callback(QQmlEngine *e, QJSEngine *)
{
    return FlickrServices::instance();
}

void FlickrServicesPlugin::registerTypes(const char *uri)
{
    // @uri org.flickrbrowser.services
    qmlRegisterSingletonType<FlickrServices>(uri, 1, 0, "FlickrServices", flickrservices_callback);
}


