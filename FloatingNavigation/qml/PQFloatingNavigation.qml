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
import PhotoQt

PQTemplateExtension {

    id: nav_top

    property bool mouseOver: false
    property int mouseOverId: -1

    color: "transparent"

    opacity: mouseOver||isPoppedOut ? 1 : 0.2
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Timer {
        id: resetMouseOver
        interval: 100
        property int oldId
        onTriggered: {
            if(oldId == nav_top.mouseOverId)
                nav_top.mouseOver = false
        }
    }

    Item {

        anchors.fill: parent

        Image {
            width: parent.width/3
            height: parent.height
            source: "image://svg/" + nav_top.baseDir + "/img/" + PQCLook.iconShade + "/leftarrow.svg"
            sourceSize: Qt.size(width, height)
            enabled: PQCExtensionProperties.currentFileList.length>0
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top.parent.parent
                drag.minimumX: 0
                drag.maximumX: PQCExtensionProperties.currentWindowSize.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: PQCExtensionProperties.currentWindowSize.height-nav_top.height
                tooltip: qsTranslate("floatingnavigation", "Navigate to previous image in folder")
                onClicked:
                    PQCExtensionMethods.executeInternalCommand("__prev")
                onEntered: {
                    resetMouseOver.stop()
                    nav_top.mouseOverId = 1
                    nav_top.mouseOver = true
                }
                onExited: {
                    resetMouseOver.oldId = 1
                    resetMouseOver.restart()
                }
            }
        }

        Image {
            x: width
            width: parent.width/3
            height: parent.height
            source: "image://svg/" + nav_top.baseDir + "/img/" + PQCLook.iconShade + "/rightarrow.svg"
            sourceSize: Qt.size(width, height)
            enabled: PQCExtensionProperties.currentFileList.length>0
            opacity: enabled ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top.parent.parent
                drag.minimumX: 0
                drag.maximumX: PQCExtensionProperties.currentWindowSize.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: PQCExtensionProperties.currentWindowSize.height-nav_top.height
                tooltip: qsTranslate("floatingnavigation", "Navigate to next image in folder")
                onClicked:
                    PQCExtensionMethods.executeInternalCommand("__next")
                onEntered: {
                    resetMouseOver.stop()
                    nav_top.mouseOverId = 2
                    nav_top.mouseOver = true
                }
                onExited: {
                    resetMouseOver.oldId = 2
                    resetMouseOver.restart()
                }
            }
        }

        Image {
            x: 2*width
            width: parent.width/3
            height: parent.height
            source: "image://svg/" + nav_top.baseDir + "/img/" + PQCLook.iconShade + "/menu.svg"
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                drag.target: nav_top.parent.parent
                drag.minimumX: 0
                drag.maximumX: PQCExtensionProperties.currentWindowSize.width-nav_top.width
                drag.minimumY: 0
                drag.maximumY: PQCExtensionProperties.currentWindowSize.height-nav_top.height
                tooltip: qsTranslate("floatingnavigation", "Show main menu")
                onClicked:
                    PQCExtensionMethods.executeInternalCommand("__toggleMainMenu")
                onEntered: {
                    resetMouseOver.stop()
                    nav_top.mouseOverId = 3
                    nav_top.mouseOver = true
                }
                onExited: {
                    resetMouseOver.oldId = 3
                    resetMouseOver.restart()
                }
            }
        }

    }

}
