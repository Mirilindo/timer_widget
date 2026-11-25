import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_buttonLayout: layoutCombo.currentIndex
    property alias cfg_showButtonLabels: labelsCheck.checked
    property alias cfg_buttonSize: sizeSpin.value
    property alias cfg_showPlusMinus: plusMinusCheck.checked
    property alias cfg_quickStepSeconds: stepSpin.value

    Translations { id: lang }

    Kirigami.FormLayout {

        QQC2.ComboBox {
            id: layoutCombo
            Kirigami.FormData.label: lang.t("buttonLayout")
            // 0 = sides, 1 = below, 2 = above, 3 = none
            model: [lang.t("layoutSides"), lang.t("layoutBelow"),
                    lang.t("layoutAbove"), lang.t("layoutNone")]
        }
        QQC2.CheckBox {
            id: labelsCheck
            enabled: layoutCombo.currentIndex !== 3
            text: lang.t("showLabel")
        }
        QQC2.SpinBox {
            id: sizeSpin
            Kirigami.FormData.label: lang.t("buttonSize")
            enabled: layoutCombo.currentIndex !== 3
            from: 0
            to: 72
        }

        Item { Kirigami.FormData.isSection: true }

        // --- +/- (countdown only) ---
        QQC2.CheckBox {
            id: plusMinusCheck
            Kirigami.FormData.label: lang.t("plusMinus")
            enabled: layoutCombo.currentIndex !== 3
            text: lang.t("show")
        }
        QQC2.SpinBox {
            id: stepSpin
            Kirigami.FormData.label: lang.t("quickStep")
            enabled: plusMinusCheck.checked && layoutCombo.currentIndex !== 3
            from: 5
            to: 3600
            stepSize: 5
        }
    }
}
