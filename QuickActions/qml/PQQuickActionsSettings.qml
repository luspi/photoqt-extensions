import QtQuick
import QtQuick.Controls
import PhotoQt

Flickable {

    id: set_top

    anchors.fill: parent
    anchors.margins: 10
    anchors.topMargin: 15

    property string extensionId: "QuickActions"

    SystemPalette { id: pqtPalette }

    contentHeight: col.height

    property list<string> curEntries: []
    onCurEntriesChanged: saveModelDelay.restart()

    Timer {
        id: saveModelDelay
        interval: 500
        onTriggered:
            set_top.saveModel()
    }

    ExtensionSettings {
        id: extsettings
        extensionId: set_top.extensionId
    }

    Column {

        id: col

        width: parent.width

        spacing: 10

        PQCheckBox {
            id: quick_show
            text: qsTranslate("quickactions", "show quick actions")
            onCheckedChanged: {
                if(checked !== extsettings["ExtShow"])
                    PQCExtensionMethods.runExtension(set_top.extensionId)
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: pqtPalette.text
            opacity: 0.4
        }

        PQText {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("quickactions", "Quick Actions can have any desired order. Some actions refer to other extensions and only function if that extension is installed and enabled. Note that any changes are applied automatically.")
        }

        ListView {

            id: avail

            width: parent.width
            height: 50

            clip: true
            orientation: ListView.Horizontal
            spacing: 5
            enabled: quick_show.checked

            ScrollBar.vertical: PQVerticalScrollBar { id: scrollbar }

            property int dragItemIndex: -1

            property list<int> heights: []

            property list<int> deleted: []

            property var disp: {
                "|"           : "["+qsTranslate("quickactions", "separator") + "]",
                "rename"      : qsTranslate("quickactions", "Rename file"),
                "copy"        : qsTranslate("quickactions", "Copy file"),
                "move"        : qsTranslate("quickactions", "Move file"),
                "delete"      : qsTranslate("quickactions", "Delete file"),
                "rotateleft"  : qsTranslate("quickactions", "Rotate left"),
                "rotateright" : qsTranslate("quickactions", "Rotate right"),
                "mirrorhor"   : qsTranslate("quickactions", "Mirror horizontally"),
                "mirrorver"   : qsTranslate("quickactions", "Mirror vertically"),
                "crop"        : qsTranslate("quickactions", "Crop image"),
                "scale"       : qsTranslate("quickactions", "Scale image"),
                "tagfaces"    : qsTranslate("quickactions", "Tag faces"),
                "clipboard"   : qsTranslate("quickactions", "Copy to clipboard"),
                "export"      : qsTranslate("quickactions", "Export to different format"),
                "wallpaper"   : qsTranslate("quickactions", "Set as wallpaper"),
                "qr"          : qsTranslate("quickactions", "Detect/hide QR/barcodes"),
                "close"       : qsTranslate("quickactions", "Close window"),
                "quit"        : qsTranslate("quickactions", "Quit")
            }

            property var svgs: {
                "|"           : "",
                "rename"      : "rename",
                "copy"        : "copy",
                "move"        : "move",
                "delete"      : "delete",
                "rotateleft"  : "rotateleft",
                "rotateright" : "rotateright",
                "mirrorhor"   : "leftrightarrow",
                "mirrorver"   : "updownarrow",
                "crop"        : "crop",
                "scale"       : "scale",
                "tagfaces"    : "faces",
                "clipboard"   : "copy",
                "export"      : "convert",
                "wallpaper"   : "wallpaper",
                "qr"          : "qrcode",
                "close"       : "quit",
                "quit"        : "quit"
            }

            model: ListModel {
                id: model
            }

            delegate: Item {
                id: deleg
                width: name==="|" ? 8 : 50
                height: 50

                required property string name
                required property int index

                Rectangle {
                    anchors.fill: parent
                    color: pqtPalette.text
                    opacity: 0.2
                    radius: 5
                }

                PQMouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton|Qt.RightButton
                    drag.target: deleg
                    drag.axis: Drag.XAxis
                    drag.onActiveChanged: {
                        if(mouseArea.drag.active) {
                            avail.dragItemIndex = deleg.index;
                        }
                        deleg.Drag.drop();
                        if(!mouseArea.drag.active) {
                            set_top.populateModel()
                        }
                    }
                    text: "<b>" + avail.disp[deleg.name] + "</b><br>" + qsTranslate("quickactions", "Click-and-drag to reorder, right click for more options")
                    cursorShape: Qt.OpenHandCursor
                    onPressed:
                        cursorShape = Qt.ClosedHandCursor
                    onReleased:
                        cursorShape = Qt.OpenHandCursor
                    onClicked: (mouse) => {
                        if(mouse.button == Qt.RightButton)
                            contextmenu.popup()
                    }
                }

                Image {

                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    visible: deleg.name!=="|"
                    width: visible ? 40 : 0
                    height: visible ? 40 : 0
                    opacity: quick_show.checked ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    source: visible ? ("image://svg/" + PQCExtensionsMethods.getExtensionLocation(set_top.extensionId) + "/img/"  + PQCLook.iconShade + "/" + avail.svgs[deleg.name] + ".svg") : ""
                    sourceSize: Qt.size(width, height)

                }

                Rectangle {
                    visible: deleg.name==="|"
                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    width: visible ? parent.width : 0
                    height: visible ? 40 : 0
                    opacity: quick_show.checked ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    color: pqtPalette.text
                }

                states: [
                    State {
                        when: deleg.Drag.active
                        ParentChange {
                            target: deleg
                            parent: avail
                        }

                        AnchorChanges {
                            target: deleg
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]

                Drag.active: mouseArea.drag.active
                Drag.hotSpot.x: 0
                Drag.hotSpot.y: 0

                PQMenu {
                    id: contextmenu
                    PQMenuItem {
                        text: qsTranslate("quickactions", "Remove entry")
                        onClicked: {
                            set_top.curEntries.splice(deleg.index, 1)
                            set_top.populateModel()
                        }
                    }
                }

            }

            DropArea {
                id: dropArea
                anchors.fill: parent
                onPositionChanged: (drag) => {
                    var newindex = avail.indexAt(drag.x, drag.y)
                    if(newindex !== -1 && newindex !== avail.dragItemIndex) {

                        // we move the entry around in the list for the populate call later
                        var element = set_top.curEntries[avail.dragItemIndex];
                        set_top.curEntries.splice(avail.dragItemIndex, 1);
                        set_top.curEntries.splice(newindex, 0, element);

                        // visual feedback, move the actual model around
                        avail.model.move(avail.dragItemIndex, newindex, 1)
                        avail.dragItemIndex = newindex
                    }
                }
            }

        }

        Row {
            spacing: 5
            PQComboBox {
                id: combo_add
                y: (but_add.height-height)/2
                width: 300
                enabled: quick_show.checked
                property list<string> quickdata_keys: [
                    "rename",
                    "copy",
                    "move",
                    "delete",
                    "rotateleft",
                    "rotateright",
                    "mirrorhor",
                    "mirrorver",
                    "crop",
                    "scale",
                    "tagfaces",
                    "clipboard",
                    "export",
                    "wallpaper",
                    "qr",
                    "close",
                    "quit",
                    "|"
                ]
                property list<string> quickdata_vals: [
                    qsTranslate("quickactions", "Rename file"),
                    qsTranslate("quickactions", "Copy file"),
                    qsTranslate("quickactions", "Move file"),
                    qsTranslate("quickactions", "Delete file"),
                    qsTranslate("quickactions", "Rotate left"),
                    qsTranslate("quickactions", "Rotate right"),
                    qsTranslate("quickactions", "Mirror horizontally"),
                    qsTranslate("quickactions", "Mirror vertically"),
                    qsTranslate("quickactions", "Crop image"),
                    qsTranslate("quickactions", "Scale image"),
                    qsTranslate("quickactions", "Tag faces"),
                    qsTranslate("quickactions", "Copy to clipboard"),
                    qsTranslate("quickactions", "Export to different format"),
                    qsTranslate("quickactions", "Set as wallpaper"),
                    qsTranslate("quickactions", "Detect/hide QR/barcodes"),
                    qsTranslate("quickactions", "Close window"),
                    qsTranslate("quickactions", "Quit"),
                    "["+qsTranslate("quickactions", "separator") + "]"
                ]
                model: quickdata_vals
            }

            PQButton {
                id: but_add
                //: This is written on a button that is used to add a selected block to the status info section.
                text: qsTranslate("quickactions", "add")
                enabled: quick_show.checked
                smallerVersion: true
                onClicked: {
                    set_top.curEntries.push(combo_add.quickdata_keys[combo_add.currentIndex])
                    set_top.populateModel()
                }
            }
        }
    }

    Component.onCompleted: {

        quick_show.checked = extsettings["ExtShow"]

        set_top.curEntries = extsettings["Items"]
        populateModel()
    }

    function populateModel() {
        model.clear()
        for(var j = 0; j < set_top.curEntries.length; ++j)
            model.append({"name": set_top.curEntries[j], "index": j})
        set_top.curEntriesChanged()
    }

    function saveModel() {
        extsettings["Items"] = curEntries
    }

}
