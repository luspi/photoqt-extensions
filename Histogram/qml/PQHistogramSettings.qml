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
            id: hist_show
            text: qsTranslate("histogram", "show histogram")
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
            enabled: hist_show.checked
            width: parent.width
            text: qsTranslate("histogram", "The Histogram can either show the RGB colors separately (but overlayed) or all combined into a grayscale histogram.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        PQRadioButton {
            id: histCol
            enabled: hist_show.checked
            text: qsTranslate("histogram", "color version")
            onCheckedChanged: {
                if(checked && extsettings["Version"] !== "color")
                    extsettings["Version"] = "color"
            }
        }

        PQRadioButton {
            id: histGray
            enabled: hist_show.checked
            text: qsTranslate("histogram", "greyscale version")
            onCheckedChanged: {
                if(checked && extsettings["Version"] !== "grey")
                    extsettings["Version"] = "grey"
            }
        }

    }


    Component.onCompleted: {
        hist_show.checked = extsettings["ExtShow"]
        histCol.checked = extsettings["Version"]==="color"
        histGray.checked = extsettings["Version"]==="grey"
    }

}
