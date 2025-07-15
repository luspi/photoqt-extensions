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

QVariant Methods::actionWithImage1(QString filepath, QImage &img, QVariant additional) {

    QFileInfo info(filepath);
    QString key = QString("%1%2").arg(filepath).arg(info.lastModified().toMSecsSinceEpoch());
    if(histogramCache.contains(key)) {
        return QVariant::fromValue<QVariantList>({filepath, histogramCache[key]});
    }

    QVariantList ret;

    if(filepath == "" || !info.exists()) {
        return {""};
    }

    // first we need to retrieve the current image
    if(img.size().isNull() || img.size().isEmpty()) {
        return {""};
    }

    if(img.format() != QImage::Format_RGB32)
        img.convertTo(QImage::Format_RGB32);

    // we first count using integers for faster adding up
    QList<int> red(256);
    QList<int> green(256);
    QList<int> blue(256);

    // Loop over all rows of the image
    for(int i = 0; i < img.height(); ++i) {

        // Get the pixel data of row i of the image
        QRgb *rowData = (QRgb*)img.scanLine(i);

        // Loop over all columns
        for(int j = 0; j < img.width(); ++j) {

            // Get pixel data of pixel at column j in row i
            QRgb pixelData = rowData[j];

            // store color data
            ++red[qRed(pixelData)];
            ++green[qGreen(pixelData)];
            ++blue[qBlue(pixelData)];

        }

    }

    // we compute the grey values once we red all rgb pixels
    // this is much faster than calculate the grey values for each pixel
    QList<int> grey(256);
    for(int i = 0; i < 256; ++i)
        grey[i] = red[i]*0.34375 + green[i]*0.5 + blue[i]*0.15625;

    // find the max values for normalization
    double max_red = *std::max_element(red.begin(), red.end());
    double max_green = *std::max_element(green.begin(), green.end());
    double max_blue = *std::max_element(blue.begin(), blue.end());
    double max_grey = *std::max_element(grey.begin(), grey.end());
    double max_rgb = qMax(max_red, qMax(max_green, max_blue));

    // the return lists, normalized
    QList<float> ret_red(256);
    QList<float> ret_green(256);
    QList<float> ret_blue(256);
    QList<float> ret_gray(256);

    // normalize values
    std::transform(red.begin(), red.end(), ret_red.begin(), [=](float val) { return val/max_rgb; });
    std::transform(green.begin(), green.end(), ret_green.begin(), [=](float val) { return val/max_rgb; });
    std::transform(blue.begin(), blue.end(), ret_blue.begin(), [=](float val) { return val/max_rgb; });
    std::transform(grey.begin(), grey.end(), ret_gray.begin(), [=](float val) { return val/max_grey; });

    // store values
    ret << QVariant::fromValue(ret_red);
    ret << QVariant::fromValue(ret_green);
    ret << QVariant::fromValue(ret_blue);
    ret << QVariant::fromValue(ret_gray);

    histogramCache.insert(key, ret);

    QVariantList repl = {filepath, ret};
    return repl;

}

QVariant Methods::actionWithImage2(QString fileapth, QImage &img, QVariant additional) {
    return QVariant();
}

QVariant Methods::action1(QString filepath, QVariant additional) {
    return QVariant();
}

QVariant Methods::action2(QString filepath, QVariant additional) {
    return QVariant();
}
