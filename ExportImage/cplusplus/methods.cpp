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
#include <QFileDialog>

#if defined(PQEIMAGEMAGICK) || defined(PQEGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif

QVariant Methods::actionWithImage(QString filepath, QImage &img, QVariant additional) {

    // get some info about this operation
    QVariantList addLst = additional.toList();
    const QString targetFilename = addLst[0].toString();
    const QStringList infoEndings = addLst[1].toString().split(",");
    const int infoQt = addLst[2].toInt();
    const QString infoQtFormatName = addLst[3].toString();
    const int infoImagemagick = addLst[4].toInt();
    const int infoGraphicsmagick = addLst[5].toInt();
    const QString infoImGmMagick = addLst[6].toString();

    // we convert the image to this tmeporary file and then copy it to the right location
    // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
    QString tmpImageFolder = QDir::tempPath() + "/photoqt/";
    QDir dir(tmpImageFolder);
    dir.mkpath(tmpImageFolder);

    QString tmpImagePath = tmpImageFolder + "/temporaryfileforexport" + "." + infoEndings[0];
    if(QFile::exists(tmpImagePath))
        QFile::remove(tmpImagePath);

    // qt might support it
    if(infoQt == 1) {

        QImageWriter writer;

        // if the QImageWriter supports the format then we're good to go
        if(writer.supportedImageFormats().contains(infoQtFormatName)) {

            // ... and then we write it into the new format
            writer.setFileName(tmpImagePath);
            writer.setFormat(infoQtFormatName.toUtf8());

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
    if(infoImagemagick == 1) {
#else
    if(infoGraphicsmagick == 1) {
#endif

        // first check whether ImageMagick/GraphicsMagick supports writing this filetype
        bool canproceed = false;
        try {
            QString magick = infoImGmMagick;
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

                image.magick(infoImGmMagick.toStdString());
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

    const QVariantList lst = additional.toList();
    const QFileInfo info(lst.at(0).toString());
    const QString formatName = lst.at(1).toString();
    const QStringList formatEndings = lst.at(2).toStringList();

    const QString useName = QString("%1/%2.%3").arg(info.absolutePath(), info.baseName(), formatEndings[0]);

    const QString targetFilename = QFileDialog::getSaveFileName(0, "Export file to", useName, QString("%1 (*.%2);;All files (*.*)").arg(formatName, formatEndings.join(" *.")));

    return targetFilename;

}
