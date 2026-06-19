import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami

// Color picker: swatch + hex code + "Pick…" button + clear.
// `value` = hex string (e.g. "#e74c3c") or "" (empty = default/theme color).
RowLayout {
    id: ctrl

    property string value: ""
    property string placeholder: ""
    property string pickLabel: "Pick…"

    spacing: Kirigami.Units.smallSpacing

    Rectangle {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 1.4
        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.4
        radius: 3
        border.width: 1
        border.color: Kirigami.Theme.disabledTextColor
        color: ctrl.value !== "" ? ctrl.value : "transparent"
        QQC2.Label {
            anchors.centerIn: parent
            visible: ctrl.value === ""
            text: "—"
            opacity: 0.6
        }
    }

    QQC2.TextField {
        id: hexField
        Layout.preferredWidth: Kirigami.Units.gridUnit * 6
        text: ctrl.value
        placeholderText: ctrl.placeholder
        inputMask: ""
        onTextEdited: ctrl.value = text
        // resync when the value changes elsewhere (picker / clear)
        Connections {
            target: ctrl
            function onValueChanged() {
                if (hexField.text !== ctrl.value) hexField.text = ctrl.value
            }
        }
    }

    QQC2.Button {
        text: ctrl.pickLabel
        icon.name: "color-picker"
        onClicked: {
            colorDialog.selectedColor = ctrl.value !== "" ? ctrl.value : "#ffffff"
            colorDialog.open()
        }
    }

    QQC2.ToolButton {
        icon.name: "edit-clear"
        enabled: ctrl.value !== ""
        onClicked: ctrl.value = ""
    }

    Dialogs.ColorDialog {
        id: colorDialog
        onAccepted: ctrl.value = "" + selectedColor
    }
}
