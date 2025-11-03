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
#include <QProcess>
#include <QApplication>

#if defined(PQEIMAGEMAGICK) || defined(PQEGRAPHICSMAGICK)
#include <Magick++/CoderInfo.h>
#include <Magick++/Exception.h>
#include <Magick++/Image.h>
#endif

// set as wallpaper
QVariant Methods::actionWithImage1(QString filepath, QImage &img, QVariant additional) {
    return QVariant();
}

QVariant Methods::actionWithImage2(QString fileapth, QImage &img, QVariant additional) {
    return QVariant();
}

// do various actions
QVariant Methods::action1(QString filepath, QVariant additional) {

    const QVariantList lst = additional.toList();

    if(lst.length() == 0)
        return QVariant();

    QVariantList ret;

    if(lst.at(0).toString() == "getScreenCount") {
        ret << "screenCount";
        ret << getScreenCount();
    } else if(lst.at(0).toString() == "checkXfce") {
        ret << "xfce";
        ret << checkXfce();
    } else if(lst.at(0).toString() == "GSettings") {
        ret << "gsettings";
        ret << checkGSettings();
    } else if(lst.at(0).toString() == "checkEnlightenment") {
        ret << "enlightenment";
        QList<int> wc = getEnlightenmentWorkspaceCount();
        ret << wc.at(0);
        ret << wc.at(1);
        ret << checkEnlightenmentRemote();
        ret << checkEnlightenmentMsgbus();
    } else if(lst.at(0).toString() == "checkFeh") {
        ret << "feh";
        ret << checkFeh();
    } else if(lst.at(0).toString() == "checkNitrogen") {
        ret << "nitrogen";
        ret << checkNitrogen();
        qWarning() << ">>>>>" << ret;
    }

    return ret;
}

QVariant Methods::action2(QString filepath, QVariant additional) {
    return QVariant();
}

/*****************************/

int Methods::getScreenCount() {
    qDebug() << "";
    return QApplication::screens().count();
}

bool Methods::checkXfce() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("xfconf-query", QStringList() << "--version", out);
    return (out=="");

}

bool Methods::checkIfCommandExists(QString cmd, QStringList args, QString &out) {

    qDebug() << "args: cmd =" << cmd;
    qDebug() << "args: args =" << args.join(",");

    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);
    proc.start(cmd, args);
    proc.waitForFinished(1000);
    out = proc.readAll();
    int ret = proc.exitCode();
    return (ret == 0);

}

bool Methods::checkGSettings() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("gsettings", QStringList() << "--version", out);
    return (out=="");

}

bool Methods::checkEnlightenmentMsgbus() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("enlightenment_remote", QStringList() << "-module-list", out);
    return (out.contains("msgbus -- Enabled") ? 0 : 1);

}

bool Methods::checkEnlightenmentRemote() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("enlightenment_remote", QStringList() << "-h", out);
    return (out=="");

}

QList<int> Methods::getEnlightenmentWorkspaceCount() {

    qDebug() << "";

    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);

    proc.start("enlightenment_remote", QStringList() << "-desktops-get");
    while(proc.waitForFinished()) {}

    QString out = proc.readAll();
    int ret= proc.exitCode();

    if(ret != 0) {
        qWarning() << "ERROR: enlightenment_remote failed with return code" << ret << "- is Enlightenment installed and the DBUS module activated?";
        return {1,1};
    }

    QStringList parts = out.trimmed().split(" ");
    if(parts.length() != 2) {
        qWarning() << "ERROR: Failed to get proper workspace count! Falling back to default (1x1)";
        return {1,1};
    }

    return {parts.at(0).toInt(), parts.at(1).toInt()};

}

bool Methods::checkFeh() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("feh", QStringList() << "--version", out);
    return (out=="");

}

bool Methods::checkNitrogen() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("nitrogen", QStringList() << "--version", out);
    return (out=="");

}
