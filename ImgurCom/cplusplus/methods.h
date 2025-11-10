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
#include <QNetworkReply>
#include <QBasicTimer>
#include <QTimerEvent>
#include <QSqlDatabase>
#include "pqc_extensionactions.h"

class QNetworkAccessManager;
class QFile;

class PQCHTTPReplyTimeout : public QObject {
    Q_OBJECT
    QBasicTimer m_timer;
public:
    PQCHTTPReplyTimeout(QNetworkReply* reply, const int timeout) : QObject(reply) {
        Q_ASSERT(reply);
        if (reply && reply->isRunning())
            m_timer.start(timeout, this);
    }
    static void set(QNetworkReply* reply, const int timeout) {
        new PQCHTTPReplyTimeout(reply, timeout);
    }
protected:
    void timerEvent(QTimerEvent * ev) {
        if (!m_timer.isActive() || ev->timerId() != m_timer.timerId())
            return;
        auto reply = static_cast<QNetworkReply*>(parent());
        if (reply->isRunning())
            reply->close();
        m_timer.stop();
    }
};

class Methods : public PQCExtensionActions {

    Q_OBJECT
    Q_PLUGIN_METADATA(IID PhotoQt_IID)
    Q_INTERFACES(PQCExtensionActions)

public:
    QVariant action(QString filepath, QVariant additional = QVariant()) override;
    QVariant actionWithImage(QString filepath, QImage &img, QVariant additional = QVariant()) override;

private:
    bool checkIfConnectedToInternet();

    QSqlDatabase db;
    void setupDatabase();

    QString uploadImage(QString filepath);
    QString obtainClientIdSecret();

    QNetworkAccessManager *m_networkManager = nullptr;

    QString extensionConfigLocation;
    QString extensionCacheLocation;

    // Store the access stuff
    QString access_token;
    QString refresh_token;
    QString account_name;
    QString auth_datetime;

    QString imgurClientID;
    QString imgurClientSecret;

private Q_SLOTS:
    // receive feedback from the upload/connecting handler
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void uploadError(QNetworkReply::NetworkError err);
    void uploadFinished();

Q_SIGNALS:
    void sendMessage(QVariant val);
    void abortUpload();

};
