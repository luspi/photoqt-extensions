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
import QtCharts

import PQCExtensionsHandler
import PhotoQt

PQTemplateExtension {

    id: quickactions_top

    property list<string> buttons: settings["Items"]

    property int mouseOverIndex: -1
    property bool mouseOver: false
    Timer {
        id: resetMouseOver
        property int leftIndex
        interval: 200
        onTriggered: {
            if(leftIndex === quickactions_top.mouseOverIndex)
                quickactions_top.mouseOver = false
        }
    }

    opacity: (mouseOver || mouseBG.containsMouse || settings["ExtPopout"]) ? 1 : 0.1
    Behavior on opacity { NumberAnimation { duration: 200 } }

    // 4 values: tooltip, icon name, shortcut action, enabled with no file loaded
    property var mappings: {
        "|" : ["|", "|", "|", "|"],
        "rename" :      [qsTranslate("quickactions", "Rename file"),                     "rename",         "__rename",      false],
        "copy"   :      [qsTranslate("quickactions", "Copy file"),                       "copy",           "__copy",        false],
        "move"   :      [qsTranslate("quickactions", "Move file"),                       "move",           "__move",        false],
        "delete" :      [qsTranslate("quickactions", "Delete file (with confirmation)"), "delete",         "__delete",      false],
        "deletetrash" : [qsTranslate("quickactions", "Move file directly to trash"),     "delete",         "__deleteTrash", false],
        "rotateleft" :  [qsTranslate("quickactions", "Rotate left"),                     "rotateleft",     "__rotateL",     false],
        "rotateright" : [qsTranslate("quickactions", "Rotate right"),                    "rotateright",    "__rotateR",     false],
        "mirrorhor" :   [qsTranslate("quickactions", "Mirror horizontally"),             "leftrightarrow", "__flipH",       false],
        "mirrorver" :   [qsTranslate("quickactions", "Mirror vertically"),               "updownarrow",    "__flipV",       false],
        "crop" :        [qsTranslate("quickactions", "Crop image"),                      "crop",           "__crop",        false],
        "scale" :       [qsTranslate("quickactions", "Scale image"),                     "scale",          "__scale",       false],
        "tagfaces" :    [qsTranslate("quickactions", "Tag faces"),                       "faces",          "__tagFaces",    false],
        "clipboard" :   [qsTranslate("quickactions", "Copy to clipboard"),               "clipboard",      "__clipboard",   false],
        "export" :      [qsTranslate("quickactions", "Export to different format"),      "convert",        "__export",      false],
        "wallpaper" :   [qsTranslate("quickactions", "Set as wallpaper"),                "wallpaper",      "__wallpaper",   false],
        "qr" :          [(PQCConstants.barcodeDisplayed ?
        qsTranslate("quickactions", "Hide QR/barcodes") :
        qsTranslate("quickactions", "Detect QR/barcodes")),   "qrcode",         "__detectBarCodes", false],
        "close" :       [qsTranslate("quickactions", "Close window"),               "quit",           "__close",          true],
        "quit" :        [qsTranslate("quickactions", "Quit"),                       "quit",           "__quit",           true],
    }

    property list<string> mapkeys: ["|", "rename", "copy", "move", "delete", "rotateleft",
    "rotateright", "mirrorhor", "mirrorver", "crop", "scale",
    "tagfaces", "clipboard", "export", "wallpaper", "qr", "close", "quit"]

    property int sze: settings["ExtPopout"] ? 50 : 40

    content: [

        Item {

            id: contentitem

            property string orientation: "horizontal"
            x: 2
            y: 2
            width: (orientation=="horizontal" ? contentrow.width : contentcol.width)+4
            height: (orientation=="horizontal" ? contentrow.height : contentcol.height)+4

            MouseArea {
                id: mouseBG
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                hoverEnabled: true
                drag.target: settings["ExtPopout"] ? undefined : element_top
                onClicked: (mouse) => {
                    if(mouse.button == Qt.RightButton)
                        menu.item.popup()
                }
            }

            Column {

                id: contentcol

                width: childrenRect.width
                spacing: 0

                Repeater {

                    model: contentitem.orientation=="vertical" ? quickactions_top.buttons.length : 0

                    Column {

                        id: delegver

                        required property int modelData
                        property string cat: quickactions_top.buttons[modelData]

                        property list<var> props: (delegver.cat in quickactions_top.mappings ?
                        quickactions_top.mappings[delegver.cat] :
                        ["?", "?", "?", "?"])

                        width: childrenRect.width

                        Item {
                            width: sze
                            height: 2
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: sepver
                            visible: delegver.props[0]==="|"
                            width: sze
                            height: 4
                            color: PQCLook.transInverseColor
                            opacity: 0.2
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: unknownver
                            visible: delegver.props[0]==="?"
                            width: visible ? sze : 0
                            height: visible ? sze : 0
                            color: "red"
                            PQText {
                                anchors.centerIn: parent
                                color: "white"
                                text: "?"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        PQButtonIcon {
                            id: iconver
                            enableContextMenu: false
                            overrideBaseColor: "transparent"
                            width: sepver.visible ? 0 : sze
                            height: sepver.visible ? 0 : sze
                            visible: !sepver.visible && !unknownver.visible
                            enabled: visible && (delegver.props[3] || PQCExtensionsHandler.numFiles>0)
                            tooltip: settings["ExtPopout"] ? "" : (enabled ? delegver.props[0] : qsTranslate("quickactions", "No file loaded"))
                            dragTarget: settings["ExtPopout"] ? undefined : element_top
                            source: visible ? ("image://svg/" + quickactions_top.baseDir + "/img/"  + PQCLook.iconShade + "/" + delegver.props[1] + ".svg") : ""

                            onClicked: {
                                PQCExtensionsHandler.requestExecutionOfInternalShortcut(delegver.props[2])
                            }

                            onRightClicked: {
                                if(!settings["ExtPopout"])
                                    menu.item.popup()
                            }

                            onMouseOverChanged: {
                                if(mouseOver) {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = delegver.modelData
                                    quickactions_top.mouseOver = true
                                } else {
                                    resetMouseOver.leftIndex = delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Item {
                            width: sze
                            height: 2
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*delegver.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*delegver.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                    }

                }

            }

            Row {

                id: contentrow

                height: childrenRect.height
                spacing: 0

                Repeater {

                    model: contentitem.orientation=="horizontal" ? quickactions_top.buttons.length : 0

                    Row {

                        id: deleghor

                        required property int modelData
                        property string cat: quickactions_top.buttons[modelData]

                        property list<var> props: (deleghor.cat in quickactions_top.mappings ?
                        quickactions_top.mappings[deleghor.cat] :
                        ["?", "?", "?", "?"])

                        height: childrenRect.height

                        Item {
                            width: 2
                            height: sze
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: sephor
                            visible: deleghor.props[0]==="|"
                            width: 4
                            height: sze
                            color: PQCLook.transInverseColor
                            opacity: 0.2
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: unknownhor
                            visible: deleghor.props[0]==="?"
                            width: visible ? sze : 0
                            height: visible ? sze : 0
                            color: "red"
                            PQText {
                                anchors.centerIn: parent
                                color: "white"
                                text: "?"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = -1*deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = -1*deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        PQButtonIcon {
                            id: icnhor
                            enableContextMenu: false
                            overrideBaseColor: "transparent"
                            width: sephor.visible ? 0 : sze
                            height: sephor.visible ? 0 : sze
                            visible: !sephor.visible && !unknownhor.visible
                            enabled: visible && (deleghor.props[3] || PQCExtensionsHandler.numFiles>0)
                            tooltip: settings["ExtPopout"] ? "" : (enabled ? deleghor.props[0] : qsTranslate("quickactions", "No file loaded"))
                            dragTarget: settings["ExtPopout"] ? undefined : element_top
                            source: visible ? ("image://svg/" + quickactions_top.baseDir + "/img/"  + PQCLook.iconShade + "/" + deleghor.props[1] + ".svg") : ""

                            onClicked: {
                                PQCExtensionsHandler.requestExecutionOfInternalShortcut(deleghor.props[2])
                            }

                            onRightClicked: {
                                if(!settings["ExtPopout"])
                                    menu.item.popup()
                            }

                            onMouseOverChanged: {
                                if(mouseOver) {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = deleghor.modelData
                                    quickactions_top.mouseOver = true
                                } else {
                                    resetMouseOver.leftIndex = deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                        Item {
                            width: 2
                            height: sze
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    resetMouseOver.stop()
                                    quickactions_top.mouseOverIndex = deleghor.modelData
                                    quickactions_top.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver.leftIndex = deleghor.modelData
                                    resetMouseOver.restart()
                                }
                            }
                        }

                    }

                }

            }

        }

    ]

    ButtonGroup { id: grp }

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {
            id: themenu

            PQMenuItem {
                text: qsTranslate("MainMenu", "Reset position to default")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                onTriggered: {
                    PQCExtensionsHandler.requestResetGeometry(quickactions_top.extensionId)
                }
            }

            PQMenuItem {
                text: qsTranslate("settingsmanager", "Manage in settings manager")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
                onTriggered: {
                    // TODO 5.0
                    console.warn("TODO TODO TODO")
                    // PQCNotify.openSettingsManagerAt("settingsmanager", "quickactions")
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                text: qsTranslate("histogram", "Hide quick actions")
                onTriggered: {
                    quickactions_top.hide()
                }
            }

        }

    }

}
