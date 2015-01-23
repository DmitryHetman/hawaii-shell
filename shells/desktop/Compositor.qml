/****************************************************************************
 * This file is part of Hawaii.
 *
 * Copyright (C) 2012-2015 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *
 * Author(s):
 *    Pier Luigi Fiorini
 *
 * $BEGIN_LICENSE:GPL2+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 ***************************************************************************/

import QtQuick 2.0
import QtCompositor 1.0
import GreenIsland 1.0
import Hawaii.Themes 1.0 as Themes
import org.hawaii.misc 0.1
import org.hawaii.session 0.1 as Session
import org.kde.plasma.core 2.0 as PlasmaCore
import "WindowManagement.js" as WindowManagement
import "screen"

Item {
    readonly property alias screenView: screenViewLoader.item
    readonly property alias surfaceModel: surfaceModel
    property var activeWindow: null
    readonly property int activeWindowIndex: WindowManagement.getActiveWindowIndex()
    readonly property var windowList: WindowManagement.windowList

    signal keyPressed(var event)
    signal keyReleased(var event)

    signal windowSwitchPrev()
    signal windowSwitchNext()
    signal windowSwitchSelect()

    id: compositorRoot
    state: "splash"
    states: [
        State {
            name: "splash"
            PropertyChanges { target: splashScreen; opacity: 1.0 }
            PropertyChanges { target: keyFilter; enabled: false }
            StateChangeScript { script: disableInput() }
        },
        State {
            name: "session"
            PropertyChanges { target: keyFilter; enabled: true }
            PropertyChanges { target: splashScreen; opacity: 0.0 }
            PropertyChanges { target: windowSwitcherLoader; source: ""; z: 899 }
            PropertyChanges { target: shieldLoader; source: ""; visible: false }
            PropertyChanges { target: logoutLoader; source: ""; z: 899 }
            PropertyChanges { target: lockScreenLoader; source: ""; z: 899 }
            PropertyChanges { target: splashScreen; opacity: 0.0 }
            StateChangeScript { script: enableInput() }
        },
        State {
            name: "windowSwitcher"
            PropertyChanges { target: windowSwitcherLoader; source: "WindowSwitcher.qml"; z: 910 }
            StateChangeScript { script: disableInput() }
        },
        State {
            name: "logout"
            PropertyChanges { target: keyFilter; enabled: false }
            PropertyChanges { target: shieldLoader; source: "Shield.qml"; z: 909 }
            PropertyChanges { target: logoutLoader; source: "LogoutScreen.qml"; mode: "logout"; z: 910 }
            StateChangeScript { script: disableInput() }
        },
        State {
            name: "poweroff"
            PropertyChanges { target: keyFilter; enabled: false }
            PropertyChanges { target: shieldLoader; source: "Shield.qml"; z: 909 }
            PropertyChanges { target: logoutLoader; source: "LogoutScreen.qml"; mode: "poweroff"; z: 910 }
            StateChangeScript { script: disableInput() }
        },
        State {
            name: "restart"
            PropertyChanges { target: keyFilter; enabled: false }
            PropertyChanges { target: shieldLoader; source: "Shield.qml"; z: 909 }
            PropertyChanges { target: logoutLoader; source: "LogoutScreen.qml"; mode: "restart"; z: 910 }
            StateChangeScript { script: disableInput() }
        },
        State {
            name: "lock"
            PropertyChanges { target: keyFilter; enabled: false }
            PropertyChanges { target: shieldLoader; source: ""; visible: false }
            PropertyChanges { target: logoutLoader; source: ""; z: 899 }
            PropertyChanges { target: lockScreenLoader; source: "LockScreen.qml"; z: 910 }
            StateChangeScript { script: disableInput() }
        },
        State {
            name: "shield"
            PropertyChanges { target: shieldLoader; source: "Shield.qml"; visible: true }
        }
    ]
    onKeyPressed: {
        // Abort session
        // TODO: Handle this as a keybinding
        if (event.modifiers === (Qt.ControlModifier | Qt.AltModifier) && event.key === Qt.Key_Backspace) {
            event.accepted = true;
            compositor.abortSession();
            return;
        }

        // Power off
        if (event.modifiers === (Qt.ControlModifier | Qt.AltModifier) && event.key === Qt.Key_Delete && session.canPowerOff) {
            state = "poweroff";
            event.accepted = true;
            return;
        }

        // Lock screen
        if (event.modifiers & Qt.MetaModifier && event.key === Qt.Key_L) {
            state = "lock";
            event.accepted = true;
            return;
        }

        // Activate session
        if (event.modifiers === (Qt.ControlModifier | Qt.AltModifier) && event.key >= Qt.Key_F1 && event.key <= Qt.Key_F12) {
            var index = (event.key - Qt.Key_F1) + 1;
            session.activateSession(index);
            event.accepted = true;
            return;
        }

        // Window switcher
        if (event.modifiers & Qt.MetaModifier) {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                if (state != "windowSwitcher" && surfaceModel.count >= 2) {
                    // Activate only when two or more windows are available
                    state = "windowSwitcher";
                    event.accepted = true;
                    return;
                }
            }
        }

        // Present windows
        if (event.modifiers & Qt.MetaModifier && event.key === Qt.Key_E) {
            compositorRoot.toggleEffect("PresentWindowsGrid");
            event.accepted = true;
            return;
        }
    }
    onKeyReleased: {
        // Window switcher
        if (state == "windowSwitcher") {
            if (event.modifiers & Qt.MetaModifier) {
                // Cycle between windows
                if (event.key === Qt.Key_Tab)
                    compositorRoot.windowSwitchNext();
                else if (event.key === Qt.Key_Backtab)
                    compositorRoot.windowSwitchPrev();
            } else {
                // Give focus to the selected window
                compositorRoot.windowSwitchSelect();

                // Keys released, deactivate switcher
                state = "session";
            }

            event.accepted = true;
            return;
        }

        // Workspaces
        if (event.modifiers & (Qt.MetaModifier | Qt.ControlModifier)) {
            if (event.key === Qt.Key_Left)
                screenView.workspacesView.selectPrevious();
            else if (event.key === Qt.Key_Right)
                screenView.workspacesView.selectNext();
        }
    }

    Timer {
        id: idleTimer
        //interval: compositor.idleInterval
        onIntervalChanged: {
            if (running)
                restart();
        }
    }

    ListModel {
        id: surfaceModel
    }

    Connections {
        target: compositor
        onIdleInhibitResetRequested: compositor.idleInhibit = 0
        onIdleTimerStartRequested: idleTimer.running = true
        onIdleTimerStopRequested: idleTimer.running = false
        onIdle: {
            // Set idle hint
            session.idle = true;
        }
        onWake: {
            // Unset idle hint
            session.idle = false;
        }
        onFadeIn: {
            // Bring user layer up
            compositorRoot.state = "session";
        }
        onFadeOut: {
            // Fade the desktop out
            compositorRoot.state = "splash";
        }
        onReady: {
            // Start idle timer
            idleTimer.running = true
        }
        onSurfaceMapped: {
            // A surface was mapped
            WindowManagement.surfaceMapped(surface);
        }
        onSurfaceUnmapped: {
            // A surface was unmapped
            WindowManagement.surfaceUnmapped(surface);
        }
        onSurfaceDestroyed: {
            // A surface was destroyed
            WindowManagement.surfaceDestroyed(surface);
        }
    }

    /*
     * Components
     */

    // FPS counter
    Text {
        anchors {
            top: parent.top
            right: parent.right
        }
        z: 1000
        text: fpsCounter.fps
        font.pointSize: 36
        style: Text.Raised
        styleColor: "#222"
        color: "white"
        visible: false

        FpsCounter {
            id: fpsCounter
        }
    }

    // Key events filter
    KeyEventFilter {
        id: keyFilter

        Keys.onPressed: compositorRoot.keyPressed(event)
        Keys.onReleased: compositorRoot.keyReleased(event)
    }

    // Session
    Session.SessionInterface {
        id: session
        onSessionLocked: compositorRoot.state = "lock"
        onSessionUnlocked: compositorRoot.state = "session"
    }

    /*
     * Splash
     */

    Loader {
        id: splashScreen
        anchors.fill: parent
        opacity: 0.0
        onOpacityChanged: {
            if (opacity == 1.0) {
                splashScreen.z = 910;
                splashScreen.source = "SplashScreen.qml";
            } else if (opacity == 0.0) {
                splashScreenTimer.start();
            }
        }

        // Unload after a while so that the opacity animation is visible
        Timer {
            id: splashScreenTimer
            running: false
            interval: 5000
            onTriggered: {
                splashScreen.z = 899;
                splashScreen.source = "";
            }
        }

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.InSine
                duration: Themes.Units.longDuration
            }
        }
    }

    /*
     * Screen view
     */

    Loader {
        property bool alreadyLoaded: false

        id: screenViewLoader
        anchors.fill: parent
        asynchronous: true
        z: 900
        onLoaded: {
            // We asynchronously load the screen component when the splash state
            // is reached. As soon as the component is loaded we switch to
            // the session state
            compositorRoot.state = "session";
        }
        onItemChanged: {
            if (!item || alreadyLoaded)
                return;

            // Create default 4 workspaces
            var i;
            for (i = 0; i < 4; i++)
                item.workspacesView.add();
            item.workspacesView.select(0);

            // Setup workspaces only once
            alreadyLoaded = true;
        }
        onStatusChanged: {
            // Show an error screen instead
            if (status == Loader.Error)
                source = "ErrorScreen.qml";
        }
    }

    /*
     * Window switcher
     */

    Loader {
        id: windowSwitcherLoader
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        asynchronous: true
        z: 899
        width: parent.width - (Themes.Units.largeSpacing * 2)
        height: (parent.height * 0.5) - (Themes.Units.largeSpacing * 2)

        Behavior on z {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                duration: Themes.Units.longDuration
            }
        }
    }

    // Shield
    Loader {
        id: shieldLoader
        anchors.fill: parent
        asynchronous: true
        z: progress > 0 ? 901 : 899
        opacity: progress

        Behavior on z {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                duration: Themes.Units.longDuration
            }
        }

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.InSine
                duration: Themes.Units.longDuration
            }
        }
    }

    /*
     * Logout screen
     */

    Loader {
        property string mode: "logout"

        id: logoutLoader
        anchors.fill: parent
        asynchronous: true
        z: 899

        Behavior on z {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                duration: Themes.Units.longDuration
            }
        }
    }

    Binding {
        target: logoutLoader.item
        property: "mode"
        value: logoutLoader.mode
    }

    Connections {
        target: logoutLoader.item
        onSuspendRequested: compositorRoot.state = "lock"
        onCancel: compositorRoot.state = "session"
    }

    /*
     * Lock screen
     */

    Loader {
        id: lockScreenLoader
        anchors.fill: parent
        asynchronous: true
        z: 899

        Behavior on z {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                duration: Themes.Units.longDuration
            }
        }
    }

    Connections {
        target: lockScreenLoader.item
        onUnlocked: compositorRoot.state = "session"
    }

    /*
     * Component
     */

    Component.onCompleted: {
        // Load screen view asynchronously
        screenViewLoader.source = "screen/ScreenView.qml";
    }

    /*
     * Methods
     */

    function toggleEffect(name) {
        screenView.workspacesView.currentWorkspace.effects.toggle(name);
    }

    function endEffect(name) {
        screenView.workspacesView.currentWorkspace.effects.end(name);
    }

    function addWindowToEffect(window) {
        screenView.workspacesView.currentWorkspace.effects.addWindow(window);
    }

    function removeWindowFromEffect(window) {
        screenView.workspacesView.currentWorkspace.effects.removeWindow(window);
    }

    function moveFront(window) {
        return WindowManagement.moveFront(window);
    }

    function forgetWindow(window) {
        return WindowManagement.forgetWindow(window);
    }

    function enableInput() {
        var i;
        for (i = 0; i < compositorRoot.surfaceModel.count; i++) {
            var window = compositorRoot.surfaceModel.get(i).window;
            window.child.focus = true;
        }
    }

    function disableInput() {
        var i;
        for (i = 0; i < compositorRoot.surfaceModel.count; i++) {
            var window = compositorRoot.surfaceModel.get(i).window;
            window.child.focus = false;
        }
    }
}
