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

import QtQuick
import QtQuick.Controls

import PQCExtensionsHandler
import PhotoQt
import "./wallpaperparts"

PQTemplateExtension {

    id: wallpaper_top

    modalButton2Text: "Set as wallpaper"

    property list<string> categories: ["plasma", "gnome", "xfce", "enlightenment", "other"]
    property int curCat: PQCScriptsConfig.amIOnWindows() ? categories.length : 0
    property int numDesktops: 0

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    content: [

        Flickable {

            id: flickable

            y: (parent.height-height)/2
            width: parent.width
            height: Math.min(parent.height, contentHeight)
            clip: true

            contentHeight: insidecont.height+20

            ScrollBar.vertical: PQVerticalScrollBar { }

            Row {

                id: insidecont

                x: ((parent.width-width)/2)
                y: 10

                width: Math.min(parent.width, 800)

                spacing: 10

                Item {
                    id: category
                    x: 0
                    y: 0
                    width: visible ? parent.width*0.375 : 0
                    height: Math.min(600, wallpaper_top.height*0.8)

                    visible: !PQCScriptsConfig.amIOnWindows()

                    Item {
                        width: parent.width
                        height: childrenRect.height
                        anchors.centerIn: parent
                        Column {
                            spacing: 20
                            PQTextL {
                                width: category.width
                                horizontalAlignment: Text.AlignHCenter
                                color: wallpaper_top.curCat==0 ? pqtPalette.text : pqtPaletteDisabled.text
                                font.weight: PQCLook.fontWeightBold
                                text: "Plasma"
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                    text: qsTranslate("wallpaper", "Click to choose %1").arg("Plasma")
                                    onClicked:
                                    wallpaper_top.curCat = 0
                                }
                            }
                            PQTextL {
                                width: category.width
                                horizontalAlignment: Text.AlignHCenter
                                color: wallpaper_top.curCat==1 ? pqtPalette.text : pqtPaletteDisabled.text
                                font.weight: PQCLook.fontWeightBold
                                text: "Gnome<br>Unity<br>Cinnamon"
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                    text: qsTranslate("wallpaper", "Click to choose %1").arg("Gnome/Unity/Cinnamon")
                                    onClicked:
                                    wallpaper_top.curCat = 1
                                }
                            }
                            PQTextL {
                                width: category.width
                                horizontalAlignment: Text.AlignHCenter
                                color: wallpaper_top.curCat==2 ? pqtPalette.text : pqtPaletteDisabled.text
                                font.weight: PQCLook.fontWeightBold
                                text: "XFCE4"
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                    text: qsTranslate("wallpaper", "Click to choose %1").arg("XFCE4")
                                    onClicked:
                                    wallpaper_top.curCat = 2
                                }
                            }
                            PQTextL {
                                width: category.width
                                horizontalAlignment: Text.AlignHCenter
                                color: wallpaper_top.curCat==3 ? pqtPalette.text : pqtPaletteDisabled.text
                                font.weight: PQCLook.fontWeightBold
                                text: "Enlightenment"
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                    text: qsTranslate("wallpaper", "Click to choose %1").arg("Enlightenment")
                                    onClicked:
                                    wallpaper_top.curCat = 3
                                }
                            }
                            PQTextL {
                                width: category.width
                                horizontalAlignment: Text.AlignHCenter
                                color: wallpaper_top.curCat==4 ? pqtPalette.text : pqtPaletteDisabled.text
                                font.weight: PQCLook.fontWeightBold
                                text: "Other"
                                PQMouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    //: %1 is a placeholder for the name of a desktop environment (plasma, xfce, gnome, etc.)
                                    text: qsTranslate("wallpaper", "Click to choose %1")
                                    //: Used as in: Other Desktop Environment
                                    .arg(qsTranslate("wallpaper", "Other"))
                                    onClicked:
                                    wallpaper_top.curCat = 4
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                        }
                        width: 1
                        color: "#cccccc"
                    }

                }

                Flickable {

                    x: category.width
                    y: (parent.height-height)/2
                    width: parent.width-category.width-10
                    height: Math.min(600, contentHeight)

                    ScrollBar.vertical: PQVerticalScrollBar { }

                    contentHeight: (wallpaper_top.curCat==0 ?
                                    plasma.height :
                                     (wallpaper_top.curCat==1 ?
                                      gnome.height :
                                       (wallpaper_top.curCat==2 ?
                                        xfce.height :
                                         (wallpaper_top.curCat==3 ?
                                          enlightenment.height :
                                           (wallpaper_top.curCat==4 ?
                                            other.height :
                                              windows.height)))))

                    clip: true

                    PQPlasma {
                        id: plasma
                        numDesktops: wallpaper_top.numDesktops
                        extensionId: wallpaper_top.extensionId
                        visible: wallpaper_top.curCat==0
                    }

                    PQGnome {
                        id: gnome
                        numDesktops: wallpaper_top.numDesktops
                        extensionId: wallpaper_top.extensionId
                        visible: wallpaper_top.curCat==1
                    }

                    PQXfce {
                        id: xfce
                        numDesktops: wallpaper_top.numDesktops
                        extensionId: wallpaper_top.extensionId
                        visible: wallpaper_top.curCat==2
                    }

                    PQEnlightenment {
                        id: enlightenment
                        numDesktops: wallpaper_top.numDesktops
                        extensionId: wallpaper_top.extensionId
                        visible: wallpaper_top.curCat==3
                    }

                    PQOther {
                        id: other
                        numDesktops: wallpaper_top.numDesktops
                        extensionId: wallpaper_top.extensionId
                        visible: wallpaper_top.curCat==4
                    }

                    PQWindows {
                        id: windows
                        numDesktops: wallpaper_top.numDesktops
                        extensionId: wallpaper_top.extensionId
                        visible: wallpaper_top.curCat==5
                    }

                }

            }

        }

    ]

    function modalButton2Action() {
        setWallpaper()
    }

    function setWallpaper() {

        var args = {}

        if(curCat == 0) {

            if(plasma.checkedScreens.length === 0)
                return

            args["category"] = "plasma"
            args["screens"] = plasma.checkedScreens

        } else if(curCat == 1) {

            args["category"] = "gnome"
            args["option"] = gnome.checkedOption

        } else if(curCat == 2) {

            if(xfce.checkedScreens.length === 0)
                return

            args["category"] = "xfce"
            args["screens"] = xfce.checkedScreens
            args["option"] = xfce.checkedOption

        } else if(curCat == 3) {

            if(enlightenment.checkedScreens.length === 0 || enlightenment.checkedWorkspaces.length === 0)
                return

            args["category"] = "enlightenment"
            args["screens"] = enlightenment.checkedScreens
            args["workspaces"] = enlightenment.checkedWorkspaces

        } else if(curCat == 4) {

            args["category"] = "other"
            args["app"] = other.checkedTool
            args["option"] = other.checkedOption

        } else if(curCat == 5) {

            args["category"] = "windows"
            args["WallpaperStyle"] = windows.checkedOption

        }

        console.warn(">>> SET:", extensionId, args)
        PQCExtensionsHandler.requestCallActionWithImage(extensionId, args)

        hide()
    }

    function showing() {
        PQCExtensionsHandler.requestCallAction(extensionId, ["checkWallpaper"])
    }

    Connections {

        target: PQCExtensionsHandler

        function onReceivedShortcut(combo : string) {

            if(!wallpaper_top.visible) return

            if(combo === "Enter" || combo === "Return") {

                wallpaper_top.setWallpaper()

            } else if(combo === "Ctrl+Down") {

                if(PQCScriptsConfig.amIOnWindows()) return

                    wallpaper_top.curCat = (wallpaper_top.curCat+1)%wallpaper_top.categories.length

            } else if(combo === "Ctrl+Up") {

                if(PQCScriptsConfig.amIOnWindows()) return

                wallpaper_top.curCat = (wallpaper_top.curCat+wallpaper_top.categories.length-1)%wallpaper_top.categories.length

            } else if(combo === "Right" || combo === "Left") {

                if(wallpaper_top.categories[wallpaper_top.curCat] === "other")
                    other.changeTool()

            }

        }

        function onReplyForAction(id, val) {

            if(id !== wallpaper_top.extensionId && val !== undefined)
                return

            if(val.length < 10 || val[0] !== "wallpaper")
                return

            wallpaper_top.numDesktops = val[1]
            xfce.xfconfQueryError = val[2]
            gnome.gsettingsError = val[3]
            enlightenment.numWorkspaces = [val[4], val[5]]
            enlightenment.enlightenmentRemoteError = val[6]
            enlightenment.msgbusError = val[7]
            other.fehError = val[8]
            other.nitrogenError = val[9]

        }

    }

}
