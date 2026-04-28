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
#include <QDir>
#if (QT_VERSION < QT_VERSION_CHECK(6, 8, 0))
#include <QDirIterator>
#endif

QVariant Methods::actionWithImage(QString filepath, QImage &img, QVariant additional) {
    return "";
}

QVariant Methods::action(QString filepath, QVariant additional) {

    const QVariantList lst = additional.toList();

    const QString what = lst.at(0).toString();

    if(what == "selectFolder") {

        const QString rootfolder = lst.at(1).toString();

        const QString folder = QFileDialog::getExistingDirectory(nullptr, "Select folder", (rootfolder != "" ? rootfolder : (filepath == "" ? QDir::homePath() : QFileInfo(filepath).absolutePath())));
        const QVariantList ret = {folder, QFileInfo(folder).fileName()};
        return ret;

    } else if(what == "foldername") {

        return QFileInfo(lst.at(1).toString()).fileName();

    } else if(what == "getHomeFolder") {

        const QVariantList lst = {QDir::homePath(), QDir::home().dirName()};
        return lst;

    } else if(what == "loadFiles") {

        const QString folder = lst.at(1).toString();

        QStringList allfiles;

#if (QT_VERSION >= QT_VERSION_CHECK(6, 8, 0))
        for(const auto &dirEntry : QDirListing(folder, QDirListing::IteratorFlag::Recursive|QDirListing::IteratorFlag::FilesOnly)) {
            allfiles << dirEntry.filePath();
        }
#else
        QDirIterator it(folder, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString dir = it.next();
            if(QFileInfo(dir).isFile()) {
                allfiles << dir;
            }
        }
#endif
        return allfiles;

    }

    return "";

}
