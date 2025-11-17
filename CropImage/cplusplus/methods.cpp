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

    const QVariantList lst = additional.toList();
    const QString targetFilename = lst.at(0).toString();
    const QVariantMap databaseinfo = lst.at(1).toMap();
    const int writeStatus = lst.at(2).toInt();
    const QPointF topLeft = lst.at(3).toPointF();
    const QPointF botRight = lst.at(4).toPointF();

    if(writeStatus == 0) {
        qWarning() << "ERROR: file not supported for cropping:" << filepath;
        return false;
    }

    QRect rect(img.width()*topLeft.x(), img.height()*topLeft.y(),
                img.width()*(botRight.x()-topLeft.x()), img.height()*(botRight.y()-topLeft.y()));
    QImage croppedImg = img.copy(rect);

    if(writeStatus == 1 || writeStatus == 2) {

        // we don't stop if this fails as we might be able to try again with Magick
        if(croppedImg.save(targetFilename, databaseinfo.value("qt_formatname").toString().toStdString().c_str(), -1))
            return true;
        else
            qWarning() << "Cropping image with Qt failed";

    }

    if(writeStatus == 1 || writeStatus == 3) {

        // imagemagick/graphicsmagick might support it
#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
    #ifdef PQMIMAGEMAGICK
        if(databaseinfo.value("imagemagick").toInt() == 1) {
    #else
        if(databaseinfo.value("graphicsmagick").toInt() == 1) {
    #endif

            // first check whether ImageMagick/GraphicsMagick supports writing this filetype
            bool canproceed = false;
            try {
                QString magick = databaseinfo.value("im_gm_magick").toString();
                Magick::CoderInfo magickCoderInfo(magick.toStdString());
                if(magickCoderInfo.isWritable())
                    canproceed = true;
            } catch(...) {
                // do nothing here
            }

            // yes, it's supported
            if(canproceed) {

                QString tmpDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
                qWarning() << ">>> tmpDir =" << tmpDir;

                // we scale the image to this tmeporary file and then copy it to the right location
                // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                QString tmpImagePath = tmpDir + "/temporaryfileforcrop" + "." + databaseinfo.value("endings").toString().split(",")[0];
                if(QFile::exists(tmpImagePath))
                    QFile::remove(tmpImagePath);

                try {

                    // first we write the QImage to a temporary file
                    // then we load it into magick and write it to the target file

                    // find unique temporary path
                    QString tmppath = tmpDir + "/converttmp.ppm";
                    if(QFile::exists(tmppath))
                        QFile::remove(tmppath);

                    croppedImg.save(tmppath);

                    // load image and write to target file
                    Magick::Image image;
                    image.magick("PPM");
                    image.read(tmppath.toStdString());

                    image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                    image.write(tmpImagePath.toStdString());

                    // remove temporary file
                    QFile::remove(tmppath);

                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);

                    // success!
                    return true;

                } catch(Magick::Exception &) { }

            } else
                qDebug() << "Writing format not supported by Magick";

        }

#endif

    }

    return false;

}

QVariant Methods::action(QString filepath, QVariant additional) {

    const QVariantList lst = additional.toList();
    const QString currentFile = lst.at(0).toString();
    const QString formatName = lst.at(1).toString();
    const QStringList formatEndings = lst.at(2).toStringList();

    const QString targetFilename = QFileDialog::getSaveFileName(0, "Save file as", currentFile, QString("%1 (*.%2);;All files (*.*)").arg(formatName, formatEndings.join(" *.")));

    return targetFilename;

}
