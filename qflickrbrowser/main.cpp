#include <QtGui/QGuiApplication>
#include <QNetworkProxy>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtWebEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("QFlickrBrowser");
    QGuiApplication::setApplicationVersion("0.8");

    QtWebEngine::initialize();

    QNetworkProxyQuery npq(QUrl("http://www.flickr.com"));
    QList<QNetworkProxy> proxyList = QNetworkProxyFactory::systemProxyForQuery(npq);
    if( proxyList.size() > 0 && proxyList[0].hostName().length()>0 ) {
        qDebug() << "proxyList[0].hostName() : " << proxyList[0].hostName()
                 << " : proxyList[0].port() : " << proxyList[0].port();
        QNetworkProxy::setApplicationProxy(proxyList[0]);
    }

    QQmlApplicationEngine engine;
    engine.addImportPath(".");
    engine.load(QStringLiteral("qml/FlickrBrowser.qml"));

    return app.exec();
}
