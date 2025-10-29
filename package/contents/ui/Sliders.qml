import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls

ColumnLayout {
    id: root
    property string mode: "HSV"
    property real hue: 0.0
    property real saturation: 1.0
    property real value: 1.0
    property real alpha: 1.0
    property color selectedColor: Qt.hsva(hue, saturation, value, alpha)

    signal updateMode(string mode)
    signal updateHue(real hue)
    signal updateSaturation(real saturation)
    signal updateValue(real value)
    signal updateAlpha(real alpha)

    // Mode dropdown
    Controls.ComboBox {
        Layout.fillWidth: true
        model: ["HSV", "RGB"]
        currentIndex: mode === "HSV" ? 0 : 1
        onCurrentTextChanged: root.updateMode(currentText)
    }

    // HSV Sliders
    ColumnLayout {
        visible: mode === "HSV"
        Layout.fillWidth: true

        Controls.Slider { from: 0; to: 1; value: root.hue; onMoved: root.updateHue(value) }
        Controls.Slider { from: 0; to: 1; value: root.saturation; onMoved: root.updateSaturation(value) }
        Controls.Slider { from: 0; to: 1; value: root.value; onMoved: root.updateValue(value) }
    }

    // RGB Sliders (convert from/to HSV)
    ColumnLayout {
        visible: mode === "RGB"
        Layout.fillWidth: true

        Controls.Slider { from: 0; to: 255; value: Math.round(root.selectedColor.r * 255); onMoved: updateRgb("r", value) }
        Controls.Slider { from: 0; to: 255; value: Math.round(root.selectedColor.g * 255); onMoved: updateRgb("g", value) }
        Controls.Slider { from: 0; to: 255; value: Math.round(root.selectedColor.b * 255); onMoved: updateRgb("b", value) }

        function updateRgb(channel, val) {
            let r = selectedColor.r * 255, g = selectedColor.g * 255, b = selectedColor.b * 255
            if (channel === "r") r = val
            else if (channel === "g") g = val
            else b = val
            let color = Qt.rgba(r/255, g/255, b/255, alpha)
            let hsv = colorToHsv(color)
            updateHue(hsv.h)
            updateSaturation(hsv.s)
            updateValue(hsv.v)
        }
    }

    // Alpha Slider (common)
    Controls.Slider { from: 0; to: 1; value: root.alpha; onMoved: root.updateAlpha(value) }

    function colorToHsv(color) {
        let max = Math.max(color.r, color.g, color.b)
        let min = Math.min(color.r, color.g, color.b)
        let d = max - min
        let s = max === 0 ? 0 : d / max
        let v = max
        let h
        if (d === 0) h = 0
        else if (max === color.r) h = (color.g - color.b) / d + (color.g < color.b ? 6 : 0)
        else if (max === color.g) h = (color.b - color.r) / d + 2
        else h = (color.r - color.g) / d + 4
        h /= 6
        return {h: h, s: s, v: v}
    }
}