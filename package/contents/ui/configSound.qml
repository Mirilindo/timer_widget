import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_beepCount: beepSpin.value

    Translations { id: lang }

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
    }
}
