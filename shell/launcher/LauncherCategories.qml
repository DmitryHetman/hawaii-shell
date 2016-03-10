/****************************************************************************
 * This file is part of Hawaii.
 *
 * Copyright (C) 2014-2016 Pier Luigi Fiorini
 *
 * Author(s):
 *    Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
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
import Fluid.Ui 1.0 as FluidUi
import org.hawaiios.launcher 0.1 as CppLauncher

ListView {
    signal selected(string category)

    id: root
    onCurrentIndexChanged: if (currentItem) root.selected(currentItem.category)

    Component {
        id: categoryDelegate

        Rectangle {
            property string category: model.category
            property bool hover: false

            color: hover ? Themes.Theme.palette.panel.selectedBackgroundColor : "transparent"
            width: Math.max(ListView.view.width, label.paintedWidth + (2 * FluidUi.Units.smallSpacing))
            height: Math.max(icon.height, label.paintedHeight) + (2 * FluidUi.Units.smallSpacing)
            radius: FluidUi.Units.dp(3)

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: hover = true
                onExited: hover = false
                onClicked: root.currentIndex = index
            }

            Row {
                anchors {
                    fill: parent
                    margins: FluidUi.Units.smallSpacing
                }
                spacing: FluidUi.Units.smallSpacing

                FluidUi.Icon {
                    id: icon
                    iconName: model.iconName
                    width: FluidUi.Units.iconSizes.smallMedium
                    height: width
                }

                Text {
                    id: label
                    anchors.verticalCenter: icon.verticalCenter
                    renderType: Text.NativeRendering
                    text: model.display
                    color: hover ? Themes.Theme.palette.panel.selectedTextColor : Themes.Theme.palette.panel.textColor
                    elide: Text.ElideRight
                    font.bold: root.currentIndex == index
                }
            }
        }
    }

    model: CppLauncher.CategoriesModel {
        id: categoriesModel
    }
    delegate: categoryDelegate
}
