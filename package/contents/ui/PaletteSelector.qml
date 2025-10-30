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
        model: palettes ? palettes.map(p => p.name || "Unnamed") : []  // Already has check
        currentIndex: selectedPaletteIndex
        onCurrentIndexChanged: selectedPaletteIndex = currentIndex
    }

    RowLayout {
        Layout.fillWidth: true
        Repeater {
            model: (palettes || []).length > 0 ? ((palettes[selectedPaletteIndex] || {}).colors || []) : []  // Add null checks
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
                let dialog = nicknameDialog.createObject(root.parent)
                dialog.open()
            }
        }

        Controls.Button {
            text: "New Palette"
            onClicked: {
                let dialog = newPaletteSheet.createObject(root.parent, { withInitialColor: true, initialColor: selectedColor })
                dialog.accepted.connect(function() {
                    let newPalette = {name: dialog.paletteName || "New Palette", colors: [{color: dialog.initialColor.toString(), nickname: dialog.colorNickname}]}
                    let newPalettes = palettes.slice()
                    newPalettes.push(newPalette)
                    root.updatePalettes(newPalettes)
                    root.selectedPaletteIndex = newPalettes.length - 1
                    dialog.close()
                })
                dialog.open()
            }
        }
    }

    Component {
        id: newPaletteSheet
        NewPaletteSheet { }
    }

    Component {
        id: nicknameDialog
        Kirigami.OverlaySheet {
            implicitWidth: Kirigami.Units.gridUnit * 20
            title: "Add Color Nickname"

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                opacity: 0.95
                radius: Kirigami.Units.smallSpacing * 2
                border.color: Kirigami.Theme.textColor
                border.width: 1
            }

            ColumnLayout {
                Controls.Label { text: "Nickname (optional):" }
                Controls.TextField {
                    id: nickField
                    Layout.fillWidth: true
                    placeholderText: "Optional nickname"
                }
            }

            footer: RowLayout {
                Item { Layout.fillWidth: true }
                Controls.Button {
                    text: "Cancel"
                    onClicked: close()
                }
                Controls.Button {
                    text: "Add"
                    onClicked: {
                        let newColors = (palettes[selectedPaletteIndex].colors || []).slice()  // Add check
                        newColors.push({color: selectedColor.toString(), nickname: nickField.text})
                        let newPalettes = (palettes || []).slice()
                        newPalettes[selectedPaletteIndex].colors = newColors
                        root.updatePalettes(newPalettes)
                        close()
                    }
                }
            }

            onOpened: {
                nickField.forceActiveFocus()
                if (parent) {
                    x = (parent.width - width) / 2
                    y = (parent.height - height) / 2
                }
            }
        }
    }
}