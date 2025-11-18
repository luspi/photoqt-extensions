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

    id: imgur_top

    SystemPalette { id: pqtPalette }

    modalButton2Text: qsTranslate("imgurcom", "Show past uploads")

    property int progresspercentage: 0
    property string errorCode: ""

    property string imageURL: ""
    property string imageDeleteHash: ""

    states: [
        State {
            name: "uploading"
            PropertyChanges {
                statusmessage.opacity: 0
                statusmessage.text: imgur_top.progresspercentage+"%"
            }
            PropertyChanges {
                imgur_top.modalButton1Text: qsTranslate("imgurcom", "Cancel")
            }
        },
        State {
            name: "busy"
            PropertyChanges {
                statusmessage.opacity: 0
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                imgur_top.modalButton1Text: qsTranslate("imgurcom", "Cancel")
            }
        },
        State {
            name: "longtime"
            PropertyChanges {
                statusmessage.opacity: 1
                statusmessage.text: qsTranslate("imgurcom", "This seems to take a long time...") + "<br>" + qsTranslate("imgurcom", "There might be a problem with your internet connection or the imgur.com servers.")
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                imgur_top.modalButton1Text: qsTranslate("imgurcom", "Cancel")
            }
        },
        State {
            name: "error"
            PropertyChanges {
                statusmessage.opacity: 1
                statusmessage.text: qsTranslate("imgurcom", "An Error occurred while uploading image!") + "<br>" + qsTranslate("imgurcom", "Error code:") + " " + imgur_top.errorCode
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                working.animationRunning: false
            }
            PropertyChanges {
                imgur_top.modalButton1Text: qsTranslate("imgurcom", "Close")
            }
        },
        State {
            name: "nointernet"
            PropertyChanges {
                statusmessage.opacity: 1
                statusmessage.text: qsTranslate("imgurcom", "You do not seem to be connected to the internet...") + "<br>" + qsTranslate("imgurcom", "Unable to upload!")
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                working.animationRunning: false
            }
            PropertyChanges {
                imgur_top.modalButton1Text: qsTranslate("imgurcom", "Close")
            }
        },
        State {
            name: "result"
            PropertyChanges {
                statusmessage.opacity: 0
            }
            PropertyChanges {
                working.opacity: 0
            }
            PropertyChanges {
                resultscol.opacity: 1
            }
            PropertyChanges {
                imgur_top.modalButton1Text: qsTranslate("imgurcom", "Close")
            }
        }

    ]

    state: "uploading"

    contentHeight: insidecont.height>parent.height ? insidecont.height : parent.height

    Column {

        id: resultscol

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        opacity: 0

        spacing: 10

        PQTextL {
            text: qsTranslate("imgurcom", "Access Image")
            font.weight: PQCLook.fontWeightBold
        }

        Row {

            spacing: 10

            PQTextL {
                id: result_access
                text: imgur_top.imageURL
                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    text: qsTranslate("imgurcom", "Click to open in browser")
                    onClicked:
                    Qt.openUrlExternally(imgur_top.imageURL)
                }
            }

            PQButtonIcon {
                id: copy1
                width: result_access.height
                height: width
                source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
                onClicked: PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["copyTextToClipboard", imgur_top.imageURL])
            }

        }

        Item {
            width: 1
            height: 10
        }

        PQTextL {
            text: qsTranslate("imgurcom", "Delete Image")
            font.weight: PQCLook.fontWeightBold
        }

        Row {

            spacing: 10

            PQTextL {
                id: result_delete
                text: "https://imgur.com/delete/" + imgur_top.imageDeleteHash
                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    text: qsTranslate("imgurcom", "Click to open in browser")
                    onClicked:
                    Qt.openUrlExternally("https://imgur.com/delete/" + imgur_top.imageDeleteHash)
                }
            }

            PQButtonIcon {
                id: copy2
                width: result_delete.height
                height: width
                source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
                onClicked: PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["copyTextToClipboard", imgur_top.imageDeleteHash])
            }

        }

    }

    // The busy indicator
    PQWorking {
        id: working

        anchors.bottomMargin: imgur_top.bottomrowHeight
        anchors.topMargin:  imgur_top.toprowHeight

        PQTextL {
            id: progressbar
            anchors.centerIn: parent
            font.weight: PQCLook.fontWeightBold
            text: imgur_top.progresspercentage + "%"
        }

    }

    // Some status message
    PQText {
        id: statusmessage
        x: (parent.width-width)/2
        y: (parent.height-height)/2 + working.circleHeight*0.8
        horizontalAlignment: Text.AlignHCenter
        font.weight: PQCLook.fontWeightBold
    }

    // a fullscreen overlay to show past (cached) uploads
    Rectangle {

        id: imgurpast

        anchors.fill: parent
        color: pqtPalette.alternateBase

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        // no past uploads available
        PQTextL {
            visible: pastview.dat.length==0
            anchors.centerIn: parent
            //: The uploads are uploads to imgur.com
            text: qsTranslate("imgurcom", "No past uploads found")
            font.weight: PQCLook.fontWeightBold
        }

        Column {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            ListView {

                id: pastview

                property list<var> dat: []
                model: dat.length
                spacing: 10

                clip: true

                width: 600
                height: Math.min(imgurpast.height-200, 500)

                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

                delegate:
                Rectangle {

                    id: deleg

                    required property int modelData

                    property list<var> curdata: pastview.dat[modelData]
                    Component.onCompleted:
                        console.warn("curdata =", curdata)

                    x: 5
                    width: pastview.width-10
                    height: delegcol.height+10
                    color: pqtPalette.base
                    radius: 5

                    // A small button to remove this entry from the cache
                    Image {
                        x: parent.width-width-5
                        y: 5
                        width: 26
                        height: 26
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                        opacity: 0.5
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: parent.opacity = 1
                            onExited: parent.opacity = 0.5
                            onClicked: {
                                PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["deletePastUploadEntry", deleg.curdata[0]])
                            }
                        }
                    }

                    Column {

                        id: delegcol

                        x: 5
                        y: 5

                        // the date of the upload
                        PQTextS {
                            text: deleg.curdata[1]
                            font.weight: PQCLook.fontWeightBold
                        }

                        Row {
                            spacing: 10

                            // the cached thumbnail
                            Image {
                                width: 75
                                height: 75
                                fillMode: Image.PreserveAspectFit
                                source: "file:/" + deleg.curdata[4]
                            }

                            Column {

                                y: (75-height)/2
                                spacing: 5

                                // access the image
                                Row {
                                    PQText {
                                        id: acctxt
                                        //: Used as in: access this image
                                        text: qsTranslate("imgurcom", "Access:") + " "
                                    }
                                    PQText {
                                        font.weight: PQCLook.fontWeightBold
                                        text: deleg.curdata[2]
                                        PQMouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            text: qsTranslate("imgurcom", "Click to open in browser")
                                            onClicked:
                                            Qt.openUrlExternally(deleg.curdata[2])
                                        }
                                    }
                                    Item {
                                        width: 10
                                        height: 1
                                    }
                                    PQButtonIcon {
                                        id: copy3
                                        width: acctxt.height
                                        height: width
                                        source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
                                        onClicked:
                                            PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["copyTextToClipboard", deleg.curdata[2]])
                                    }
                                }

                                // delete the image
                                Row {
                                    PQText {
                                        id: deltxt
                                        //: Used as in: delete this image
                                        text: qsTranslate("imgurcom", "Delete:") + " "
                                    }
                                    PQText {
                                        font.weight: PQCLook.fontWeightBold
                                        text: "https://imgur.com/delete/" + deleg.curdata[3]
                                        PQMouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            text: qsTranslate("imgurcom", "Click to open in browser")
                                            onClicked:
                                            Qt.openUrlExternally("https://imgur.com/delete/" + deleg.curdata[3])
                                        }
                                    }
                                    Item {
                                        width: 10
                                        height: 1
                                    }
                                    PQButtonIcon {
                                        id: copy4
                                        width: deltxt.height
                                        height: width
                                        source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
                                        onClicked:
                                        PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["copyTextToClipboard", deleg.curdata[3]])
                                    }
                                }

                            }
                        }
                    }

                }



            }

            // close and clear buttons
            Row {
                x: (parent.width-width)/2
                PQButton {
                    id: closebutton
                    text: genericStringClose
                    onClicked: {
                        imgurpast.hide()
                    }
                }
                PQButton {
                    id: clearbutton
                    //: Written on button, please keep short. Used as in: clear all entries
                    text: qsTranslate("imgurcom", "Clear all")
                    onClicked: {
                        PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["deletePastUploadEntry", "xxx"])
                    }
                }
            }

        }

        function show() {
            opacity = 1
            PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["getPastUploads"])
        }

        function hide() {
            opacity = 0
        }

    }

    Timer {
        id: showLongTimeMessage
        interval: 10000
        onTriggered: {
            imgur_top.state = "longtime"
        }
    }

    Connections {

        target: PQCExtensionMethods

        function onReplyForAction(extensionId : string, val : var) {

            if(extensionId !== imgur_top.extensionId)
                return

            console.log("args: val =", val);

            if(val[0] === "noInternet") {

                working.showFailure(true)
                imgur_top.state = "nointernet"

            } else if(val[0] === "setupError") {

                working.showFailure(true)
                showLongTimeMessage.stop()
                imgur_top.errorCode = "Setup (" + val[1] + ")"
                imgur_top.state = "error"

            } else if(val[0] === "pastUploads") {

                pastview.dat = val[1]

            } else if(val[0] === "deletedPastEntry") {

                PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["getPastUploads"])

            }

        }

        function onReceivedMessage(extensionId : string, val : var) {

            if(extensionId !== imgur_top.extensionId)
                return

            console.log("args: val =", val);

            if(val[0] === "uploadError") {

                working.showFailure(true)
                showLongTimeMessage.stop()
                imgur_top.errorCode = "Upload (" + val[1] + ")"
                imgur_top.state = "error"

            } else if(val[0] === "progress") {

                showLongTimeMessage.restart()

                imgur_top.state = "uploading"

                var p = Math.round(parseFloat(val[1])*100)
                imgur_top.progresspercentage = p

                if(p >= 99)
                    imgur_top.state = "busy"

            } else if(val[0] === "url") {

                console.log("imgur.com image url:", val[1])
                imgur_top.imageURL = val[1]

            } else if(val[0] === "deleteHash") {

                console.log("imgur.com delete hash:", val[1])
                imgur_top.imageDeleteHash = val[1]

            } else if(val[0] === "uploadFinished") {

                showLongTimeMessage.stop()
                if(imgur_top.errorCode == "") {
                    working.hide()
                    imgur_top.state = "result"
                    PQCExtensionMethods.requestCallActionWithImage(imgur_top.extensionId, ["saveToHistory", imgur_top.imageURL, imgur_top.imageDeleteHash])
                }

            }

        }

    }

    function modalButton1Action() {

    }

    function modalButton2Action() {
        imgurpast.show()
    }

    function showing() {

        if(PQCExtensionProperties.currentFile === "")
            return false

        imgurpast.opacity = 0
        errorCode = ""
        progresspercentage = 0
        imageURL = ""
        imageDeleteHash = ""

        state = "uploading"
        working.showBusy()

        PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["start",
                                               settings["AccessToken"], settings["RefreshToken"], settings["AccountName"],
                                               settings["AuthDateTime"]],
                                               false);

    }

    function hiding() {

        if(imgurpast.visible) {
            imgurpast.hide()
            return false
        }

        PQCExtensionMethods.requestCallAction(imgur_top.extensionId, ["interruptUpload"])

    }

}
