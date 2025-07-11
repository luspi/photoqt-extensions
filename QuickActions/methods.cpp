#include "methods.h"
#include <QColor>
#include <QFileInfo>

QString PQEHistogramMethods::name() {
    return "Quick Actions";
}

QString PQEHistogramMethods::description() {
    return "This extension provides various actions that can be accessed with a single click.";
}

QString PQEHistogramMethods::author() {
    return "Lukas Spies";
}

QString PQEHistogramMethods::contact() {
    return "Lukas@photoqt.org";
}

int PQEHistogramMethods::targetAPIVersion() {
    return 1;
}

QSize PQEHistogramMethods::minimumRequiredWindowSize() {
    return QSize(0,0);
}

bool PQEHistogramMethods::isModal() {
    return false;
}

QList<QStringList> PQEHistogramMethods::shortcuts() {
    return {
        {"__quickActions",
         //: Description of shortcut action
         tr("settingsmanager", "Show/Hide quick actions"),
         "Ctrl+Shift+A", "show"}
    };
}

QList<QStringList> PQEHistogramMethods::settings() {
    return {
        {"Items", "list", "rename:://::delete:://::|:://::rotateleft:://::rotateright:://::mirrorhor:://::mirrorver:://::|:://::crop:://::scale:://::|:://::close"}
    };
}

QMap<QString, QList<QStringList> > PQEHistogramMethods::migrateSettings() {
    return {};
}
QMap<QString, QList<QStringList> > PQEHistogramMethods::migrateShortcuts() {
    return {};
}

/****************************************************/

QVariant PQEHistogramMethods::actionWithImage1(QString filepath, QImage &img) {
    return QVariant();
}

QVariant PQEHistogramMethods::actionWithImage2(QString fileapth, QImage &img) {
    return QVariant();
}

QVariant PQEHistogramMethods::action1(QString filepath) {
    return QVariant();
}

QVariant PQEHistogramMethods::action2(QString filepath) {
    return QVariant();
}
