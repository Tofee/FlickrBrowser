import QtQuick 2.0

QtObject {
    property string flickrMethod
    property variant flickrArgs

    property int status: 0

    signal received(variant response)
    signal completed()
}
