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

import PQCExtensionsHandler
import PhotoQt

PQTemplateExtension {

    id: export_top

    content: [

        Flickable {

            id: flickable

            anchors.fill: parent
            clip: true

            contentHeight: insidecont.height+20

            ScrollBar.vertical: PQVerticalScrollBar { }

            Column {

                id: insidecont

                x: ((parent.width-width)/2)
                y: 10

                width: parent.width-10

                spacing: 10

                Rectangle {

                    width: 400
                    height: 200
                    color: "red"

                }

            }

        }

    ]

    onShowing: {
    }

}
