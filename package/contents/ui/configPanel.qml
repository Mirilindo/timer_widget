import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

// What the widget shows inside a panel: the time (default) or the icon with progress.
KCM.SimpleKCM {
    id: page

    // 0 = time, 1 = icon while idle, then the time, 2 = icon with progress
    // (the settings below the choices belong to the last one)
    property int cfg_panelDisplay
    readonly property bool progressOn: page.cfg_panelDisplay === 2
    readonly property bool iconOn: page.cfg_panelDisplay !== 0
    property alias cfg_compactBar: barCheck.checked
    property alias cfg_compactIconScale: iconSpin.value
    property alias cfg_compactRingThickness: thickSpin.value
    property alias cfg_compactRingFill: fillCheck.checked
    property string cfg_compactIconPath

    Translations { id: lang }

    Dialogs.FileDialog {
        id: logoDialog
        title: lang.t("compactLogo")
        nameFilters: ["Images (*.png *.svg *.svgz *.jpg *.jpeg *.webp *.ico)", "*"]
        onAccepted: page.cfg_compactIconPath = selectedFile.toString()
    }

    Kirigami.FormLayout {

        QQC2.RadioButton {
            Kirigami.FormData.label: lang.t("panelShow")
            text: lang.t("panelTime")
            checked: page.cfg_panelDisplay === 0
            onToggled: if (checked) page.cfg_panelDisplay = 0
        }
        QQC2.RadioButton {
            text: lang.t("panelIconIdle")
            checked: page.cfg_panelDisplay === 1
            onToggled: if (checked) page.cfg_panelDisplay = 1
        }
        QQC2.RadioButton {
            text: lang.t("panelIcon")
            checked: page.cfg_panelDisplay === 2
            onToggled: if (checked) page.cfg_panelDisplay = 2
        }
        QQC2.Label {
            text: lang.t("panelIconHint")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 24
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Icon mode settings ---
        QQC2.CheckBox {
            id: barCheck
            enabled: page.progressOn
            text: lang.t("compactBar")
        }
        QQC2.SpinBox {
            id: iconSpin
            Kirigami.FormData.label: lang.t("compactIconSize")
            enabled: page.progressOn
            from: 0
            to: 100
            stepSize: 5
        }
        QQC2.SpinBox {
            id: thickSpin
            Kirigami.FormData.label: lang.t("compactRingThickness")
            enabled: page.progressOn
            from: 4
            to: 40
            stepSize: 1
        }
        QQC2.CheckBox {
            id: fillCheck
            enabled: page.progressOn
            text: lang.t("compactFill")
        }

        RowLayout {
            Kirigami.FormData.label: lang.t("compactLogo")
            enabled: page.iconOn
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextField {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 14
                readOnly: true
                text: page.cfg_compactIconPath
                placeholderText: lang.t("defaultFont")
            }
            QQC2.Button {
                text: lang.t("browse")
                icon.name: "document-open"
                onClicked: logoDialog.open()
            }
            QQC2.Button {
                icon.name: "edit-clear"
                enabled: page.cfg_compactIconPath !== ""
                onClicked: page.cfg_compactIconPath = ""
            }
        }
        QQC2.Label {
            enabled: page.iconOn
            text: lang.t("compactLogoHint")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 24
        }
    }
}
