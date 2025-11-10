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
#include <QVariant>
#include <QVariantList>
#include <QImage>
#include "pqc_extensionactions.h"

class Methods : public PQCExtensionActions {

    Q_OBJECT
    Q_PLUGIN_METADATA(IID PhotoQt_IID)
    Q_INTERFACES(PQCExtensionActions)

public:
    QVariant action(QString filepath, QVariant additional = QVariant()) override;
    QVariant actionWithImage(QString filepath, QImage &img, QVariant additional = QVariant()) override;

private:
    QMap<QString,QVariantList> histogramCache;

Q_SIGNALS:
    void sendMessage(QVariant val);

};
