#include "methods.h"
#include <QColor>
#include <QFileInfo>

int PQEHistogramMethods::requiredAPIVersion() {
    return 1;
}

QList<QStringList> PQEHistogramMethods::shortcutsActions() {
    return {
        {"__histogram",
            //: Description of shortcut action
            tr("settingsmanager", "Show/Hide Histogram"),
            "H",
            "show", "histogram"}
    };
}

QList<QStringList> PQEHistogramMethods::settings() {
    return {
        {"HistogramVersion",  "extensions", "string", "color"}
    };
}

QMap<QString, QList<QStringList> > PQEHistogramMethods::migrateSettings() {
    return {
        {"4.9", {{"Visible",         "histogram", "Histogram",         "extensions"},
        {"Position",        "histogram", "HistogramPosition", "extensions"},
        {"Size",            "histogram", "HistogramSize",     "extensions"},
        {"Version",         "histogram", "HistogramVersion",  "extensions"},
        {"",                "histogram", "",                  ""},
        {"PopoutHistogram", "interface", "HistogramPopout",   "extensions"}}}
    };
}
QMap<QString, QList<QStringList> > PQEHistogramMethods::migrateShortcuts() {
    return {};
}

QList<QStringList> PQEHistogramMethods::doAtStartup() {
    return {
        {"Histogram", "setup", "histogram"}
    };
}

/****************************************************/

QVariantList PQEHistogramMethods::doOnFileLoad(QString &filepath, QImage &img) {

    QFileInfo info(filepath);
    QString key = QString("%1%2").arg(filepath).arg(info.lastModified().toMSecsSinceEpoch());
    if(histogramCache.contains(key)) {
        return {filepath, histogramCache[key]};
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

    return {filepath, ret};

}

QVariantList PQEHistogramMethods::doOnFileUnLoad(QString &filepath) {
    return {};
}
