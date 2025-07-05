#pragma once

#include <QObject>

class PQExtensionsAPI {

public:
    virtual ~PQExtensionsAPI() = default;

    virtual int requiredAPIVersion() = 0;

    // initial setup stuff
    virtual QList<QStringList> shortcutsActions() = 0;
    virtual QList<QStringList> settings() = 0;
    virtual QMap<QString, QList<QStringList> > migrateSettings() = 0;
    virtual QMap<QString, QList<QStringList> > migrateShortcuts() = 0;
    virtual QList<QStringList> doAtStartup() = 0;

    /////////////////////////////////////////

    // reaction methods to do stuff
    virtual QVariantList doOnFileLoad(QString &filepath, QImage &img) = 0;
    virtual QVariantList doOnFileUnLoad(QString &filepath) = 0;


};

#define PhotoQt_IID "org.photoqt.PhotoQt"
Q_DECLARE_INTERFACE(PQExtensionsAPI, PhotoQt_IID)
