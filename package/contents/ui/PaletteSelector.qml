import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    property var palettes: []
    property color selectedColor: "#FFFFFF"
    property int selectedPaletteIndex: 0
    property var clipboard

    signal updatePalettes(var palettes)

    Controls.ComboBox {
        Layout.fillWidth: true
        model: palettes.map(p => p.name)
        currentIndex: selectedPaletteIndex
        onCurrentIndexChanged: selectedPaletteIndex = currentIndex
    }

    RowLayout {
        Layout.fillWidth: true
        Repeater {
            model: palettes.length > 0 ? palettes[selectedPaletteIndex].colors : []
            Rectangle {
                width: 30
                height: 30
                color: modelData.color
                border.color: "black"
                border.width: 1
                Controls.ToolTip.text: modelData.nickname || ""
                MouseArea {
                    anchors.fill: parent
                    onClicked: clipboard.setText(color.toString().toUpperCase().slice(0, 7))
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Controls.Button {
            text: "+ Add to Palette"
            onClicked: {
                let dialog = nicknameDialog.component.createObject(root)
                dialog.open()
            }
        }

        Controls.Button {
            text: "New Palette"
            onClicked: {
                let dialog = newPaletteDialog.component.createObject(root)
                dialog.open()
            }
        }
    }

    Component {
        id: nicknameDialog
        Kirigami.OverlaySheet {
            title: "Add Color Nickname"
            Kirigami.FormLayout {
                Controls.TextField { id: nickField; placeholderText: "Optional nickname" }
                Controls.Button {
                    text: "Add"
                    onClicked: {
                        let newColors = palettes[selectedPaletteIndex].colors.slice()
                        newColors.push({color: selectedColor.toString(), nickname: nickField.text})
                        let newPalettes = palettes.slice()
                        newPalettes[selectedPaletteIndex].colors = newColors
                        root.updatePalettes(newPalettes)
                        close()
                    }
                }
            }
        }
    }

    Component {
        id: newPaletteDialog
        Kirigami.OverlaySheet {
            title: "New Palette Name"
            Kirigami.FormLayout {
                Controls.TextField { id: nameField; placeholderText: "Palette name" }
                Controls.TextField { id: nickField2; placeholderText: "Nickname for first color" }
                Controls.Button {
                    text: "Create"
                    onClicked: {
                        let newPalette = {name: nameField.text, colors: [{color: selectedColor.toString(), nickname: nickField2.text}]}
                        let newPalettes = palettes.slice()
                        newPalettes.push(newPalette)
                        root.updatePalettes(newPalettes)
                        root.selectedPaletteIndex = newPalettes.length - 1
                        close()
                    }
                }
            }
        }
    }
}