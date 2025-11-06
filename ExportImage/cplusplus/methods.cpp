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
#include <QColor>
#include <QFileInfo>
#include <QDir>
#include <QImageWriter>

#if defined(PQEIMAGEMAGICK) || defined(PQEGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif

QVariant Methods::actionWithImage(QString filepath, QImage &img, QVariant additional) {

    // get info about new file format and source file
    QString targetFilename = additional.toList()[0].toString();
    QVariantMap databaseinfo = additional.toList()[1].toMap();

    // we convert the image to this tmeporary file and then copy it to the right location
    // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
    QString tmpImageFolder = QDir::tempPath() + "/photoqt/";
    QDir dir(tmpImageFolder);
    dir.mkpath(tmpImageFolder);

    QString tmpImagePath = tmpImageFolder + "/temporaryfileforexport" + "." + databaseinfo.value("endings").toString().split(",")[0];
    if(QFile::exists(tmpImagePath))
        QFile::remove(tmpImagePath);

    // qt might support it
    if(databaseinfo.value("qt").toInt() == 1) {

        QImageWriter writer;

        // if the QImageWriter supports the format then we're good to go
        if(writer.supportedImageFormats().contains(databaseinfo.value("qt_formatname").toString())) {

            // ... and then we write it into the new format
            writer.setFileName(tmpImagePath);
            writer.setFormat(databaseinfo.value("qt_formatname").toString().toUtf8());

            // if the actual writing succeeds we're done now
            if(!writer.write(img))
                qWarning() << "ERROR:" << writer.errorString();
            else {
                // copy result to target destination
                QFile::copy(tmpImagePath, targetFilename);
                QFile::remove(tmpImagePath);
                return true;
            }

        }

    }

    // imagemagick/graphicsmagick might support it
#if defined(PQEIMAGEMAGICK) || defined(PQEGRAPHICSMAGICK)
#ifdef PQEIMAGEMAGICK
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

            try {

                // first we write the QImage to a temporary file
                // then we load it into magick and write it to the target file

                // find unique temporary path
                QString tmppath = QDir::tempPath() + "/photoqt/converttmp.ppm";
                if(QFile::exists(tmppath))
                    QFile::remove(tmppath);

                img.save(tmppath);

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

        }

    }

    #endif

    return false;

}

QVariant Methods::action(QString filepath, QVariant additional) {
    return QVariant();
}
