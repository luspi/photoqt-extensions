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

    id: export_top

    modalButton2Text: qsTranslate("export", "Export")

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    /***************************************************************/

    // the favs are shown on a label and are used to identify the respective entry in the listview
    property list<string> favs: settings["Favorites"]

    // this is the selected format, both the first ending (for identification) and all endings for a format
    property string targetFormat: settings["LastUsed"]

    contentHeight: insidecont.height>parent.height ? insidecont.height : parent.height

    Column {

        id: insidecont

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        width: parent.width-10

        spacing: 10

        /*****************************************************/
        // error message

        Item {
            visible: errormessage.visible
            width: 1
            height: 10
        }

        PQTextL {
            id: errormessage
            visible: false
            x: (parent.width-width)/2
            width: favs_item.width
            horizontalAlignment: Qt.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("export", "Something went wrong during export to the selected format...")
            font.weight: PQCLook.fontWeightBold
        }

        Item {
            visible: errormessage.visible
            width: 1
            height: 10
        }

        /*****************************************************/
        // at first we list any selected favorites

        Item {

            id: favs_item

            x: (parent.width-width)/2

            width: favs_col.width
            height: favs_col.height

            Column {

                id: favs_col

                spacing: 10

                PQText {
                    width: Math.min(600, export_top.width-100)
                    //: These are the favorite image formats for exporting images to
                    text: qsTranslate("export", "Favorites:")
                }

                // only shown when no favorites are set
                PQText {
                    width: favcol.width
                    height: 30
                    color: pqtPalette.text
                    font.weight: PQCLook.fontWeightBold
                    font.italic: true
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    //: the favorites are image formats for exporting images to
                    text: " " + qsTranslate("export", "no favorites set")
                    visible: export_top.favs.length===0
                }

                // all favorites
                Column {
                    id: favcol
                    width: Math.min(600, export_top.width-100)
                    spacing: 5

                    property int currentIndex: -1
                    property int currentHover: -1

                    Timer {
                        id: resetFavsHighlightIndex
                        interval: 100
                        property int oldIndex
                        onTriggered: {
                            if(favcol.currentHover==oldIndex)
                                favcol.currentHover = -1
                        }
                    }

                    onCurrentHoverChanged: {
                        if(favcol.currentHover !== -1)
                            formatsview.currentHover = -1
                    }

                    Repeater {

                        model: export_top.favs.length

                        Rectangle {

                            id: favdeleg

                            required property int modelData

                            property string myid: export_top.favs[modelData]

                            width: favcol.width
                            height: favsrow.height+10
                            radius: 5

                            property bool hovered: favcol.currentHover===modelData
                            property bool isActive: export_top.targetFormat===favdeleg.myid

                            color: isActive ? PQCLook.baseBorder : (hovered ? pqtPalette.alternateBase : pqtPalette.button)

                            Row {
                                id: favsrow
                                x: 5
                                y: 5
                                spacing: 10
                                PQText {
                                    text: "*." + PQCExtensionMethods.getImageFormatEndings(favdeleg.myid).join(", *.")
                                }
                                PQTextS {
                                    y: (parent.height-height)/2
                                    font.italic: true
                                    text: "(" + PQCExtensionMethods.getImageFormatName(favdeleg.myid) + ")"
                                }
                            }
                            Image {
                                id: rem
                                x: parent.width-width-5-scroll.width
                                y: (parent.height-height)/2
                                width: 20
                                height: 20
                                property bool hovered: false
                                opacity: hovered ? 1 : 0.5
                                source: "image://svg/:/" + PQCLook.iconShade + "/star.svg"
                                sourceSize: Qt.size(width, height)
                            }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                text: qsTranslate("export", "Click to select this image format")
                                onEntered: {
                                    resetFavsHighlightIndex.stop()
                                    favcol.currentHover = favdeleg.modelData
                                }
                                onExited: {
                                    resetFavsHighlightIndex.oldIndex = favdeleg.modelData
                                    resetFavsHighlightIndex.restart()
                                }
                                onClicked: {
                                    export_top.targetFormat = export_top.favs[favdeleg.modelData]
                                    favcol.currentIndex = favdeleg.modelData
                                    formatsview.currentIndex = -1
                                }
                            }

                            PQMouseArea {
                                anchors.fill: rem
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: rem.hovered = true
                                onExited: rem.hovered = false
                                text: qsTranslate("export", "Click to remove this image format from your favorites")
                                onClicked: {
                                    export_top.settings["Favorites"].splice(favdeleg.modelData, 1)
                                }
                            }
                        }
                    }
                }

            }

        }

        Item {
            width: 1
            height: 20
        }

        /*************************************************/
        // then we list all available writable formats

        Rectangle {

            x: (parent.width-width)/2
            width: Math.min(600, export_top.width-100)
            height: Math.max(200, Math.min(400, export_top.parent.height-targettxt1.height-targettxt2.height-favs_item.height-120))

            color: pqtPalette.base
            border.width: 1
            border.color: PQCLook.baseBorder

            ListView {

                id: formatsview

                anchors.fill: parent
                anchors.margins: 1

                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

                property list<var> thedata: PQCExtensionMethods.getImageFormatsThatAreWriteable()
                model: thedata.length

                clip: true

                property int currentHover: -1
                Timer {
                    id: resetCurrentHover
                    interval: 100
                    property int oldIndex
                    running: true
                    onTriggered: {
                        if(oldIndex === formatsview.currentHover)
                            formatsview.currentHover = -1
                    }
                }

                onCurrentHoverChanged: {
                    if(formatsview.currentHover !== -1) {
                        formatsview.positionViewAtIndex(formatsview.currentHover, ListView.Contain)
                            favcol.currentHover = -1
                    }
                }

                delegate: Rectangle {

                    id: deleg

                    required property int modelData

                    property list<var> curData: formatsview.thedata[modelData]
                    property string curUniqueid: curData[1]
                    property list<string> curEndings: curData[2].split(",")
                    property bool isFav: export_top.favs.indexOf(curUniqueid)!==-1

                    property bool isActive: curUniqueid===export_top.targetFormat
                    property bool isHover: formatsview.currentHover===modelData

                    width: formatsview.width
                    height: visible ? (formatsname.height+10) : 0
                    color: isActive ? PQCLook.baseBorder : (isHover ? pqtPalette.alternateBase : pqtPalette.button)
                    border.width: 1
                    border.color: "black"
                    radius: 5

                    Row {
                        id: formatsname
                        x: 5
                        y: 5
                        spacing: 10
                        PQText {
                            text: "*." + deleg.curEndings.join(", *.")
                        }
                        PQTextS {
                            y: (parent.height-height)/2
                            font.italic: true
                            text: "(" + deleg.curData[3] + ")"
                        }
                    }

                    Image {
                        id: favs_icon
                        x: (parent.width-width-5) - scroll.width
                        y: (parent.height-height)/2
                        height: formatsname.height
                        width: height
                        opacity: favmousearea.containsMouse ? 1 : 0.5
                        sourceSize: Qt.size(width, height)
                        source: deleg.isFav ? ("image://svg/:/" + PQCLook.iconShade + "/star.svg") : ("image://svg/:/" + PQCLook.iconShade + "/star_empty.svg")
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: "<b>" + deleg.curData[3] + "</b><br>*." + deleg.curEndings.join(", *.") + "<br><br>" + qsTranslate("export", "Click to select this image format")
                        onEntered: {
                            resetCurrentHover.stop()
                            formatsview.currentHover = deleg.modelData
                        }
                        onExited: {
                            resetCurrentHover.oldIndex = deleg.modelData
                            resetCurrentHover.restart()
                        }

                        onClicked: {
                            formatsview.currentIndex = deleg.modelData
                                if(deleg.modelData !== -1)
                                    export_top.targetFormat = deleg.curUniqueid
                        }
                    }

                    PQMouseArea {
                        id: favmousearea
                        anchors.fill: favs_icon
                        anchors.margins: -5
                        cursorShape: Qt.PointingHandCursor
                        text: deleg.isFav ? qsTranslate("export", "Click to remove this image format from your favorites")
                        : qsTranslate("export", "Click to add this image format to your favorites")
                        onClicked: {
                            var tmp = export_top.settings["Favorites"]
                            if(isFav)
                                tmp.splice(tmp.indexOf(deleg.curUniqueid), 1)
                                else
                                    tmp.push(deleg.curUniqueid)
                                    export_top.settings["Favorites"] = tmp
                        }
                    }

                }

            }

        }

        Item {
            width: 1
            height: 10
        }

        PQText {
            id: targettxt1
            x: (parent.width-width)/2
            //: The target format is the format the image is about to be exported to
            text: qsTranslate("export", "Selected target format:")
        }

        PQText {
            id: targettxt2
            x: (parent.width-width)/2
            text: (export_top.targetFormat==="" ? "---" : PQCExtensionMethods.getImageFormatName(export_top.targetFormat))
            font.weight: PQCLook.fontWeightBold
        }

    }

    PQWorking {
        id: exportbusy
    }

    Connections {
        target: exportbusy
        function onSuccessHidden() {
            export_top.hide()
        }
    }

    Connections {

        target: PQCExtensionMethods

        function onReceivedShortcut(combo : string) {
            if(!export_top.visible) return
            if(combo === "Enter" || combo === "Return") {
                export_top.modalButton2Action()
            }
        }

        function onReplyForActionWithImage(id, val) {
            if(id !== export_top.extensionId)
                return
            if(val) {
                errormessage.visible = false
                exportbusy.showSuccess()
            } else {
                exportbusy.hide()
                errormessage.visible = true
            }
        }

    }

    function modalButton2Action() {

        if(targetFormat === "") return

        settings["LastUsed"] = targetFormat

        errormessage.visible = false

        var val = PQCExtensionMethods.callAction(export_top.extensionId,
                                                 [PQCExtensionProperties.currentFile,
                                                  PQCExtensionMethods.getImageFormatName(parseInt(targetFormat)),
                                                  PQCExtensionMethods.getImageFormatEndings(parseInt(targetFormat))])

        if(val === "")
            return

        var info = PQCExtensionMethods.getImageFormatInfo(parseInt(export_top.targetFormat))

        exportbusy.showBusy()
        PQCExtensionMethods.callActionWithImageNonBlocking(extensionId, [val, info["ëndings"], info["qt"], info["qt_formatname"], info["imagemagick"], info["graphicsmagick"], info["im_gm_magick"]])

    }

    function showing() {
        if(PQCExtensionProperties.currentFile === "")
            return false
        exportbusy.hide()
        errormessage.visible = false
    }

}
