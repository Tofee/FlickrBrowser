import QtQuick 2.0

Item {
    property string pageItemId
    property ListModel pageModel
    property string pageModelType: "Generic"

    signal remoteModelChanged(string itemId);
}
