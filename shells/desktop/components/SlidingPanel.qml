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
import Hawaii.Themes 1.0 as Themes

Item {
    default property alias contents: background.children
    property int edge: Qt.LeftEdge
    readonly property alias expanded: __priv.open

    id: slidingPanel
    width: {
        if (edge == Qt.TopEdge || edge == Qt.BottomEdge)
            return compositorRoot.screenView.width;
        return Math.max(Themes.Units.gu(10), childrenRect.width);
    }
    height: {
        if (edge == Qt.LeftEdge || edge == Qt.RightEdge)
            return compositorRoot.screenView.height;
        return Math.max(Themes.Units.gu(10), childrenRect.height);
    }
    clip: true
    onEdgeChanged: __priv.resetPosition()
    onWidthChanged: __priv.resetPosition()
    onHeightChanged: __priv.resetPosition()
    visible: false

    Behavior on x {
        NumberAnimation {
            duration: Themes.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: Themes.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    QtObject {
        id: __priv

        property bool open: false

        function setInitialPosition() {
            switch (edge) {
            case Qt.LeftEdge:
                x = -slidingPanel.width;
                y = 0;
                break;
            case Qt.TopEdge:
                x = 0;
                y = -slidingPanel.height;
                break;
            case Qt.RightEdge:
                x = compositorRoot.screenView.width + slidingPanel.width;
                y = 0;
                break;
            case Qt.BottomEdge:
                x = 0;
                y = compositorRoot.screenView.height + slidingPanel.height;
                break;
            default:
                break;
            }
        }

        function setFinalPosition() {
            switch (edge) {
            case Qt.LeftEdge:
                x = 0;
                y = 0;
                break;
            case Qt.TopEdge:
                x = 0;
                y = 0;
                break;
            case Qt.RightEdge:
                x = compositorRoot.screenView.width - slidingPanel.width;
                y = 0;
                break;
            case Qt.BottomEdge:
                x = 0;
                y = compositorRoot.screenView.height - slidingPanel.height;
                break;
            default:
                break;
            }
        }

        function resetPosition() {
            if (open)
                setFinalPosition();
            else
                setInitialPosition();
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Themes.Theme.palette.panel.backgroundColor
    }

    function open() {
        if (__priv.open)
            return;

        visible = true;
        __priv.setFinalPosition();
        __priv.open = true;
    }

    function close() {
        if (!__priv.open)
            return;

        __priv.setInitialPosition();
        __priv.open = false;
    }

    function toggle() {
        if (__priv.open)
            close();
        else
            open();
    }
}