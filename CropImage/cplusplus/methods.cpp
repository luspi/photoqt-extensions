/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/
#include "methods.h"
#include <QFileDialog>

QVariant Methods::actionWithImage(QString filepath, QImage &img, QVariant additional) {
    return false;
}

QVariant Methods::action(QString filepath, QVariant additional) {

    const QVariantList lst = additional.toList();
    const QString formatName = lst.at(0).toString();
    const QStringList formatEndings = lst.at(1).toStringList();

    const QString targetFilename = QFileDialog::getSaveFileName(0, "Save file as", filepath, QString("%1 (*.%2);;All files (*.*)").arg(formatName, formatEndings.join(" *.")));

    return targetFilename;

}
