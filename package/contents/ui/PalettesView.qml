import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    property var palettes: []
    property var clipboard

    signal updatePalettes(var palettes)

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: palettes || []  // Add null check
        delegate: Controls.ItemDelegate {
            width: ListView.view.width
            ColumnLayout {
                Controls.Label { text: modelData.name || "Unnamed" }
                RowLayout {
                    Repeater {
                        model: modelData.colors || []
                        Rectangle {
                            width: 20
                            height: 20
                            color: modelData.color || "transparent"
                        }
                    }
                }
            }
            onClicked: paletteDetailSheet.openForPalette(index)
        }
    }

    Controls.Button {
        Layout.alignment: Qt.AlignHCenter
        text: "+ New Palette"
        onClicked: {
            let dialog = newPaletteSheet.createObject(root.parent, { withInitialColor: false })
            dialog.accepted.connect(function() {
                let newPalette = {name: dialog.paletteName || "New Palette", colors: []}
                let newPalettes = (palettes || []).slice()
                newPalettes.push(newPalette)
                root.updatePalettes(newPalettes)
                dialog.close()
            })
            dialog.open()
        }
    }

    Component {
        id: newPaletteSheet
        NewPaletteSheet { }
    }

    Kirigami.OverlaySheet {
        id: paletteDetailSheet
        property int paletteIndex: -1
        function openForPalette(index) {
            paletteIndex = index
            open()
        }

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            opacity: 0.95
            radius: Kirigami.Units.smallSpacing * 2
            border.color: Kirigami.Theme.textColor
            border.width: 1
        }

        onOpened: {
            if (parent) {
                x = (parent.width - width) / 2
                y = (parent.height - height) / 2
            }
        }

        PaletteDetail {
            anchors.fill: parent
            palette: (palettes || [])[paletteDetailSheet.paletteIndex] || {name: "", colors: []}  // Add null check for palettes
            clipboard: root.clipboard
            onUpdatePalette: function(palette) {
                let newPalettes = (palettes || []).slice()
                newPalettes[paletteDetailSheet.paletteIndex] = palette
                root.updatePalettes(newPalettes)
            }
            onDeleteRequested: {
                let newPalettes = (palettes || []).slice()
                newPalettes.splice(paletteDetailSheet.paletteIndex, 1)
                root.updatePalettes(newPalettes)
                paletteDetailSheet.close()
            }
            onCloneRequested: {
                let clone = {name: palette.name + " Copy", colors: (palette.colors || []).slice()}
                let newPalettes = (palettes || []).slice()
                newPalettes.push(clone)
                root.updatePalettes(newPalettes)
                paletteDetailSheet.close()
            }
        }
    }
}