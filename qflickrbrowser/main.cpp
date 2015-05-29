#include <QtGui/QGuiApplication>
#include <QNetworkProxy>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QNetworkProxyQuery npq(QUrl("http://www.flickr.com"));
    QList<QNetworkProxy> proxyList = QNetworkProxyFactory::systemProxyForQuery(npq);
    if( proxyList.size() > 0 && proxyList[0].hostName().length()>0 ) {
        qDebug() << "proxyList[0].hostName() : " << proxyList[0].hostName()
                 << " : proxyList[0].port() : " << proxyList[0].port();
        QNetworkProxy::setApplicationProxy(proxyList[0]);
    }

    QQmlApplicationEngine engine;
//    engine.addImportPath("qml/");
    engine.load(QStringLiteral("qml/FlickrBrowserWindow.qml"));

    return app.exec();
}
