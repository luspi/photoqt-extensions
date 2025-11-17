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

#include <QNetworkAccessManager>
#include <QNetworkInterface>
#include <QRegularExpression>
#include <QSqlError>
#include <QSqlQuery>
#include <QFileInfo>
#include <QTimer>
#include <QBuffer>
#include <QStandardPaths>
#include <QEventLoop>
#include <QApplication>
#include <QClipboard>

QVariant Methods::actionWithImage(QString filepath, QImage &img, QVariant additional) {

    const QVariantList lst = additional.toList();

    if(lst.length() == 0) return false;

    qDebug() << "args: filepath =" << filepath;
    qDebug() << "args: additional =" << lst;

    const QString what = lst.at(0).toString();

    if(what == "saveToHistory") {

        const QString imageUrl = lst.at(1).toString();
        const QString deleteHash = lst.at(2).toString();

        img = img.scaled(256, 256, Qt::KeepAspectRatio);

        QByteArray thumb_data;
        QBuffer thumb_buffer(&thumb_data);
        thumb_buffer.open(QIODevice::WriteOnly);
        img.save(&thumb_buffer, "PNG");

        if(!db.isValid()) setupDatabase();

        if(!db.isOpen() && !db.open())
            return QVariant();

        QSqlQuery query(db);
        query.prepare("INSERT INTO `history` (`timestamp`, `thumbnail`, `imageurl`, `deletehash`) VALUES (:timestamp, :thumbnail, :imageurl, :deletehash)");
        query.bindValue(":timestamp", QDateTime::currentMSecsSinceEpoch());
        query.bindValue(":thumbnail", thumb_data);
        query.bindValue(":imageurl", imageUrl);
        query.bindValue(":deletehash", deleteHash);

        if(!query.exec())
            qWarning() << "SQL error caching imgur.com upload:" << query.lastError().text();

        query.clear();

    }

    return QVariant();
}

QVariant Methods::action(QString filepath, QVariant additional) {

    const QVariantList lst = additional.toList();

    if(lst.length() == 0) return false;

    qDebug() << "args: filepath =" << filepath;
    qDebug() << "args: additional =" << lst;

    const QString what = lst.at(0).toString();

    if(what == "start") {

        if(m_networkManager == nullptr)
            m_networkManager = new QNetworkAccessManager;

        extensionConfigLocation = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        extensionCacheLocation = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);

        access_token = lst.at(1).toString();
        refresh_token = lst.at(2).toString();
        account_name = lst.at(3).toString();
        auth_datetime = lst.at(4).toString();

        if(!checkIfConnectedToInternet()) {
            return "nointernet";
        }

        if(imgurClientID == "" || imgurClientSecret == "") {
            QString ret = obtainClientIdSecret();
            if(ret != "")
                return ret;
        }

        QString ret = uploadImage(filepath);
        if(ret != "")
            return QVariantList() << "setupError" << ret;

        return QVariantList() << "uploading";

    } else if(what == "getPastUploads") {

        QVariantList ret;
        ret << "pastUploads";

        if(!db.isValid()) setupDatabase();

        if(!db.isOpen() && !db.open())
            return ret;

        QSqlQuery query(db);
        if(!query.exec("SELECT `timestamp`,`thumbnail`,`imageurl`,`deletehash` FROM `history` ORDER BY `timestamp` DESC")) {
            qWarning() << "SQL error:" << db.lastError().text();
            return ret;
        }

        QVariantList dat;

        while(query.next()) {

            const qint64 ms = query.value(0).toLongLong();
            const QVariant imageUrl = query.value(2);
            const QVariant deleteHash = query.value(3);

            QImage thumb = QImage::fromData(query.value(1).toByteArray());
            const QString thumbPath = extensionCacheLocation + "/" + deleteHash.toString() + ".jpg";
            thumb.save(thumbPath);

            QDateTime dt;
            dt.setMSecsSinceEpoch(ms);

            QVariantList entry;
            entry << ms;
            entry << QLocale::system().toString(dt);
            entry << imageUrl;
            entry << deleteHash;
            entry << thumbPath;

            dat.push_back(entry);

        }

        ret.push_back(dat);

        query.clear();

        return ret;

    } else if(what == "deletePastUploadEntry") {

        if(!db.isOpen() && !db.open())
            return QVariant();

        const QString timestamp = lst.at(1).toString();

        // delete all
        if(timestamp == "xxx") {

            QSqlQuery query(db);
            query.prepare("DELETE FROM `history`");
            if(!query.exec()) {
                qWarning() << "SQL error:" << db.lastError().text();
                return QVariant();
            }

        } else {

            QSqlQuery query(db);
            query.prepare("DELETE FROM `history` WHERE `timestamp`=:timestamp");
            query.bindValue(":timestamp", timestamp);
            if(!query.exec()) {
                qWarning() << "SQL error:" << db.lastError().text();
                return QVariant();
            }

        }

        return QVariantList() << "deletedPastEntry";

    } else if(what == "interruptUpload") {

        Q_EMIT abortUpload();

    } else if(what == "getAuthorizeUrlForPin") {

        if(m_networkManager == nullptr)
            m_networkManager = new QNetworkAccessManager;

        if(imgurClientID == "" || imgurClientSecret == "") {
            QString ret = obtainClientIdSecret();
            if(ret != "")
                return "failed to obtain URL";
        }

        // return authorisation url
        return QVariantList() << "authorizeUrlForPin" << QString("https://api.imgur.com/oauth2/authorize?client_id=%1&response_type=pin&state=requestaccess").arg(imgurClientID);

    } else if(what == "forgetAccount") {

        // TODO: accountForgotten

    } else if(what == "doAuthorizeHandlePin") {

        // TODO: authorizeHandlePin, ret, accountname
    } else if(what == "copyTextToClipboard") {

        qApp->clipboard()->setText(lst.at(1).toString(), QClipboard::Clipboard);

    }

    return false;
}

bool Methods::checkIfConnectedToInternet() {

    qDebug() << "checkIfConnectedToInternet()";

    // will store the return value
    bool internetConnected = false;

    // Get a list of all network interfaces
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();

    // a reg exp to validate an ip address
    static QRegularExpression ipRegExp("[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}");

    // loop over all network interfaces
    for(int i = 0; i < ifaces.count(); i++) {

        // get the current network interface
        QNetworkInterface iface = ifaces.at(i);

        // if the interface is up and not a loop back interface
        if(iface.flags().testFlag(QNetworkInterface::IsUp)
            && !iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {

            // loop over all possible ip addresses
            for (int j=0; j<iface.allAddresses().count(); j++) {

                // get the ip address
                QString ip = iface.allAddresses().at(j).toString();

                // validate the ip. We have to double check 127.0.0.1 as isLoopBack above does not always work reliably
                if(ip != "127.0.0.1" && ipRegExp.match(ip).hasMatch()) {
                    internetConnected = true;
                    break;
                }
            }

            }

            // done
            if(internetConnected) break;

    }

    // return whether we're connected or not
    return internetConnected;

}

QString Methods::uploadImage(QString filename) {

    qDebug() << "uploadImage()";
    qDebug() << "args: filename =" << filename;

    // Ensure that filename is not empty and that the file exists
    if(filename.trimmed() == "" || !QFileInfo::exists(filename))
        return "IMGUR_FILENAME_ERROR";

    // Initiate file and open for reading
    QFile *file = new QFile(filename);
    if(!file->open(QIODevice::ReadOnly))
        return "IMGUR_FILE_OPEN_ERROR";

    // Setup network request (XML format)
    QNetworkRequest request(QUrl("https://api.imgur.com/3/image.xml"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/application/x-www-form-urlencoded");
    request.setRawHeader("Authorization", QString("Client-ID " + imgurClientID).toLatin1());

    // Send upload request and connect to feedback signals
    QNetworkReply *reply = m_networkManager->post(request, file);
    file->setParent(m_networkManager);
    connect(reply, &QNetworkReply::finished, this, &Methods::uploadFinished);
    connect(reply, &QNetworkReply::uploadProgress, this, &Methods::uploadProgress);
    connect(reply, &QNetworkReply::errorOccurred, this, &Methods::uploadError);
    connect(this, &Methods::abortUpload, reply, &QNetworkReply::abort);

    // Phew, no error occurred!
    return "";

}

// Read client id and secret from server
QString Methods::obtainClientIdSecret() {

    qDebug() << "obtainClientIdSecret()";

    // If we have done it already, no need to do it again
    if(imgurClientID != "" && imgurClientSecret != "")
        return "";

    // Request text file from server
    QNetworkRequest req(QUrl("https://photoqt.org/appaccess/oauth2imgur.php"));
    req.setRawHeader("Referer", "PhotoQt");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QNetworkReply *reply =  m_networkManager->get(req);
    PQCHTTPReplyTimeout::set(reply, 2500);

    // Synchronous connect
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    // Read reply data
    QString dat = reply->readAll();
    reply->deleteLater();

    // If response invalid
    if(dat.trimmed() == "")
        return "IMGUR_NOT_CONNECTED_TO_INET";
    else if(!dat.contains("client_id=") || !dat.contains("client_secret="))
        return "IMGUR_NETWORK_REPLY_ERROR";

    // Split client id and secret out of reply data
    imgurClientID = dat.split("client_id=").at(1).split("\n").at(0).trimmed();
    imgurClientSecret = dat.split("client_secret=").at(1).split("\n").at(0).trimmed();

    // success
    return "";

}

// Handle upload progress
void Methods::uploadProgress(qint64 bytesSent, qint64 bytesTotal) {

    qDebug() << "uploadProgress()";
    qDebug() << "args: bytesSent =" << bytesSent;
    qDebug() << "args: bytesTotal =" << bytesTotal;

    // Avoid division by zero
    if(bytesTotal == 0)
        return;

    // Compute and emit progress, between 0 and 1
    double progress = (double)bytesSent/(double)bytesTotal;
    Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "progress" << progress);

}

// An error occurred
void Methods::uploadError(QNetworkReply::NetworkError err) {

    qDebug() << "uploadError()";
    qDebug() << "args: err =" << err;

    // Access sender object and delete it
    QNetworkReply *reply = (QNetworkReply*)(sender());
    reply->deleteLater();

    // This is an error, but caused by the user (by calling abort())
    if(err == QNetworkReply::OperationCanceledError)
        return;

    // Compose, output, and emit error message
    Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "uploadError" << err);

}

// Finished uploading an image
void Methods::uploadFinished() {

    qDebug() << "uploadFinished()";

    // The sending network reply
    QNetworkReply *reply = (QNetworkReply*)(sender());

    // The reply is not open when operation was aborted
    if(!reply->isOpen()) {
        Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "url" << "");
        Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "uploadFinished");
        return;
    }

    // Read output from finished network reply
    QString resp = reply->readAll();

    // Delete sender object
    reply->deleteLater();

    // If there has been an error...
    if(resp.contains("success=\"0\"")) {
        Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "uploadFinished");
        return;
    }

    // If data doesn't contain a valid link, something went wrong
    if(!resp.contains("<link>") || !resp.contains("<deletehash>")) {
        Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "uploadFinished");
        return;
    }

    // Read out the link
    QString imgLink = resp.split("<link>").at(1).split("</link>").at(0);
    QString delHash = resp.split("<deletehash>").at(1).split("</deletehash>").at(0);
    qDebug() << "URL:" << imgLink;
    qDebug() << "Delete hash:" << delHash;
    // and tell the user
    Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "url" << imgLink);
    Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "deleteHash" << delHash);
    Q_EMIT PQCExtensionActions::sendMessage(QVariantList() << "uploadFinished");

}

void Methods::setupDatabase() {

    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "imgurhistory");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "imgurhistory");

    const QString dbpath = extensionConfigLocation + "/imgurhistory.db";

    if(!QFileInfo::exists(dbpath)) {
        if(!QFile::copy(":/imgurhistory.db", dbpath))
            qWarning() << "Unable to create default imgurhistory database";
        else {
            QFile file(dbpath);
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    db.setDatabaseName(dbpath);

}
