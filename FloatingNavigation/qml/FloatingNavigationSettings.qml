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
            id: float_show
            text: qsTranslate("floatingnavigation", "show floating navigation")
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
            text: qsTranslate("floatingnavigation", "There are currently no other settings here.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

    }


    Component.onCompleted: {
        float_show.checked = extsettings["ExtShow"]
    }

}
