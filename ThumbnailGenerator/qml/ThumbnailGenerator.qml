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

    id: gen_top

    modalButton2Text: qsTranslate("thumbnailgenerator", "Start generating")

    property string rootfolder: ""
    property string rootfolder_name: ""
    property list<string> allfiles: []
    property int totalfiles: 0
    property int processedfiles: 0
    property string customStatus: ""

    onRootfolderChanged: {
        modalButton2Enabled = (rootfolder!=="")
    }

    property bool processingRunning: false
    property bool processingPaused: false

    onProcessingRunningChanged: {
        modalButton3Enabled = (processingRunning || processingPaused)
    }
    onProcessingPausedChanged: {
        modalButton3Enabled = (processingRunning || processingPaused)
    }

    Column {
        x: 5
        width: parent.width-10

        spacing: 20

        Item {
            width: 1
            height: 1
        }

        PQText {
            width: parent.width
            text: qsTranslate("thumbnailgenerator", "Select a folder and click on the start button. PhotoQt then generates thumbnails of all files in that folder, including all subfolders.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQButton {
            x: (parent.width-width)/2
            extraSmall: true
            text: qsTranslate("thumbnailgenerator", "Change folder")
            onClicked: {
                var ret = PQCExtensionMethods.callAction(extensionId, ["selectFolder", gen_top.rootfolder])
                gen_top.rootfolder = ret[0]
                gen_top.rootfolder_name = ret[1]
            }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                text: gen_top.rootfolder
            }
        }

        PQTextL {
            id: folder
            x: (parent.width-width)/2
            width: gen_top.width-40
            horizontalAlignment: Text.AlignHCenter
            font.weight: PQCLook.fontWeightBold
            elide: Text.ElideMiddle
            text: (gen_top.rootfolder==="" ? "---" : gen_top.rootfolder)
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                text: qsTranslate("thumbnailgenerator", "Selected folder:") + " " + gen_top.rootfolder
            }
        }

        Item { width: 1; height: 10 }

        Row {
            x: (parent.width-width)/2
            spacing: 15
            PQText {
                y: (threads.height-height)/2
                text: qsTranslate("thumbnailgenerator", "Parallel threads:")
            }
            PQSpinBox {
                id: threads
                from: 1
                to: 20
                value: settings["Threads"]
                onValueChanged:
                    settings["Threads"] = value
            }
        }



        Item {
            width: 1
            height: 1
        }

    }

    Item {
        id: workingRect
        visible: gen_top.processingRunning||gen_top.processingPaused||gen_top.customStatus!==""
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: palette.base
            opacity: 0.8
        }

        Column {

            y: (parent.height-height)/2
            width: parent.width

            spacing: 20

            PQTextL {
                visible: gen_top.processingRunning||gen_top.processingPaused||gen_top.customStatus!==""
                x: (parent.width-width)/2
                font.weight: PQCLook.fontWeightBold
                text: gen_top.customStatus!=="" ?
                            gen_top.customStatus :
                            (gen_top.totalfiles===0 ?
                                    qsTranslate("thumbnailgenerator", "loading file list...") :
                                    qsTranslate("thumbnailgenerator", "processed %1 of %2 files").arg(gen_top.processedfiles).arg(gen_top.totalfiles))
            }

            Image {
                visible: (gen_top.processingRunning||gen_top.processingPaused) && gen_top.customStatus===""
                x: (parent.width-width)/2
                width: 20
                height: 20
                sourceSize: Qt.size(width, height)
                source: PQCExtensionMethods.path2ImageProvider(gen_top.baseDir + "/img/" + PQCLook.iconShade + "/gear.svg")
                NumberAnimation on rotation {
                    running: gen_top.processingRunning
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 4000
                }
            }

        }

    }

    property list<int> allsizes: [512, 256, 128, 64]

    Repeater {
        id: generator
        model: 0
        Image {
            id: deleg
            required property int modelData
            visible: false
            property int sizeIndex: 0
            sourceSize: Qt.size(gen_top.allsizes[sizeIndex], gen_top.allsizes[sizeIndex])
            onStatusChanged: {
                if(source === "") return
                if(status == Image.Ready) {
                    var bak = source
                    source = ""
                    if(sizeIndex < gen_top.allsizes.length-1) {
                        sizeIndex += 1
                        source = bak
                    } else {
                        sizeIndex = 0
                        gen_top.loadNextThumbnail(deleg.modelData)
                    }
                }
            }
            Component.onCompleted: {
                if(deleg.modelData < gen_top.allfiles.length)
                    deleg.source = PQCExtensionMethods.path2ImageProvider(gen_top.allfiles[deleg.modelData], true)
            }
            property string bakSource: ""
            Connections {
                target: gen_top
                function onProcessingPausedChanged() {
                    if(gen_top.processingPaused) {
                        deleg.bakSource = deleg.source
                        deleg.source = ""
                    } else
                        deleg.source = deleg.bakSource
                }
            }
        }
    }

    function loadNextThumbnail(index) {

        processedfiles += 1

        var nextIndex = threads.value + processedfiles-1

        if(nextIndex < allfiles.length)
            generator.itemAt(index).source = PQCExtensionMethods.path2ImageProvider(allfiles[nextIndex], true)

        if(processedfiles == totalfiles) {
            gen_top.customStatus = qsTranslate("thumbnailgenerator", "Successfully generated %1 thumbnails.").arg(processedfiles)
            processingRunning = false
            processingPaused = false
            modalButton2Text = qsTranslate("thumbnailgenerator", "Start generating")
        }

    }

    Connections {

        target: PQCExtensionMethods

        function onReplyForAction(id, val) {

            var lst = []
            for(var i = 0; i < val.length; ++i) {
                if(PQCExtensionMethods.getFormatOfFile(val[i]) != "")
                    lst.push(val[i])
            }

            if(lst.length == 0) {
                gen_top.customStatus = qsTranslate("thumbnailgenerator", "No files found.")
                processingRunning = false
                processingPaused = false
                modalButton2Text = qsTranslate("thumbnailgenerator", "Start generating")
            } else {
                gen_top.allfiles = lst
                gen_top.totalfiles = allfiles.length
                generator.model = threads.value
            }
        }

    }

    function modalButton2Action() {

        if(processingRunning) {

            modalButton2Text = qsTranslate("thumbnailgenerator", "Continue")
            processingPaused = true
            processingRunning = false
            customStatus = ""

        } else if(processingPaused) {

            modalButton2Text = qsTranslate("thumbnailgenerator", "Pause")
            processingPaused = false
            processingRunning = true
            customStatus = ""

        } else {

            modalButton2Text = qsTranslate("thumbnailgenerator", "Pause")
            processingPaused = false
            processingRunning = true
            customStatus = ""
            totalfiles = 0
            processedfiles = 0
            generator.model = 0

            PQCExtensionMethods.callActionNonBlocking(extensionId, ["loadFiles", gen_top.rootfolder])

        }

    }

    function modalButton3Action() {

        processingPaused = false
        processingRunning = false
        modalButton2Text = qsTranslate("thumbnailgenerator", "Start generating")


    }

    function hiding() {
        processingPaused = false
        processingRunning = false
        modalButton2Text = qsTranslate("thumbnailgenerator", "Start generating")
    }

    function showing() {
        modalButton2Text = qsTranslate("thumbnailgenerator", "Start generating")
        modalButton3Text = qsTranslate("thumbnailgenerator", "Abort")
        rootfolder = PQCExtensionProperties.currentFolder
        if(rootfolder == "") {
            var ret = PQCExtensionMethods.callAction(extensionId, ["getHomeFolder"])
            rootfolder = ret[0]
            rootfolder_name = ret[1]
        } else
            rootfolder_name = PQCExtensionMethods.callAction(extensionId, ["foldername", rootfolder])
        modalButton2Enabled = true
        modalButton3Enabled = false
        processingPaused = false
        processingRunning = false
        totalfiles = 0
        processedfiles = 0
        customStatus = ""
        return true
    }

}
