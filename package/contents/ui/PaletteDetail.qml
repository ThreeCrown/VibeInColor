import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    property var palette: ({name: "", colors: []})
    property string displayMode: "Hex"
    property var clipboard

    signal updatePalette(var palette)
    signal deleteRequested()
    signal cloneRequested()

    // Radio buttons for display mode
    Controls.ButtonGroup { id: modeGroup }
    RowLayout {
        Layout.fillWidth: true
        Controls.RadioButton { text: "Hex"; checked: displayMode === "Hex"; Controls.ButtonGroup.group: modeGroup; onToggled: displayMode = "Hex" }
        Controls.RadioButton { text: "RGB"; checked: displayMode === "RGB"; Controls.ButtonGroup.group: modeGroup; onToggled: displayMode = "RGB" }
        Controls.RadioButton { text: "RGBA"; checked: displayMode === "RGBA"; Controls.ButtonGroup.group: modeGroup; onToggled: displayMode = "RGBA" }
        Controls.RadioButton { text: "HSV"; checked: displayMode === "HSV"; Controls.ButtonGroup.group: modeGroup; onToggled: displayMode = "HSV" }
    }

    // Swatches with value buttons
    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: palette.colors || []  // Add null check to prevent undefined error
        delegate: RowLayout {
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

            Controls.Button {
                text: getValue(modelData.color)
                onClicked: clipboard.setText(text)
            }

            function getValue(colorStr) {
                let color = Qt.rgba(0,0,0,1)  // Parse if needed
                color = colorStr
                if (displayMode === "Hex") return color.toString().toUpperCase().slice(0, 7)
                if (displayMode === "RGB") return "rgb(" + Math.round(color.r*255) + ", " + Math.round(color.g*255) + ", " + Math.round(color.b*255) + ")"
                if (displayMode === "RGBA") return "rgba(" + Math.round(color.r*255) + ", " + Math.round(color.g*255) + ", " + Math.round(color.b*255) + ", " + color.a + ")"
                if (displayMode === "HSV") return "hsv(" + (color.hsvHue*360).toFixed(0) + ", " + (color.hsvSaturation*100).toFixed(0) + "%, " + (color.hsvValue*100).toFixed(0) + "%)"
                return ""
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Controls.Button { text: "Delete Palette"; onClicked: deleteRequested() }
        Controls.Button { text: "Clone Palette"; onClicked: cloneRequested() }
    }
}