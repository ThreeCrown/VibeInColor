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
        model: palettes ? palettes.map(p => p.name || "Unnamed") : []
        currentIndex: selectedPaletteIndex
        onCurrentIndexChanged: selectedPaletteIndex = currentIndex
    }

    RowLayout {
        Layout.fillWidth: true
        Repeater {
            model: palettes.length > 0 ? (palettes[selectedPaletteIndex].colors || []) : []
            Rectangle {
                width: 30
                height: 30
                color: modelData.color || "transparent"
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
                let dialog = nicknameDialog.createObject(root)
                dialog.open()
            }
        }

        Controls.Button {
            text: "New Palette"
            onClicked: {
                let dialog = newPaletteDialog.createObject(root)
                dialog.open()
            }
        }
    }

    Component {
        id: nicknameDialog
        Kirigami.OverlaySheet {
            implicitWidth: Kirigami.Units.gridUnit * 20  // Reasonable fixed width
            title: "Add Color Nickname"
            ColumnLayout {  // Switched to ColumnLayout to avoid loops
                Controls.Label { text: "Nickname (optional):" }  // Optional explicit label
                Controls.TextField {
                    id: nickField
                    Layout.fillWidth: true
                    placeholderText: "Optional nickname"
                }
                Controls.Button {
                    Layout.alignment: Qt.AlignRight
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
            implicitWidth: Kirigami.Units.gridUnit * 20  // Reasonable fixed width
            title: "New Palette Name"
            ColumnLayout {  // Switched to ColumnLayout to avoid loops
                Controls.Label { text: "Palette name:" }  // Optional explicit label
                Controls.TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Palette name"
                }
                Controls.Label { text: "Nickname for first color:" }  // Optional explicit label
                Controls.TextField {
                    id: nickField2
                    Layout.fillWidth: true
                    placeholderText: "Nickname for first color"
                }
                Controls.Button {
                    Layout.alignment: Qt.AlignRight
                    text: "Create"
                    onClicked: {
                        let newPalette = {name: nameField.text || "New Palette", colors: [{color: selectedColor.toString(), nickname: nickField2.text}]}
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