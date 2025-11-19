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
import QtLocation
import QtPositioning
import PhotoQt

PQTemplateExtension {

    id: mapcurrent_top

    property bool noLocation: true
    property real latitude: 49.00937
    property real longitude: 8.40444

    SystemPalette { id: pqtPalette }

    Plugin {

        id: osmPlugin

        name: "osm"

        PluginParameter {
            name: "osm.useragent"
            value: "PhotoQt Image Viewer"
        }

        PluginParameter {
            name: "osm.mapping.providersrepository.address"
            value: "https://osm.photoqt.org"
        }

        PluginParameter {
            name: "osm.mapping.highdpi_tiles";
            value: true
        }

    }

    Map {
        id: map
        anchors.fill: parent
        plugin: osmPlugin
        center {
            latitude: mapcurrent_top.latitude
            longitude: mapcurrent_top.longitude
        }

        Behavior on center.latitude { NumberAnimation { duration: 200 } }
        Behavior on center.longitude { NumberAnimation { duration: 200 } }

        zoomLevel: 12
        Behavior on zoomLevel { NumberAnimation { duration: 100 } }

        activeMapType: supportedMapTypes[supportedMapTypes.length > 5 ? 5 : (supportedMapTypes.length-1)]

        MapQuickItem {

            id: marker

            anchorPoint.x: container.width*(61/256)
            anchorPoint.y: container.height*(198/201)

            visible: true

            coordinate: QtPositioning.coordinate(mapcurrent_top.latitude, mapcurrent_top.longitude)

            sourceItem:
                Image {
                    id: container
                    width: 64
                    height: 50
                    mipmap: true
                    smooth: false
                    source: "qrc:/" + PQCLook.iconShade + "/maplocation.png"
                }

        }

        Item {
            id: noloc
            anchors.fill: parent
            opacity: (mapcurrent_top.noLocation&&PQCExtensionProperties.currentFileList.length>0) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            Rectangle {
                anchors.fill: parent
                color: pqtPalette.base
                opacity: 0.95
            }
            PQText {
                font.weight: PQCLook.fontWeightBold
                anchors.centerIn: parent
                //: The location here is a GPS location
                text: qsTranslate("mapcurrent", "No location data")
            }
        }

        Item {
            id: nofileloaded
            anchors.fill: parent
            opacity: PQCExtensionProperties.currentFileList.length===0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            Rectangle {
                anchors.fill: parent
                color: pqtPalette.base
                opacity: 0.95
            }
            PQText {
                font.weight: PQCLook.fontWeightBold
                anchors.centerIn: parent
                //: The location here is a GPS location
                text: qsTranslate("mapcurrent", "No file loaded")
            }
        }

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            tooltip: qsTranslate("mapcurrent", "Click-and-drag to move")
            drag.target: mapcurrent_top.parent.parent
            onWheel: (wheel) => {
                if(!nofileloaded.visible && !noloc.visible)
                    map.zoomLevel = (map.zoomLevel + wheel.angleDelta.y*0.01)
                wheel.accepted = true
            }
        }

    }

    Connections {

        target: PQCExtensionProperties

        function onCurrentMetadataChanged() {
            mapcurrent_top.updateMap()
        }

    }

    function showing() {
        updateMap()
    }

    function updateMap() {

        var pos = convertGPSToPoint(PQCExtensionProperties.currentMetadata["exifGPS"])

        // this value means: no gps data
        if(pos[0] === 9999 || pos[1] === 9999) {
            noLocation = true
            return
        }

        latitude = pos[0]
        longitude = pos[1]
        noLocation = false

    }

    function convertGPSToPoint(gps : string) : list<real> {

        if(!gps.includes(", "))
            return [9999,9999]

        var one = gps.split(", ")[0]
        var two = gps.split(", ")[1]

        if(!one.includes("°") || !one.includes("'") || !one.includes("''"))
            return [9999,9999]
        if(!two.includes("°") || !two.includes("'") || !two.includes("''"))
            return [9999,9999]

        var one_dec = parseFloat(one.split("°")[0]) + parseFloat(one.split("°")[1].split("'")[0])/60.0 + parseFloat(one.split("'")[1].split("''")[0])/3600.0;
        if(one.includes("S"))
            one_dec *= -1

        var two_dec = parseFloat(two.split("°")[0]) + parseFloat(two.split("°")[1].split("'")[0])/60.0 + parseFloat(two.split("'")[1].split("''")[0])/3600.0;
        if(two.includes("W"))
            two_dec *= -1

        return [one_dec, two_dec]

    }

}
