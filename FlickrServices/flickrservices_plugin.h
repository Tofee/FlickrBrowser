#ifndef FLICKRSERVICES_PLUGIN_H
#define FLICKRSERVICES_PLUGIN_H

#include <QQmlExtensionPlugin>

class FlickrServicesPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif // FLICKRSERVICES_PLUGIN_H

