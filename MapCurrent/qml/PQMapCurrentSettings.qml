import QtQuick
import QtQuick.Controls
import PhotoQt
import PQCExtensionsHandler

Flickable {

    id: set_top

    anchors.fill: parent
    anchors.margins: 10
    anchors.topMargin: 15

    property string extensionId: "MapCurrent"

    SystemPalette { id: pqtPalette }

    ExtensionSettings {
        id: extsettings
        extensionId: set_top.extensionId
    }

    Column {

        width: parent.width
        spacing: 10

        PQCheckBox {
            id: map_show
            text: qsTranslate("settingsmanager", "show small floating map")
            onCheckedChanged: {
                if(checked !== extsettings["ExtShow"])
                    PQCExtensionsHandler.showExtension(set_top.extensionId)
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
            font.italic: true
            enabled: false
            text: "There are currently no other settings here."
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

    }


    Component.onCompleted: {
        map_show.checked = extsettings["ExtShow"]
    }

}
