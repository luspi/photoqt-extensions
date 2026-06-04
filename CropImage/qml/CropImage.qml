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

    id: crop_top

    modalButton2Text: qsTranslate("cropimage", "Crop")

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    // this is needed to not show the animation again when the window is resized
    property bool animShowed: false

    /***************************************************************/

    Image {

        id: theimage

        width: parent.width
        height: parent.height

        sourceSize.width: width
        sourceSize.height: height

        fillMode: Image.PreserveAspectFit

        source: PQCExtensionMethods.path2ImageProvider(PQCExtensionProperties.currentFile)

        onStatusChanged: (status) => {
            if(status === Image.Ready) {
                updateStartEndPosBackupAndStart.restart()
            }
        }
        // we add a slight delay to make sure the bindings are all properly updated before starting
        Timer {
            id: updateStartEndPosBackupAndStart
            interval: 500
            onTriggered: {
                if(!crop_top.animShowed) {
                    animateCropping.startPosBackup = resizerect.startPos
                    animateCropping.endPosBackup = resizerect.endPos
                    animateCropping.restart()
                }
            }
        }

        /******************************************/
        // shaded region that will be cropped out

        // left region
        Rectangle {
            color: "#aa000000"
            x: resizerect.effectiveX
            y: resizerect.effectiveY
            width: resizerect.startPos.x*theimage.paintedWidth
            height: resizerect.effectiveHeight
        }

        // right region
        Rectangle {
            color: "#aa000000"
            x: resizerect.effectiveX+resizerect.endPos.x*theimage.paintedWidth
            y: resizerect.effectiveY
            width: resizerect.effectiveWidth-resizerect.endPos.x*theimage.paintedWidth
            height: resizerect.effectiveHeight
        }

        // top region
        Rectangle {
            color: "#aa000000"
            x: resizerect.effectiveX+resizerect.startPos.x*theimage.paintedWidth
            y: resizerect.effectiveY
            width: (resizerect.endPos.x-resizerect.startPos.x)*theimage.paintedWidth
            height: resizerect.startPos.y*theimage.paintedHeight
        }

        // bottom region
        Rectangle {
            color: "#aa000000"
            x: resizerect.effectiveX+resizerect.startPos.x*theimage.paintedWidth
            y: resizerect.effectiveY+resizerect.endPos.y*theimage.paintedHeight
            width: (resizerect.endPos.x-resizerect.startPos.x)*theimage.paintedWidth
            height: resizerect.effectiveHeight-resizerect.endPos.y*theimage.paintedHeight
        }

        /******************************************/

        Item {

            id: resizerect

            width: parent.width
            height: parent.height

            property int effectiveX: (theimage.width-theimage.paintedWidth)/2
            property int effectiveY: (theimage.height-theimage.paintedHeight)/2
            property int effectiveWidth: theimage.paintedWidth
            property int effectiveHeight: theimage.paintedHeight

            property point startPos: Qt.point(0.2,0.2)
            property point endPos: Qt.point(0.4,0.4)

            // region that is desired

            Rectangle {
                x: resizerect.effectiveX+resizerect.startPos.x*resizerect.effectiveWidth
                y: resizerect.effectiveY+resizerect.startPos.y*resizerect.effectiveHeight
                width: (resizerect.endPos.x-resizerect.startPos.x)*resizerect.effectiveWidth
                height: (resizerect.endPos.y-resizerect.startPos.y)*resizerect.effectiveHeight
                color: "transparent"
                border.width: 2
                border.color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeAllCursor
                    property bool pressedDown: false
                    property int startX
                    property int startY
                    onPressed: (mouse) => {
                        startX = mouse.x
                        startY = mouse.y
                        pressedDown = true
                    }
                    onReleased:
                    pressedDown = false
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            var w = resizerect.endPos.x - resizerect.startPos.x
                            resizerect.startPos.x = Math.max(0, Math.min(1-w, resizerect.startPos.x+(mouse.x-startX)/resizerect.effectiveWidth))
                            resizerect.endPos.x = resizerect.startPos.x+w
                        }
                    }
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            var h = resizerect.endPos.y - resizerect.startPos.y
                            resizerect.startPos.y = Math.max(0, Math.min(1-h, resizerect.startPos.y+(mouse.y-startY)/resizerect.effectiveHeight))
                            resizerect.endPos.y = resizerect.startPos.y+h
                        }
                    }
                }
            }

            /******************************************/
            // markers for resizing highlighted region

            property int markerSize: ((resizerect.endPos.x-resizerect.startPos.x)*effectiveWidth < 50 || (resizerect.endPos.y-resizerect.startPos.y)*effectiveHeight < 50 ? 10 : 20)
            Behavior on markerSize { NumberAnimation { duration: 200 } }

            // top
            Rectangle {
                x: resizerect.effectiveX + (resizerect.startPos.x +(resizerect.endPos.x-resizerect.startPos.x)/2)*resizerect.effectiveWidth -resizerect.markerSize/2
                y: resizerect.effectiveY + resizerect.startPos.y*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeVerCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.startPos.y = Math.max(0, Math.min(resizerect.endPos.y-0.01, (mapToItem(theimage, mouse.x, mouse.y).y-resizerect.effectiveY)/resizerect.effectiveHeight))
                        }
                    }
                }
            }

            // left
            Rectangle {
                x: resizerect.effectiveX + resizerect.startPos.x*resizerect.effectiveWidth - resizerect.markerSize/2
                y: resizerect.effectiveY + (resizerect.startPos.y + (resizerect.endPos.y-resizerect.startPos.y)/2)*resizerect.effectiveHeight -resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeHorCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.startPos.x = Math.max(0, Math.min(resizerect.endPos.x-0.01, (mapToItem(theimage, mouse.x, mouse.y).x-resizerect.effectiveX)/resizerect.effectiveWidth))
                        }
                    }
                }
            }

            // right
            Rectangle {
                x: resizerect.effectiveX + resizerect.endPos.x*resizerect.effectiveWidth - resizerect.markerSize/2
                y: resizerect.effectiveY + (resizerect.startPos.y + (resizerect.endPos.y-resizerect.startPos.y)/2)*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeHorCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.endPos.x = Math.min(1, Math.max(resizerect.startPos.x+0.01, (mapToItem(theimage, mouse.x, mouse.y).x-resizerect.effectiveX)/resizerect.effectiveWidth))
                        }
                    }
                }
            }

            // bottom
            Rectangle {
                x: resizerect.effectiveX + (resizerect.startPos.x +(resizerect.endPos.x-resizerect.startPos.x)/2)*resizerect.effectiveWidth -resizerect.markerSize/2
                y: resizerect.effectiveY + resizerect.endPos.y*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeVerCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.endPos.y = Math.min(1, Math.max(resizerect.startPos.y+0.01, (mapToItem(theimage, mouse.x, mouse.y).y-resizerect.effectiveY)/resizerect.effectiveHeight))
                        }
                    }
                }
            }

            // top left
            Rectangle {
                x: resizerect.effectiveX + resizerect.startPos.x*resizerect.effectiveWidth - resizerect.markerSize/2
                y: resizerect.effectiveY + resizerect.startPos.y*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeFDiagCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.startPos.y = Math.max(0, Math.min(resizerect.endPos.y-0.01, (mapToItem(theimage, mouse.x, mouse.y).y-resizerect.effectiveY)/resizerect.effectiveHeight))
                        }
                    }
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.startPos.x = Math.max(0, Math.min(resizerect.endPos.x-0.01, (mapToItem(theimage, mouse.x, mouse.y).x-resizerect.effectiveX)/resizerect.effectiveWidth))
                        }
                    }
                }
            }

            // top right
            Rectangle {
                x: resizerect.effectiveX + resizerect.endPos.x*resizerect.effectiveWidth - resizerect.markerSize/2
                y: resizerect.effectiveY + resizerect.startPos.y*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeBDiagCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.startPos.y = Math.max(0, Math.min(resizerect.endPos.y-0.01, (mapToItem(theimage, mouse.x, mouse.y).y-resizerect.effectiveY)/resizerect.effectiveHeight))
                        }
                    }
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.endPos.x = Math.min(1, Math.max(resizerect.startPos.x+0.01, (mapToItem(theimage, mouse.x, mouse.y).x-resizerect.effectiveX)/resizerect.effectiveWidth))
                        }
                    }
                }
            }

            // bottom left
            Rectangle {
                x: resizerect.effectiveX + resizerect.startPos.x*resizerect.effectiveWidth - resizerect.markerSize/2
                y: resizerect.effectiveY + resizerect.endPos.y*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeBDiagCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.endPos.y = Math.min(1, Math.max(resizerect.startPos.y+0.01, (mapToItem(theimage, mouse.x, mouse.y).y-resizerect.effectiveY)/resizerect.effectiveHeight))
                        }
                    }
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.startPos.x = Math.max(0, Math.min(resizerect.endPos.x-0.01, (mapToItem(theimage, mouse.x, mouse.y).x-resizerect.effectiveX)/resizerect.effectiveWidth))
                        }
                    }
                }
            }

            // bottom right
            Rectangle {
                x: resizerect.effectiveX + resizerect.endPos.x*resizerect.effectiveWidth - resizerect.markerSize/2
                y: resizerect.effectiveY + resizerect.endPos.y*resizerect.effectiveHeight - resizerect.markerSize/2
                width: resizerect.markerSize
                height: resizerect.markerSize
                radius: resizerect.markerSize/2
                color: "red"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeFDiagCursor
                    property bool pressedDown: false
                    onPressed:
                    pressedDown = true
                    onReleased:
                    pressedDown = false
                    onMouseYChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.endPos.y = Math.min(1, Math.max(resizerect.startPos.y+0.01, (mapToItem(theimage, mouse.x, mouse.y).y-resizerect.effectiveY)/resizerect.effectiveHeight))
                        }
                    }
                    onMouseXChanged: (mouse) => {
                        if(pressedDown) {
                            resizerect.endPos.x = Math.min(1, Math.max(resizerect.startPos.x+0.01, (mapToItem(theimage, mouse.x, mouse.y).x-resizerect.effectiveX)/resizerect.effectiveWidth))
                        }
                    }
                }
            }

        }

    }

    Rectangle {

        id: errorlabel

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        width: errorlabel_txt.width+30
        height: errorlabel_txt.height+30

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        color: "#88ff0000"
        radius: 10

        border.width: 1
        border.color: "white"

        PQTextL {

            id: errorlabel_txt

            x: 15
            y: 15

            width: 300

            horizontalAlignment: Qt.AlignHCenter
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("cropimage", "An error occured, file could not be cropped")
        }

        Timer {
            interval: 2500
            running: errorlabel.visible
            onTriggered:
            errorlabel.hide()
        }

        function show() {
            opacity = 1
        }
        function hide() {
            opacity = 0
        }

    }

    PQWorking {
        id: cropbusy
    }

    ParallelAnimation {
        id: animateCropping

        property point startPosBackup: Qt.point(-1,-1)
        property point endPosBackup: Qt.point(-1,-1)

        property real maxW: (endPosBackup.x-startPosBackup.x)/2
        property real maxH: (endPosBackup.y-startPosBackup.y)/2
        property real animExtentW: Math.min(0.02, maxW)
        property real animExtentH: Math.min(0.02, maxH)

        onStarted:
        crop_top.animShowed = true

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "startPos.x"
                duration: 400
                from: animateCropping.startPosBackup.x
                to: animateCropping.startPosBackup.x + animateCropping.animExtentW
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "startPos.x"
                duration: 400
                from: animateCropping.startPosBackup.x + animateCropping.animExtentW
                to: animateCropping.startPosBackup.x
                easing.type: Easing.OutBounce
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "startPos.y"
                duration: 400
                from: animateCropping.startPosBackup.y
                to: animateCropping.startPosBackup.y + animateCropping.animExtentH
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "startPos.y"
                duration: 400
                from: animateCropping.startPosBackup.y + animateCropping.animExtentH
                to: animateCropping.startPosBackup.y
                easing.type: Easing.OutBounce
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "endPos.x"
                duration: 400
                from: animateCropping.endPosBackup.x
                to: animateCropping.endPosBackup.x - animateCropping.animExtentW
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "endPos.x"
                duration: 400
                from: animateCropping.endPosBackup.x - animateCropping.animExtentW
                to: animateCropping.endPosBackup.x
                easing.type: Easing.OutBounce
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "endPos.y"
                duration: 400
                from: animateCropping.endPosBackup.y
                to: animateCropping.endPosBackup.y - animateCropping.animExtentH
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "endPos.y"
                duration: 400
                from: animateCropping.endPosBackup.y - animateCropping.animExtentH
                to: animateCropping.endPosBackup.y
                easing.type: Easing.OutBounce
            }
        }
    }

    Connections {
        target: cropbusy
        function onSuccessHidden() {
            crop_top.hide()
        }
    }

    Connections {

        target: PQCExtensionMethods

        function onReceivedShortcut(combo : string) {
            if(!crop_top.visible || !crop_top.modalButton2Enabled) return
                if(combo === "Enter" || combo === "Return") {
                    crop_top.modalButton2Action()
                }
        }

    }

    function modalButton2Action() {

        errorlabel.hide()
        modalButton2Enabled = false

        const format = PQCExtensionMethods.getFormatOfFile(PQCExtensionProperties.currentFile)

        var val = PQCExtensionMethods.callAction(crop_top.extensionId,
                                                 [format,PQCExtensionMethods.getSuffixesForFormat(format)])

        if(val === "")
            return

        cropbusy.showBusy()

        const sze = PQCExtensionMethods.getSizeOfImage(PQCExtensionProperties.currentFile)

        if(!PQCExtensionMethods.writeImage(PQCExtensionProperties.currentFile, val,
            Qt.rect(resizerect.startPos.x*sze.width,
                    resizerect.startPos.y*sze.height,
                    (resizerect.endPos.x-resizerect.startPos.x)*sze.width,
                    (resizerect.endPos.y-resizerect.startPos.y)*sze.height), Qt.size(0,0))) {
            cropbusy.hide()
            errorlabel.show()
            modalButton2Enabled = true
        } else {
            errorlabel.hide()
            cropbusy.showSuccess()
        }
    }

    function showing() {

        if(PQCExtensionProperties.currentFile === "")
            return false

        if(!PQCExtensionMethods.getWritableSuffixes().includes(PQCExtensionProperties.currentFile.split('.').pop().toLowerCase())) {
            PQCExtensionMethods.showNotification(qsTranslate("cropimage", "Cropping not supported"),
                                                 qsTranslate("cropimage", "Cropping of this image format is currently not supported."))
            return false
        }


        cropbusy.hide()
        errorlabel.hide()
        modalButton2Enabled = true

        resizerect.startPos = Qt.point(PQCExtensionProperties.currentVisibleArea.x,
                                       PQCExtensionProperties.currentVisibleArea.y)
        resizerect.endPos = Qt.point(resizerect.startPos.x + PQCExtensionProperties.currentVisibleArea.width,
                                     resizerect.startPos.y + PQCExtensionProperties.currentVisibleArea.height)

        animShowed = false

        if(theimage.status === Image.Ready && !updateStartEndPosBackupAndStart.running)
            updateStartEndPosBackupAndStart.restart()

    }

}
