import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    property var palettes: []
    signal updatePalettes(var palettes)

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: palettes
        delegate: Controls.ItemDelegate {
            width: ListView.view.width
            ColumnLayout {
                Controls.Label { text: modelData.name }
                RowLayout {
                    Repeater {
                        model: modelData.colors
                        Rectangle {
                            width: 20
                            height: 20
                            color: modelData.color
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
            palette: palettes[paletteIndex]
            onPaletteChanged: {
                let newPalettes = palettes.slice()
                newPalettes[paletteIndex] = palette
                root.updatePalettes(newPalettes)
            }
            onDeleteRequested: {
                let newPalettes = palettes.slice()
                newPalettes.splice(paletteIndex, 1)
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
            title: "New Palette Name"
            Kirigami.FormLayout {
                Controls.TextField { id: nameField; placeholderText: "Palette name" }
                Controls.Button {
                    text: "Create"
                    onClicked: {
                        let newPalette = {name: nameField.text, colors: []}
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