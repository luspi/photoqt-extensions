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
import PhotoQt

PQTemplateExtension {

    id: histogram_top

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    ChartView {

        id: chart

        anchors.fill: parent

        antialiasing: true
        legend.visible: false

        margins.left: 0
        margins.right: 0
        margins.top: 0
        margins.bottom: 0

        backgroundColor: "transparent"

        ValueAxis {
            id: noaxisX
            labelsVisible: false
            gridVisible: true
            gridLineColor: pqtPaletteDisabled.text
            color: pqtPaletteDisabled.text
            min: 0
            max: 255
        }
        ValueAxis {
            id: noaxisY
            labelsVisible: false
            gridVisible: true
            gridLineColor: pqtPaletteDisabled.text
            color: pqtPaletteDisabled.text
            min: 0
            max: 1.01
        }

        AreaSeries {
            id: histogramred_cont
            axisX: noaxisX
            axisY: noaxisY
            color: "#bbff0000"
            borderWidth: 1
            borderColor: "#ff0000"
            visible: settings["Version"]==="color"
            upperSeries: LineSeries {
                id: histogramred
            }
        }

        AreaSeries {
            id: histogramgreen_cont
            axisX: noaxisX
            axisY: noaxisY
            color: "#bb00ff00"
            borderWidth: 1
            borderColor: "#00ff00"
            visible: settings["Version"]==="color"
            upperSeries: LineSeries {
                id: histogramgreen
            }
        }

        AreaSeries {
            id: histogramblue_cont
            axisX: noaxisX
            axisY: noaxisY
            color: "#bb0000ff"
            borderWidth: 1
            borderColor: "#0000ff"
            visible: settings["Version"]==="color"
            upperSeries: LineSeries {
                id: histogramblue
            }
        }

        AreaSeries {
            id: histogramgrey_cont
            axisX: noaxisX
            axisY: noaxisY
            color: pqtPaletteDisabled.text
            opacity: 0.8
            borderWidth: 1
            borderColor: pqtPalette.text
            visible: settings["Version"]==="grey"
            upperSeries: LineSeries {
                id: histogramgrey
            }
        }



        Rectangle {
            id: busy
            radius: histogram_top.radius
            anchors.fill: parent
            color: pqtPalette.base
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            PQText {
                anchors.centerIn: parent
                text: qsTranslate("histogram", "Loading...")
            }
        }

        Rectangle {
            id: failed
            radius: histogram_top.radius
            anchors.fill: parent
            color: pqtPalette.base
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            PQText {
                anchors.centerIn: parent
                text: qsTranslate("histogram", "Error loading histogram")
            }
        }

        Rectangle {
            id: nofileloaded
            radius: histogram_top.radius
            anchors.fill: parent
            color: pqtPalette.base
            opacity: PQCExtensionProperties.currentFileList.length===0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            PQText {
                anchors.centerIn: parent
                text: qsTranslate("histogram", "Histogram")
            }
        }

    }

    onRightClicked: (mouse) => {
        menu.item.popup() // qmllint disable missing-property
    }

    ButtonGroup { id: grp }

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {
            id: themenu
            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                //: used in context menu for histogram
                text: qsTranslate("histogram", "RGB colors")
                ButtonGroup.group: grp
                checked: settings["Version"]==="color"
                onCheckedChanged: {
                    if(checked)
                        settings["Version"] = "color"
                }
            }
            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                //: used in context menu for histogram
                text: qsTranslate("histogram", "gray scale")
                ButtonGroup.group: grp
                checked: settings["Version"]==="grey"
                onCheckedChanged: {
                    if(checked)
                        settings["Version"] = "grey"
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                iconSource: PQCExtensionMethods.path2ImageProvider(":/" + PQCLook.iconShade + "/close.svg")
                text: qsTranslate("histogram", "Hide histogram")
                onTriggered: {
                    histogram_top.hide()
                }
            }

        }

    }

    Connections {

        target: PQCExtensionProperties

        function onCurrentFileChanged() {
            failed.opacity = 0
            nofileloaded.opacity = 0
            busy.opacity = 1
            PQCExtensionMethods.callActionWithImageNonBlocking(histogram_top.extensionId)
        }

    }

    Connections {

        target: PQCExtensionMethods

        function onReplyForActionWithImage(id, val) {

            if(id !== histogram_top.extensionId || val === undefined || val[0] !== PQCExtensionProperties.currentFile) {
                return
            }

            nofileloaded.opacity = 0

            if(val[1].length === 0) {
                failed.opacity = 1
                return
            }

            failed.opacity = 0

            var red = val[1][0]
            var green = val[1][1]
            var blue = val[1][2]
            var grey = val[1][3]

            // RED COLOR

            histogramred.clear()
            for(var r = 0; r < 256; ++r)
                histogramred.append(r, red[r])

            // GREEN COLOR

            histogramgreen.clear()
            for(var g = 0; g < 256; ++g)
                histogramgreen.append(g, green[g])

            // BLUE COLOR

            histogramblue.clear()
            for(var b = 0; b < 256; ++b)
                histogramblue.append(b, blue[b])

            // GRAY SCALE

            histogramgrey.clear();
            for(var k = 0; k < 256; ++k)
                histogramgrey.append(k, grey[k])

            busy.opacity = 0

        }

    }

    function showing() {

        if(PQCExtensionProperties.currentFileList.length === 0) {
            nofileloaded.opacity = 1
            busy.opacity = 0
            failed.opacity = 0
        } else {
            failed.opacity = 0
            nofileloaded.opacity = 0
            busy.opacity = 1
            PQCExtensionMethods.callActionWithImageNonBlocking(histogram_top.extensionId)
        }

    }

}
