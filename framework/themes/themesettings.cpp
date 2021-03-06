/****************************************************************************
 * This file is part of Hawaii.
 *
 * Copyright (C) 2012-2016 Pier Luigi Fiorini
 *
 * Author(s):
 *    Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *
 * $BEGIN_LICENSE:LGPL2.1+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 ***************************************************************************/

#include <QtCore/QDir>
#include <QtCore/QStandardPaths>

#include "themesettings.h"
#include "cmakedirs.h"

ThemeSettings::ThemeSettings(QObject *parent)
    : QObject(parent)
{
}

QString ThemeSettings::name() const
{
    return QStringLiteral("Wind");
}

QString ThemeSettings::path() const
{
    // TODO: Read style from settings
    QString theme = name();

    // Return style only if it exists
    QStringList paths =
            QStandardPaths::locateAll(QStandardPaths::GenericDataLocation,
                                      QStringLiteral("hawaii/themes/") + theme,
                                      QStandardPaths::LocateDirectory);
    for (const QString &path: paths) {
        QDir dir(path);
        if (dir.exists())
            return path;
    }

    return QString();
}

#include "moc_themesettings.cpp"
