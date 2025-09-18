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
import PhotoQt.CPlusPlus
import PhotoQt

PQTemplateExtension {

    id: scale_top

    modalButton1Text: "Scale"
    modalButton2Text: "Cancel"

    function modalButton1Action() {
        // settings["LastUsed"] = targetFormat
        // var newfile = PQCExtensionsHandler.requestSelectFileFromDialog("Export", PQCExtensionsHandler.currentFile, parseInt(targetFormat), true)
        // if(newfile !== "") {
        //     errormessage.visible = false
        //     exportbusy.showBusy()
        //     PQCExtensionsHandler.requestCallActionWithImage1(extensionId,
        //                                                     [newfile,
        //                                                      PQCExtensionsHandler.requestImageFormatInfoForId(parseInt(targetFormat))])
        // }
    }
    function modalButton2Action() {
        scale_top.hide()
    }

    content: [

        Flickable {

            id: flickable

            anchors.fill: parent
            clip: true

            contentHeight: insidecont.height+20

            ScrollBar.vertical: PQVerticalScrollBar { }

            Column {

                id: insidecont

                x: ((parent.width-width)/2)
                y: 10

                width: parent.width-10

                spacing: 10

                /*****************************************************/
                // error message

                Item {
                    visible: errorlabel.visible
                    width: 1
                    height: 10
                }

                PQTextL {
                    id: errorlabel
                    width: parent.width
                    horizontalAlignment: Qt.AlignHCenter
                    font.weight: PQCLook.fontWeightBold
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: false
                    text: qsTranslate("scale", "An error occured, file could not be scaled")
                }

                Item {
                    width: 1
                    height: 10
                }

                Row {

                    x: (parent.width-width)/2

                    spacing: 10

                    Column {
                        spacing: 5
                        PQText {
                            height: spin_w.height
                            //: The number of horizontal pixels of the image
                            text: qsTranslate("scale", "Width:")
                            verticalAlignment: Qt.AlignVCenter
                        }
                        PQText {
                            height: spin_h.height
                            //: The number of vertical pixels of the image
                            text: qsTranslate("scale", "Height:")
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }

                    Column {
                        id: spincol
                        spacing: 5

                        PQSliderSpinBox {
                            id: spin_w
                            enabled: scale_top.visible
                            minval: 1
                            maxval: 99999
                            showSlider: false
                            property bool reactToValueChanged: true
                            onValueChanged: {
                                if(scale_top.opacity < 1) return
                                    if(scale_top.keepAspectRatio && reactToValueChanged) {
                                        var h = value/scale_top.aspectRatio
                                        if(h !== spin_h.value) {
                                            spin_h.reactToValueChanged = false
                                            spin_h.value = Math.round(h)
                                        }
                                    } else
                                        reactToValueChanged = true
                            }
                        }
                        PQSliderSpinBox {
                            id: spin_h
                            enabled: scale_top.visible
                            minval: 1
                            maxval: 99999
                            showSlider: false
                            property bool reactToValueChanged: true
                            onValueChanged: {
                                if(scale_top.opacity < 1) return
                                    if(scale_top.keepAspectRatio && reactToValueChanged) {
                                        var w = value*scale_top.aspectRatio
                                        if(w !== spin_w.value) {
                                            spin_w.reactToValueChanged = false
                                            spin_w.value = Math.round(w)
                                        }
                                    } else
                                        reactToValueChanged = true
                            }
                        }

                    }

                    Image {
                        source: scale_top.keepAspectRatio ? "image://svg/:/" + PQCLook.iconShade + "/aspectratiokeep.svg" : "image://svg/:/" + PQCLook.iconShade + "/aspectratioignore.svg" // qmllint disable unqualified
                        y: (spincol.height-height)/2
                        width: height/3
                        height: spincol.height*0.8
                        sourceSize: Qt.size(width, height)
                        smooth: false
                        mipmap: false
                        opacity: scale_top.keepAspectRatio ? 1 : 0.5
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                scale_top.keepAspectRatio = !scale_top.keepAspectRatio
                            }
                        }
                    }

                }

                PQTextS {

                    x: (parent.width-width)/2
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                    text: qsTranslate("scale", "New size:") + " " +
                    spin_w.value + " x " + spin_h.value + " " +
                    //: This is used as in: 100x100 pixels
                    qsTranslate("scale", "pixels")
                }

                Item {
                    width: 1
                    height: 10
                }

                Row {

                    x: (parent.width-width)/2

                    spacing: 5

                    PQButton {
                        id: but025
                        text: "0.25x"
                        font.pointSize: PQCLook.fontSize // qmllint disable unqualified
                        font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified
                        width: height*1.5
                        onClicked: {
                            spin_w.value = PQCConstants.currentImageResolution.width*0.25 // qmllint disable unqualified
                            spin_h.value = PQCConstants.currentImageResolution.height*0.25 // qmllint disable unqualified
                        }
                    }

                    PQButton {
                        id: but050
                        text: "0.5x"
                        font.pointSize: PQCLook.fontSize // qmllint disable unqualified
                        font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified
                        width: height*1.5
                        onClicked: {
                            spin_w.value = PQCConstants.currentImageResolution.width*0.5 // qmllint disable unqualified
                            spin_h.value = PQCConstants.currentImageResolution.height*0.5
                        }
                    }

                    PQButton {
                        id: but075
                        text: "0.75x"
                        font.pointSize: PQCLook.fontSize // qmllint disable unqualified
                        font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified
                        width: height*1.5
                        onClicked: {
                            spin_w.value = PQCConstants.currentImageResolution.width*0.75 // qmllint disable unqualified
                            spin_h.value = PQCConstants.currentImageResolution.height*0.75
                        }
                    }

                    PQButton {
                        id: but100
                        text: "1x"
                        font.pointSize: PQCLook.fontSize // qmllint disable unqualified
                        font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified
                        width: height*1.5
                        onClicked: {
                            spin_w.value = PQCConstants.currentImageResolution.width // qmllint disable unqualified
                            spin_h.value = PQCConstants.currentImageResolution.height
                        }
                    }

                    PQButton {
                        id: but150
                        text: "1.5x"
                        font.pointSize: PQCLook.fontSize // qmllint disable unqualified
                        font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified
                        width: height*1.5
                        onClicked: {
                            spin_w.value = PQCConstants.currentImageResolution.width*1.5 // qmllint disable unqualified
                            spin_h.value = PQCConstants.currentImageResolution.height*1.5
                        }
                    }

                }

                Item {
                    width: 1
                    height: 10
                }

                Row {

                    x: (parent.width-width)/2

                    spacing: 10

                    PQText {
                        text: qsTranslate("scale", "Quality:")
                    }

                    PQSlider {
                        id: quality
                        from: 1
                        to: 100
                        value: 80
                    }

                    PQText {
                        text: quality.value + "%"
                    }

                }

            }

        }

    ]

    PQWorking {
        id: scalebusy
    }

    Connections {

        target: PQCExtensionsHandler

        function onReplyForActionWithImage1(id, val) {
            if(id !== scale_top.extensionId)
                return
            if(val) {
                errorlabel.visible = false
                scalebusy.showSuccess()
            } else {
                scalebusy.hide()
                errorlabel.visible = true
            }
        }

    }

    onShowing: {
        scalebusy.hide()
        errorlabel.visible = false
    }

}
