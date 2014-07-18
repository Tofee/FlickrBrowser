# Add more folders to ship with the application, here
folder_qml.source = ../qml
folder_qml.target = /
DEPLOYMENTFOLDERS = folder_qml

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH = "../qml/"

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

QT += network

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

HEADERS +=

OTHER_FILES +=
