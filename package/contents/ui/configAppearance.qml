import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_fontColor: textColor.value
    property alias cfg_warnEnabled: warnEnable.checked
    property alias cfg_warnPercent: warnSpin.value
    property alias cfg_warnColor: warnColor.value
    property alias cfg_compactInPanel: compactCheck.checked
    property alias cfg_compactRingFill: compactFillCheck.checked
    property alias cfg_compactIconScale: compactIconSpin.value
    property alias cfg_compactBar: compactBarCheck.checked
    property string cfg_fontFamily
    property string cfg_compactIconPath

    Translations { id: lang }

    Dialogs.FileDialog {
        id: logoDialog
        title: lang.t("compactLogo")
        nameFilters: ["Images (*.png *.svg *.svgz *.jpg *.jpeg *.webp *.ico)", "*"]
        onAccepted: page.cfg_compactIconPath = selectedFile.toString()
    }

    Kirigami.FormLayout {

        QQC2.SpinBox {
            id: fontSizeSpin
            Kirigami.FormData.label: lang.t("fontSize")
            from: 8
            to: 400
            stepSize: 2
        }

        QQC2.ComboBox {
            id: fontCombo
            Kirigami.FormData.label: lang.t("fontFamily")
            model: [lang.t("defaultFont")].concat(Qt.fontFamilies())
            Component.onCompleted: {
                var idx = model.indexOf(page.cfg_fontFamily)
                currentIndex = (page.cfg_fontFamily === "" || idx < 0) ? 0 : idx
            }
            onActivated: page.cfg_fontFamily = (currentIndex === 0 ? "" : currentText)
        }

        ColorField {
            id: textColor
            Kirigami.FormData.label: lang.t("textColor")
            placeholder: lang.t("themeColor")
            pickLabel: lang.t("pickColor")
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Warning color near the end ---
        QQC2.CheckBox {
            id: warnEnable
            Kirigami.FormData.label: lang.t("warnTitle")
            text: lang.t("warnEnable")
        }
        QQC2.SpinBox {
            id: warnSpin
            Kirigami.FormData.label: lang.t("warnThreshold")
            enabled: warnEnable.checked
            from: 1
            to: 100
            stepSize: 5
        }
        ColorField {
            id: warnColor
            Kirigami.FormData.label: lang.t("warnColor")
            enabled: warnEnable.checked
            pickLabel: lang.t("pickColor")
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Compact representation when placed in a panel ---
        QQC2.CheckBox {
            id: compactCheck
            Kirigami.FormData.label: lang.t("compactTitle")
            text: lang.t("compactPanel")
        }
        QQC2.CheckBox {
            id: compactFillCheck
            enabled: compactCheck.checked
            text: lang.t("compactFill")
        }
        QQC2.SpinBox {
            id: compactIconSpin
            Kirigami.FormData.label: lang.t("compactIconSize")
            enabled: compactCheck.checked
            from: 0
            to: 100
            stepSize: 5
        }
        QQC2.CheckBox {
            id: compactBarCheck
            enabled: compactCheck.checked
            text: lang.t("compactBar")
        }

        // --- Custom logo image ---
        RowLayout {
            Kirigami.FormData.label: lang.t("compactLogo")
            enabled: compactCheck.checked
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextField {
                id: logoField
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
            enabled: compactCheck.checked
            text: lang.t("compactLogoHint")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 24
        }
    }
}
