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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtCharts

import PQCExtensionsHandler
import PhotoQt

PQTemplateExtension {

    id: histogram_top

    extensionId: "Histogram"
    setTooltip: getIsPoppedOut ? "" : qsTr("Click-and-drag to move.")

    content: [

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

            ValuesAxis {
                id: noaxisX
                labelsVisible: false
                gridVisible: true
                gridLineColor: "#33ffffff"
                color: "#66ffffff"
                min: 0
                max: 255
            }
            ValuesAxis {
                id: noaxisY
                labelsVisible: false
                gridVisible: true
                gridLineColor: "#33ffffff"
                color: "#66ffffff"
                min: 0
                max: 1.01
            }

            AreaSeries {
                id: histogramred_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#88ff0000"
                borderWidth: 1
                borderColor: "#ff0000"
                visible: PQCSettings.extensions.HistogramVersion==="color" // qmllint disable unqualified
                upperSeries: LineSeries {
                    id: histogramred
                }
            }

            AreaSeries {
                id: histogramgreen_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#8800ff00"
                borderWidth: 1
                borderColor: "#00ff00"
                visible: PQCSettings.extensions.HistogramVersion==="color" // qmllint disable unqualified
                upperSeries: LineSeries {
                    id: histogramgreen
                }
            }

            AreaSeries {
                id: histogramblue_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#880000ff"
                borderWidth: 1
                borderColor: "#0000ff"
                visible: PQCSettings.extensions.HistogramVersion==="color" // qmllint disable unqualified
                upperSeries: LineSeries {
                    id: histogramblue
                }
            }

            AreaSeries {
                id: histogramgrey_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#88cccccc"
                borderWidth: 1
                borderColor: "#cccccc"
                visible: PQCSettings.extensions.HistogramVersion==="grey" // qmllint disable unqualified
                upperSeries: LineSeries {
                    id: histogramgrey
                }
            }



            Rectangle {
                id: busy
                radius: histogram_top.radius
                anchors.fill: parent
                color: PQCLook.transColor // qmllint disable unqualified
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
                color: PQCLook.transColor // qmllint disable unqualified
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
                color: PQCLook.transColor // qmllint disable unqualified
                opacity: PQCExtensionsHandler.numFiles===0 ? 1 : 0 // qmllint disable unqualified
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    anchors.centerIn: parent
                    text: qsTranslate("histogram", "Histogram")
                }
            }

        }

    ]

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
                checked: PQCSettings.extensions.HistogramVersion==="color"
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.extensions.HistogramVersion = "color"
                }
            }
            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                //: used in context menu for histogram
                text: qsTranslate("histogram", "gray scale")
                ButtonGroup.group: grp
                checked: PQCSettings.extensions.HistogramVersion==="grey" // qmllint disable unqualified
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.extensions.HistogramVersion = "grey"
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                text: qsTranslate("histogram", "Hide histogram")
                onTriggered: {
                    histogram_top.hide()
                }
            }

        }

    }

    Connections {

        target: PQCExtensionsHandler

        function onCurrentFileChanged() {
            failed.opacity = 0
            nofileloaded.opacity = 0
            busy.opacity = 1
        }

        function onReplyForOnFileLoad(id, val) {

            if(id !== histogram_top.extensionId || val === undefined || val[0] !== PQCExtensionsHandler.currentFile) {
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

    onShowing: {

        if(PQCExtensionsHandler.numFiles === 0) {
            nofileloaded.opacity = 1
            busy.opacity = 0
            failed.opacity = 0
        } else {
            failed.opacity = 0
            nofileloaded.opacity = 0
            busy.opacity = 1
        }

    }

}
