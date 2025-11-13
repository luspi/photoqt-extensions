import QtQuick
import PhotoQt
import PQCExtensionsHandler

Flickable {

    id: set_top

    anchors.fill: parent
    anchors.margins: 10
    anchors.topMargin: 15

    property string account: ""

    Column {

        id: col

        width: parent.width

        spacing: 10

        PQText {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: "Below you can see either whether PhotoQt is connected to which user account, or you can initiate the authentication process by clicking on the button below."
        }

        PQText {
            visible: set_top.account !== ""
            text: "Authenticated with: " + set_top.account
        }

        PQButton {
            text: set_top.account==="" ? "Authenticate" : "Forget account"
            onClicked: {
                if(set_top.account == "") {
                    PQCExtensionsHandler.requestCallAction("ImgurCom", ["getAuthorizeUrlForPin"], false)
                    authcol.authshow = true
                    error.err = ""
                } else {
                    PQCExtensionsHandler.requestCallAction("ImgurCom", ["forgetAccount"], false)
                }
            }
        }

        Column {

            id: authcol
            spacing: 10

            clip: true
            height: authshow ? (authinfotxt.height+authpinrow.height+authspacer.height+20) : 0
            Behavior on height { NumberAnimation { duration: 200 } }

            property bool authshow: false

            Item {
                id: authspacer
                width: 1
                height: 10
            }

            PQText {
                id: authinfotxt
                width: set_top.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTranslate("settingsmanager", "Switch to your browser and log into your imgur.com account. Then paste the displayed PIN in the field below. Click on the button above again to reopen the website.")
            }

            Row {
                id: authpinrow
                spacing: 5

                PQLineEdit {
                    id: pinholder
                    placeholderText: "PIN"
                }
                PQButton {
                    id: butsave
                    text: genericStringSave
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.BusyCursor
                    onClicked: {
                        authpinrow.enabled = false
                        PQCExtensionsHandler.requestCallAction("ImgurCom", ["doAuthorizeHandlePin"], false)
                    }
                }
            }

            PQText {
                id: error
                width: set_top.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.weight: PQCLook.fontWeightBold
                color: "red"
                property string err: ""
                visible: err!=""
                text: qsTranslate("settingsmanager", "An error occured:") + " " + err
            }

        }

    }

    Connections {

        target: PQCExtensionsHandler

        function onReplyForAction(extensionId : string, val : var) {

            if(extensionId !== "ImgurCom")
                return

            if(val[0] === "authorizeUrlForPin") {

                Qt.openUrlExternally(val[1])

            } else if(val[0] === "accountForgotten") {

                if(parseInt(val[1]) === 0) {
                    set_top.account = ""
                    error.err = ""
                } else {
                    error.err = val[1]
                }

            } else if(val[0] === "authorizeHandlePin") {

                if(val[1] !== 0) {
                    authpinrow.enabled = true
                    error.err = val[1]
                } else {
                    authpinrow.enabled = true
                    error.err = ""
                    set_top.account = val[2]
                    authcol.authshow = false
                }

            }

        }

    }

}
