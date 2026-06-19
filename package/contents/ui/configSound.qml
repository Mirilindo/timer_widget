import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_beepCount: beepSpin.value
    property alias cfg_showNotification: notifCheck.checked
    property string cfg_customSoundPath

    Translations { id: lang }

    Dialogs.FileDialog {
        id: fileDialog
        title: lang.t("customSound")
        nameFilters: ["Audio (*.mp3 *.ogg *.wav *.flac *.m4a)", "*"]
        onAccepted: page.cfg_customSoundPath = selectedFile.toString()
    }

    Kirigami.FormLayout {

        QQC2.SpinBox {
            id: beepSpin
            Kirigami.FormData.label: lang.t("beepRepeats")
            from: 0
            to: 20
            stepSize: 1
        }
        QQC2.Label {
            text: lang.t("beepHint")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            wrapMode: Text.WordWrap
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Custom sound ---
        RowLayout {
            Kirigami.FormData.label: lang.t("customSound")
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextField {
                id: soundField
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 14
                readOnly: true
                text: page.cfg_customSoundPath
                placeholderText: lang.t("useDefault")
            }
            QQC2.Button {
                text: lang.t("browse")
                icon.name: "document-open"
                onClicked: fileDialog.open()
            }
            QQC2.Button {
                icon.name: "edit-clear"
                enabled: page.cfg_customSoundPath !== ""
                onClicked: page.cfg_customSoundPath = ""
                QQC2.ToolTip.text: lang.t("useDefault")
                QQC2.ToolTip.visible: hovered
            }
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Notification ---
        QQC2.CheckBox {
            id: notifCheck
            Kirigami.FormData.label: lang.t("notification")
            text: lang.t("show")
        }
    }
}
