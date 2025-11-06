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

#if defined(PQEIMAGEMAGICK) || defined(PQEGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif

QVariant Methods::actionWithImage(QString filepath, QImage &img, QVariant additional) {

    const QString targetFilename = additional.toList()[0].toString();
    const QSize targetSize(additional.toList()[1].toInt(), additional.toList()[2].toInt());
    const int targetQuality = additional.toList()[3].toInt();
    const int writeStatus = additional.toList()[4].toInt();
    const QVariantMap databaseinfo = additional.toList()[5].toMap();

    img = img.scaled(targetSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

#ifdef PQMEXIV2

    // This will store all the exif data
    Exiv2::ExifData exifData;
    Exiv2::IptcData iptcData;
    Exiv2::XmpData xmpData;
    bool gotExifData = false;

  #if EXIV2_TEST_VERSION(0, 28, 0)
    Exiv2::Image::UniquePtr image_read;
  #else
    Exiv2::Image::AutoPtr image_read;
  #endif

    try {

        // Open image for exif reading
  #if EXIV2_TEST_VERSION(0, 28, 0)
        image_read = Exiv2::ImageFactory::open(filepath.toStdString());
  #else
        image_read = Exiv2::ImageFactory::open(filepath.toStdString());
  #endif

        if(image_read.get() != 0) {
            // YAY, WE FOUND SOME!!!!!
            gotExifData = true;
            image_read->readMetadata();
        }

    }

    catch (Exiv2::Error& e) {
        qDebug() << "ERROR reading exif data (caught exception):" << e.what();
    }

    if(gotExifData) {

        // read exif
        exifData = image_read->exifData();
        iptcData = image_read->iptcData();
        xmpData = image_read->xmpData();

        // Update dimensions
        exifData["Exif.Photo.PixelXDimension"] = int32_t(targetSize.width());
        exifData["Exif.Photo.PixelYDimension"] = int32_t(targetSize.height());

    }

#endif

    // We need to do the actual scaling in between reading the exif data above and writing it below,
    // since we might be scaling the image in place and thus would overwrite old exif data
    bool success = false;

    if(writeStatus == 1 || writeStatus == 2) {

        // we don't stop if this fails as we might be able to try again with Magick
        if(img.save(targetFilename, databaseinfo.value("qt_formatname").toString().toStdString().c_str(), targetQuality))
            success = true;
        else
            qWarning() << "Scaling image with Qt failed";

    }

    if(!success && (writeStatus == 1 || writeStatus == 3)) {

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

                // we scale the image to this tmeporary file and then copy it to the right location
                // converting it straight to the right location can lead to corrupted thumbnails if target folder is the same as source folder
                QString tmpImagePath = PQCConfigFiles::get().CACHE_DIR() + "/temporaryfileforscale" + "." + databaseinfo.value("endings").toString().split(",")[0];
                if(QFile::exists(tmpImagePath))
                    QFile::remove(tmpImagePath);

                try {

                    // first we write the QImage to a temporary file
                    // then we load it into magick and write it to the target file

                    // find unique temporary path
                    QString tmppath = PQCConfigFiles::get().CACHE_DIR() + "/converttmp.ppm";
                    if(QFile::exists(tmppath))
                        QFile::remove(tmppath);

                    img.save(tmppath);

                    // load image and write to target file
                    Magick::Image image;
                    image.magick("PPM");
                    image.read(tmppath.toStdString());

                    image.resize(Magick::Geometry(targetSize.width(), targetSize.height()));

                    image.magick(databaseinfo.value("im_gm_magick").toString().toStdString());
                    image.write(tmpImagePath.toStdString());

                    // remove temporary file
                    QFile::remove(tmppath);

                    // copy result to target destination
                    QFile::copy(tmpImagePath, targetFilename);
                    QFile::remove(tmpImagePath);

                    // success!
                    success = true;

                } catch(Magick::Exception &) { }

            }

        }

#endif

    }

    if(!success) {
        return false;
    }

#ifdef PQMEXIV2

    if(gotExifData) {

        try {

            // And write exif data to new image file
    #if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::Image::UniquePtr image_write = Exiv2::ImageFactory::open(targetFilename.toStdString());
    #else
            Exiv2::Image::AutoPtr image_write = Exiv2::ImageFactory::open(targetFilename.toStdString());
    #endif
            image_write->setExifData(exifData);
            image_write->setIptcData(iptcData);
            image_write->setXmpData(xmpData);
            image_write->writeMetadata();

        }

        catch (Exiv2::Error& e) {
            qWarning() << "ERROR writing exif data (caught exception):" << e.what();
        }

    }

#endif

    return true;

}

QVariant Methods::action(QString filepath, QVariant additional) {
    return QVariant();
}
