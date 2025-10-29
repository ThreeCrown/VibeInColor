import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami as Kirigami

GridLayout {
    id: root
    columns: 2
    rowSpacing: 5
    columnSpacing: 10
    property color selectedColor: "#FFFFFF"
    property var clipboard

    ColumnLayout {
        spacing: 2
        Layout.fillWidth: true

        Controls.Label {
            text: "Hex"
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Button {
            Layout.fillWidth: true
            text: selectedColor.toString().toUpperCase().slice(0, 7)
            onClicked: clipboard.setText(text)
        }
    }

    ColumnLayout {
        spacing: 2
        Layout.fillWidth: true

        Controls.Label {
            text: "RGB"
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Button {
            Layout.fillWidth: true
            text: "rgb(" + Math.round(selectedColor.r * 255) + ", " + Math.round(selectedColor.g * 255) + ", " + Math.round(selectedColor.b * 255) + ")"
            onClicked: clipboard.setText(text)
        }
    }

    ColumnLayout {
        spacing: 2
        Layout.fillWidth: true

        Controls.Label {
            text: "RGBA"
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Button {
            Layout.fillWidth: true
            text: "rgba(" + Math.round(selectedColor.r * 255) + ", " + Math.round(selectedColor.g * 255) + ", " + Math.round(selectedColor.b * 255) + ", " + selectedColor.a + ")"
            onClicked: clipboard.setText(text)
        }
    }

    ColumnLayout {
        spacing: 2
        Layout.fillWidth: true

        Controls.Label {
            text: "HSV"
            Layout.alignment: Qt.AlignHCenter
        }
        Controls.Button {
            Layout.fillWidth: true
            text: "hsv(" + (selectedColor.hsvHue * 360).toFixed(0) + ", " + (selectedColor.hsvSaturation * 100).toFixed(0) + "%, " + (selectedColor.hsvValue * 100).toFixed(0) + "%)"
            onClicked: clipboard.setText(text)
        }
    }
}