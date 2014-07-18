import QtQuick 2.0

import "../Singletons"

Column {
    id: root

    // List of current flickr actions
    Connections {
        target: FlickrBrowserApp
        onFlickrActionLaunched: {
            actionsListModel.append( { method: reply.flickrMethod, args: reply.flickrArgs, replyObject: reply } );
        }
    }
    ListModel {
        id: actionsListModel
    }
    Repeater {
        model: actionsListModel
        delegate: Item {
            id: delegateItem
            property QtObject delegateReplyObject: replyObject

            width: root.width
            height: 20
            Text {
                text: method
            }
            onDelegateReplyObjectChanged: if( !delegateReplyObject ) {
                                              destructionAnimation.start();
                                          }
            NumberAnimation {
                id: destructionAnimation
                running: false
                target: delegateItem; properties: "opacity"; to: 0.2; duration: 800
                onStopped: actionsListModel.remove(index);
            }
        }
    }
    add: Transition {
         NumberAnimation { properties: "opacity"; from: 0; to: 1.0; duration: 100 }
    }
}
