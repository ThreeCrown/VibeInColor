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
        model: palettes ? palettes : []
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
            let dialog = newPaletteDialog.component.createObject(root)
            dialog.open()
        }
    }

    Kirigami.OverlaySheet {
        id: paletteDetailSheet
        property int paletteIndex: -1
        function openForPalette(index) {
            paletteIndex = index
            open()
        }

        PaletteDetail {
            anchors.fill: parent
            palette: palettes[paletteDetailSheet.paletteIndex] || {name: "", colors: []}
            clipboard: root.clipboard
            onUpdatePalette: function(palette) {
                let newPalettes = palettes.slice()
                newPalettes[paletteDetailSheet.paletteIndex] = palette
                root.updatePalettes(newPalettes)
            }
            onDeleteRequested: {
                let newPalettes = palettes.slice()
                newPalettes.splice(paletteDetailSheet.paletteIndex, 1)
                root.updatePalettes(newPalettes)
                paletteDetailSheet.close()
            }
            onCloneRequested: {
                let clone = {name: palette.name + " Copy", colors: palette.colors.slice()}
                let newPalettes = palettes.slice()
                newPalettes.push(clone)
                root.updatePalettes(newPalettes)
                paletteDetailSheet.close()
            }
        }
    }

    Component {
        id: newPaletteDialog
        Kirigami.OverlaySheet {
            implicitWidth: Kirigami.Units.gridUnit * 20  // Reasonable fixed width
            title: "New Palette Name"
            ColumnLayout {  // Switched to ColumnLayout to avoid loops
                Controls.Label { text: "Palette name:" }  // Optional explicit label
                Controls.TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Palette name"
                }
                Controls.Button {
                    Layout.alignment: Qt.AlignRight
                    text: "Create"
                    onClicked: {
                        let newPalette = {name: nameField.text || "New Palette", colors: []}
                        let newPalettes = palettes.slice()
                        newPalettes.push(newPalette)
                        root.updatePalettes(newPalettes)
                        close()
                    }
                }
            }
        }
    }
}