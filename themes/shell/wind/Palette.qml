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

Themes.Palette {
    window: Themes.PaletteValues {
        textColor: "#f1f1f1"
        textEffectColor: "#000000"
        backgroundColor: "#3e4243"
        selectedTextColor: textColor
        selectedTextEffectColor: textEffectColor
        selectedBackgroundColor: backgroundColor
        primaryColor: "#6f7678"
        secondaryColor: "#494c4d"
    }
    view: Themes.PaletteValues {
        textColor: "#000000"
        textEffectColor: "#ffffff"
        backgroundColor: "#f1f1f1"
        selectedTextColor: "#ffffff"
        selectedTextEffectColor: "#000000"
        selectedBackgroundColor: "#5cb7d7"
        primaryColor: "#cdcdcd"
        secondaryColor: "#ececec"
    }
    panel: Themes.PaletteValues {
        textColor: "#ffffff"
        textEffectColor: "#000000"
        backgroundColor: "#31363b"
        selectedTextColor: "#ffffff"
        selectedTextEffectColor: "#000000"
        selectedBackgroundColor: "mediumturquoise"
        primaryColor: "#464e57"
        secondaryColor: "#67717a"
    }
}
