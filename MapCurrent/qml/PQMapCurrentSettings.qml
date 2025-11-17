import QtQuick
import QtQuick.Controls
import PhotoQt

PQTemplateExtensionSettings {

    id: set_top

    contentHeight: col.height

    SystemPalette { id: pqtPalette }

    ExtensionSettings {
        id: extsettings
        extensionId: set_top.extensionId
    }

    Column {

        id: col

        width: parent.width
        spacing: 10

        PQCheckBox {
            id: map_show
            text: qsTranslate("mapcurrent", "show small floating map")
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
            font.italic: true
            enabled: false
            text: qsTranslate("mapcurrent", "There are currently no other settings here.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

    }


    Component.onCompleted: {
        map_show.checked = extsettings["ExtShow"]
    }

}
