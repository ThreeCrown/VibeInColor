import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation


    // Global color state (HSV for wheel/sliders)
    property real hue: 0.0
    property real saturation: 1.0
    property real value: 1.0
    property real alpha: 1.0
    property color selectedColor: Qt.hsva(hue, saturation, value, alpha)
    property string mode: "HSV"  // Dropdown selection: HSV, RGB

    // Palette storage (JSON array of {name: string, colors: [{color: string, nickname: string}]})
    property string palettesConfig: plasmoid.configuration.palettes
    onPalettesConfigChanged: palettes = palettesConfig ? JSON.parse(palettesConfig) : []
    property var palettes: []
    onPalettesChanged: plasmoid.configuration.palettes = JSON.stringify(palettes)

    compactRepresentation: Kirigami.Icon {
        source: Qt.resolvedUrl("../icons/VICLogo.png")
        MouseArea {
            anchors.fill: parent
            onClicked: {
                expanded = !expanded;
            }
        }
    }


    fullRepresentation: Kirigami.Page {
        id: fullView
        Layout.preferredWidth: 400
        Layout.preferredHeight: 500
        Layout.minimumWidth: 300
        Layout.minimumHeight: 400


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
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: Kirigami.Units.gridUnit * 15  // Breaks layout loop

                        ColorWheel {
                            id: colorWheel
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) * 0.9
                            height: width
                            hue: root.hue
                            saturation: root.saturation
                            onUpdateHue: (hue) => root.hue = hue  // Arrow func to preserve scope
                            onUpdateSaturation: (saturation) => root.saturation = saturation  // Arrow func
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
                        onUpdateMode: (mode) => root.mode = mode  // Arrow func
                        onUpdateHue: (hue) => root.hue = hue  // Arrow func
                        onUpdateSaturation: (saturation) => root.saturation = saturation  // Arrow func
                        onUpdateValue: (value) => root.value = value  // Arrow func
                        onUpdateAlpha: (alpha) => root.alpha = alpha  // Arrow func
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
                    clipboard: clipboard
                    onUpdatePalettes: (palettes) => root.palettes = palettes  // Arrow func
                }
            }

            // Palettes Tab
            PalettesView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                palettes: root.palettes
                clipboard: clipboard
                onUpdatePalettes: (palettes) => root.palettes = palettes  // Arrow func
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