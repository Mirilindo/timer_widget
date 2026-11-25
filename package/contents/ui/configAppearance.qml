import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_fontColor: textColor.value
    property alias cfg_warnEnabled: warnEnable.checked
    property alias cfg_warnPercent: warnSpin.value
    property alias cfg_warnColor: warnColor.value
    property string cfg_fontFamily

    Translations { id: lang }

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

        // --- Countdown: warning color near the end ---
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
    }
}
