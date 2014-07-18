import QtQuick 2.0
import QtTest 1.0

import "../Singletons"
import "../Core/DBAccess.js" as DBAccess
import ".."

FlickrBrowser {
    id: myApp

    Component.onCompleted: {
        // generated July 17th
        // DBAccess.saveToken("token", "secret");
    }

    SignalSpy {
        id: spy
        target: myApp
        signalName: "stateChanged"
    }

    TestCase {
        name: "BasicTest"
        when: windowShown
        function test_simpleTest() {
            spy.clear();
            spy.wait(10000);
            verify(spy.count >= 1, "spy.count >=1 !");
        }
    }
}
