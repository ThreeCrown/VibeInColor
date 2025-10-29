import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Plasmoid.PlasmoidItem {
    id: root

    Layout.minimumWidth: 300
    Layout.minimumHeight: 400
    preferredRepresentation: Plasmoid.CompactRepresentation
    compactRepresentation: Kirigami.Icon {
        source: plasmoid.icon  // Uses metadata icon for panel
        MouseArea {
            anchors.fill: parent
            onClicked: plasmoid.expanded = !plasmoid.expanded
        }
    }
    fullRepresentation: Kirigami.Page {
        id: fullView
        Layout.preferredWidth: 400
        Layout.preferredHeight: 500

        // Global color state (HSV for wheel/sliders)
        property real hue: 0.0
        property real saturation: 1.0
        property real value: 1.0
        property real alpha: 1.0
        property color selectedColor: Qt.hsva(hue, saturation, value, alpha)
        property string mode: "HSV"  // Dropdown selection: HSV, RGB

        // Palette storage (JSON array of {name: string, colors: [{color: string, nickname: string}]})
        property var palettes: {
            let stored = plasmoid.configuration.palettes || "[]"
            return JSON.parse(stored)
        }
        onPalettesChanged: plasmoid.configuration.palettes = JSON.stringify(palettes)

        // Tabs at top
        Controls.TabBar {
            id: tabBar
            anchors.top: parent.top
            width: parent.width
            Controls.TabButton { text: "Picker" }
            Controls.TabButton { text: "Palettes" }
        }

        // Tab content
        StackLayout {
            anchors {
                top: tabBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            currentIndex: tabBar.currentIndex

            // Picker Tab
            ColumnLayout {
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                      Layout.preferredWidth: parent.width * 0.6
                      Layout.fillHeight: true

                      ColorWheel {
                        id: colorWheel
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width
                        hue: root.hue
                        saturation: root.saturation
                        onHueChanged: root.hue = hue
                        onSaturationChanged: root.saturation = saturation
                      }
                    }
                    

                    Sliders {
                        id: sliders
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        mode: root.mode
                        hue: root.hue
                        saturation: root.saturation
                        value: root.value
                        alpha: root.alpha
                        selectedColor: root.selectedColor
                        onUpdateMode: root.mode = mode
                        onUpdateHue: root.hue = hue
                        onUpdateSaturation: root.saturation = saturation
                        onUpdateValue: root.value = value
                        onUpdateAlpha: root.alpha = alpha
                    }
                }

                Kirigami.Separator { Layout.fillWidth: true }

                ColorOutputs {
                    Layout.fillWidth: true
                    selectedColor: root.selectedColor
                    clipboard: clipboard
                }

                Kirigami.Separator { Layout.fillWidth: true }

                PaletteSelector {
                    Layout.fillWidth: true
                    palettes: root.palettes
                    selectedColor: root.selectedColor
                    onPalettesChanged: root.palettes = palettes
                }
            }

            // Palettes Tab
            PalettesView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palettes: root.palettes
                onPalettesChanged: root.palettes = palettes
            }
        }
    }

    // Clipboard (shared)
    Plasma5Support.DataSource {
        id: clipboard
        engine: "clipboard"
        connectedSources: ["clipboard"]

        function setText(text) {
            var mimeData = {};
            mimeData["text/plain"] = text;
            var service = serviceForSource("clipboard");
            var operation = service.operationDescription("set");
            operation.mimeData = mimeData;
            startOperationCall(operation);
        }
    }
}