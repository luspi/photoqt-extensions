/**************************************************************************
 **                                                                      **
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
#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QImage>
#include "pqc_extensions_api.h"

class PQEHistogramMethods : public QObject, public PQExtensionsAPI {

    Q_OBJECT
    Q_PLUGIN_METADATA(IID PhotoQt_IID)
    Q_INTERFACES(PQExtensionsAPI)

public:
    int requiredAPIVersion() override;
    QList<QStringList> shortcutsActions() override;
    QList<QStringList> settings() override;
    QMap<QString, QList<QStringList> > migrateSettings() override;
    QMap<QString, QList<QStringList> > migrateShortcuts() override;
    QList<QStringList> doAtStartup() override;

    /****************************************************/

    QVariantList doOnFileLoad(QString &filepath, QImage &img) override;
    QVariantList doOnFileUnLoad(QString &filepath) override;

private:
    QMap<QString,QVariantList> histogramCache;

};
