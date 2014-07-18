#include <QtGui/QGuiApplication>
#include <QNetworkProxy>
#include <QQmlEngine>
#include "qtquick2applicationviewer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QNetworkProxyQuery npq(QUrl("http://www.google.com"));
    QList<QNetworkProxy> proxyList = QNetworkProxyFactory::systemProxyForQuery(npq);
    if( proxyList.size() > 0 ) {
        qDebug() << "proxyList[0].hostName() : " << proxyList[0].hostName()
                 << " : proxyList[0].port() : " << proxyList[0].port();
        QNetworkProxy::setApplicationProxy(proxyList[0]);
    }

    QtQuick2ApplicationViewer viewer;
    viewer.setMainQmlFile(QStringLiteral("qml/FlickrBrowser.qml"));
    viewer.showExpanded();

    return app.exec();
}
