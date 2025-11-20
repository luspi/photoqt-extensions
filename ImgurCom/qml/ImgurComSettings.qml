import QtQuick
import PhotoQt

PQTemplateExtensionSettings {

    id: set_top

    contentHeight: col.height

    property string account: ""

    Column {

        id: col

        width: parent.width

        spacing: 10

        Item {
            width: 1
            height: 10
        }

        PQTextL {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            enabled: false
            text: qsTranslate("imgurcom", "Unfortunately it is currently only possible to upload images to imgur.com anonymously from within PhotoQt.")
        }



    }

}
