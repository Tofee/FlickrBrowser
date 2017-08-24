TEMPLATE = lib
TARGET = FlickrServices
QT += qml quick xml
CONFIG += qt plugin

win32 {
    INCLUDEPATH  += $$quote(../../exiv2/deployed/include)
    LIBS         += $$quote(../../exiv2/deployed/lib32/exiv2.lib)
}
win64 {
    INCLUDEPATH  += $$quote(../../exiv2/deployed/include)
    LIBS         += $$quote(../../exiv2/deployed/lib64/exiv2.lib)
}

unix {
    LIBS         += -L/usr/lib -lexiv2
}

TARGET = $$qtLibraryTarget($$TARGET)
uri = org.flickrbrowser.services
# put the executable in the same directory as the tests
DESTDIR=$$OUT_PWD/../qflickrbrowser/$$replace(uri, \\., /)

# Input
SOURCES += \
    flickrservices_plugin.cpp \
    flickrservices.cpp \
    uploader.cpp

HEADERS += \
    flickrservices_plugin.h \
    flickrservices.h \
    uploader.h

DISTFILES = qmldir

!equals(_PRO_FILE_PWD_, $$DESTDIR) {
    copy_qmldir.target = $$DESTDIR/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath

    INSTALLS += target qmldir
}

