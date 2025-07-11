import QtQuick
import QtQuick.Controls
import PQCExtensionsHandler
import PhotoQt

PQTemplateExtensionSettings {

    id: settop

    extensionId: "QuickActions"

    property list<string> curEntries: []

    content: [

        PQCheckBox {
            id: quick_show
            text: qsTranslate("settingsmanager", "show quick actions")
            onCheckedChanged: settop.checkHasChanged()
        },

        PQCheckBox {
            id: quick_popout
            text: qsTranslate("settingsmanager", "pop out of main window")
            onCheckedChanged: settop.checkHasChanged()
        },

        Rectangle {
            enabled: quick_show.checked
            x: 10
            width: parent.width-20
            radius: 5
            clip: true

            height: enabled ? 50 : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            opacity: enabled ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            color: PQCLook.baseColorHighlight // qmllint disable unqualified
            ListView {

                id: avail

                x: 5
                y: 5

                width: parent.width-10
                height: parent.height-10

                clip: true
                orientation: ListView.Horizontal
                spacing: 5

                ScrollBar.horizontal: PQHorizontalScrollBar { id: scrollbar }

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

                model: ListModel {
                    id: model
                }

                delegate: Item {
                    id: deleg
                    width: avail.height
                    height: avail.height

                    required property string name
                    required property int index

                    Rectangle {
                        id: dragRect
                        width: avail.height
                        height: avail.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: PQCLook.baseColorActive
                        radius: 5

                        PQTextL {
                            anchors.centerIn: parent
                            visible: deleg.name === "|"
                            text: "|"
                        }

                        Image {
                            x: (parent.width-width)/2
                            y: (parent.height-height)/2
                            width: parent.width*0.8
                            height: parent.height*0.8
                            sourceSize: Qt.size(width, height)
                            source: (deleg.name !== "|" ? ("image://svg/:/" + PQCLook.iconShade + "/" + deleg.name + ".svg") : "")

                            PQMouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                text: avail.disp[deleg.name]
                                drag.target: dragRect
                                drag.axis: Drag.XAxis
                                drag.onActiveChanged: {
                                    if(mouseArea.drag.active) {
                                        avail.dragItemIndex = deleg.index;
                                    }
                                    dragRect.Drag.drop();
                                    if(!mouseArea.drag.active) {
                                        settop.populateModel()
                                    }
                                }
                                cursorShape: Qt.OpenHandCursor
                                onPressed:
                                    cursorShape = Qt.ClosedHandCursor
                                onReleased:
                                    cursorShape = Qt.OpenHandCursor
                            }

                        }

                        states: [
                            State {
                                when: dragRect.Drag.active
                                ParentChange {
                                    target: dragRect
                                    parent: setting_top
                                }

                                AnchorChanges {
                                    target: dragRect
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }
                            }
                        ]

                        Drag.active: mouseArea.drag.active
                        Drag.hotSpot.x: 0
                        Drag.hotSpot.y: 0

                        Image {

                            x: parent.width-width
                            y: 0
                            width: 15
                            height: 15

                            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                            sourceSize: Qt.size(width, height)

                            opacity: closemouse.containsMouse ? 1.0 : 0.8
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Rectangle {
                                anchors.fill: parent
                                z: -1
                                color: "red"
                                radius: 5
                            }

                            PQMouseArea {
                                id: closemouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                text: "Remove entry"
                                onClicked: {
                                    settop.curEntries.splice(deleg.index, 1)
                                    settop.populateModel()
                                    settop.checkHasChanged()
                                }
                            }

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
                        var element = settop.curEntries[avail.dragItemIndex];
                        settop.curEntries.splice(avail.dragItemIndex, 1);
                        settop.curEntries.splice(newindex, 0, element);

                        // visual feedback, move the actual model around
                        avail.model.move(avail.dragItemIndex, newindex, 1)
                        avail.dragItemIndex = newindex
                        settop.checkHasChanged()
                    }
                }
            }
        },

        Row {
            enabled: quick_show.checked
            spacing: 10

            x: 10
            height: enabled ? combo_add.height : 0
            opacity: enabled ? 1 : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            PQComboBox {
                id: combo_add
                y: (but_add.height-height)/2
                width: 600 - but_add.width - 20
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
                text: qsTranslate("settingsmanager", "add")
                smallerVersion: true
                onClicked: {
                    settop.curEntries.push(combo_add.quickdata_keys[combo_add.currentIndex])
                    settop.populateModel()
                    settop.checkHasChanged()
                }
            }
        }

    ]

    // do not make this function typed, it will break
    function areTwoListsEqual(l1, l2) {

        if(l1.length !== l2.length)
            return false

        for(var i = 0; i < l1.length; ++i) {

            if(l1[i].length !== l2[i].length)
                return false

            for(var j = 0; j < l1[i].length; ++j) {
                if(l1[i][j] !== l2[i][j])
                    return false
            }
        }

        return true
    }

    onResetToDefaults: {

        quick_show.checked = settings.getDefaultFor("Show")
        quick_popout.checked = settings.getDefaultFor("Popout")
        settop.curEntries = settings.getDefaultFor("Items")
        populateModel()

        // this is needed to check for model changes
        settop.checkHasChanged()

    }

    function checkHasChanged() {
        if(quick_show.hasChanged() || quick_popout.hasChanged() || !settop.areTwoListsEqual(settop.curEntries, settings["Items"])) {
            settop.hasChanged()
        }
    }

    function loadSettings() {

        quick_show.loadAndSetDefault(settings["Show"])
        quick_popout.loadAndSetDefault(settings["Popout"])

        settop.curEntries = settings["Items"]
        populateModel()

    }

    function saveSettings() {

        var prevStatus = settings["Show"]
        settings["Show"] = quick_show.checked

        settings["Popout"] = quick_popout.checked

        var opts = []
        for(var i = 0; i < model.count; ++i)
            opts.push(model.get(i).name)
        settings["Items"] = opts

        if(quick_show.checked !== prevStatus)
            PQCExtensionsHandler.requestShowingOf(settop.extensionId)

        quick_show.saveDefault()

    }

    function populateModel() {
        model.clear()
        for(var j = 0; j < settop.curEntries.length; ++j)
            model.append({"name": settop.curEntries[j], "index": j})
    }

}
