import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_defaultDuration: durationSpin.value

    Translations { id: lang }

    Kirigami.FormLayout {

        QQC2.SpinBox {
            id: fontSizeSpin
            Kirigami.FormData.label: lang.t("fontSize")
            from: 8
            to: 400
            stepSize: 2
        }

        QQC2.SpinBox {
            id: durationSpin
            Kirigami.FormData.label: lang.t("defaultDuration")
            from: 1
            to: 86400
            stepSize: 30
        }
    }
}
