import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_showStartButton: showStart.checked
    property alias cfg_showResetButton: showReset.checked
    property alias cfg_startButtonSide: startSide.currentIndex
    property alias cfg_resetButtonSide: resetSide.currentIndex
    property alias cfg_showStartLabel: showStartLabel.checked
    property alias cfg_showResetLabel: showResetLabel.checked

    Translations { id: lang }

    Kirigami.FormLayout {

        QQC2.CheckBox {
            id: showStart
            Kirigami.FormData.label: lang.t("startBtn")
            text: lang.t("show")
        }
        QQC2.ComboBox {
            id: startSide
            Kirigami.FormData.label: lang.t("position")
            enabled: showStart.checked
            // side = relative to the digits (left / right / top / bottom)
            model: [lang.t("left"), lang.t("right"), lang.t("top"), lang.t("bottom")]
        }
        QQC2.CheckBox {
            id: showStartLabel
            enabled: showStart.checked
            text: lang.t("showLabel")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: showReset
            Kirigami.FormData.label: lang.t("resetBtn")
            text: lang.t("show")
        }
        QQC2.ComboBox {
            id: resetSide
            Kirigami.FormData.label: lang.t("position")
            enabled: showReset.checked
            model: [lang.t("left"), lang.t("right"), lang.t("top"), lang.t("bottom")]
        }
        QQC2.CheckBox {
            id: showResetLabel
            enabled: showReset.checked
            text: lang.t("showLabel")
        }
    }
}
