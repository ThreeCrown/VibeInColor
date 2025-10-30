// Updated NewPaletteSheet.qml (fix accepted as signal, not alias; emit on button click)
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami as Kirigami

Kirigami.OverlaySheet {
    id: root
    property string paletteName: ""
    property string colorNickname: ""
    property color initialColor: "#FFFFFF"  // Only used if withInitialColor
    property bool withInitialColor: false  // True for picker tab (includes color nickname field)

    signal accepted()  // Custom signal for "Create" action (parent connects to this)

    title: "New Palette Name"
    implicitWidth: Kirigami.Units.gridUnit * 20  // Fixed width to prevent loops/overflow

    // Explicit background to fix transparency
    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
        opacity: 0.95  // Slight transparency for overlay feel; adjust as needed
        radius: Kirigami.Units.smallSpacing * 2
        border.color: Kirigami.Theme.textColor
        border.width: 1  // Optional border for visibility
    }

    ColumnLayout {
        Layout.fillWidth: true

        Controls.Label { text: "Palette name:" }
        Controls.TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "Palette name"
            text: root.paletteName
            onTextChanged: root.paletteName = text
        }

        // Conditional field for initial color nickname
        Item {
            visible: root.withInitialColor
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                Controls.Label { text: "Nickname for first color:" }
                Controls.TextField {
                    id: nickField
                    Layout.fillWidth: true
                    placeholderText: "Nickname for first color"
                    text: root.colorNickname
                    onTextChanged: root.colorNickname = text
                }
            }
        }
    }

    // Footer for actions (Cancel/Create) - provides "check" button
    footer: RowLayout {
        spacing: Kirigami.Units.smallSpacing
        Item { Layout.fillWidth: true }  // Spacer to right-align buttons
        Controls.Button {
            text: "Cancel"
            onClicked: root.close()
        }
        Controls.Button {
            id: createButton
            text: "Create"
            onClicked: root.accepted()  // Emit the signal (parent handles save/close)
        }
    }

    // Force focus on open
    onOpened: {
        nameField.forceActiveFocus()
        // Center in parent (fixes outside window if parent is set correctly)
        if (parent) {
            x = (parent.width - width) / 2
            y = (parent.height - height) / 2
        }
    }
}