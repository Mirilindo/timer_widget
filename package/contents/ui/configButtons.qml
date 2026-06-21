import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page
    property alias cfg_showStartButton: showStart.checked
    property alias cfg_startButtonSide: startSide.currentIndex
    property alias cfg_showStartLabel: showStartLabel.checked
    property alias cfg_startButtonSize: startSize.value
    property alias cfg_startButtonOrder: startOrder.value

    property alias cfg_showResetButton: showReset.checked
    property alias cfg_resetButtonSide: resetSide.currentIndex
    property alias cfg_showResetLabel: showResetLabel.checked
    property alias cfg_resetButtonSize: resetSize.value
    property alias cfg_resetButtonOrder: resetOrder.value
    property alias cfg_resetTwiceToDefault: resetTwice.checked

    property alias cfg_showAddButton: showAdd.checked
    property alias cfg_addButtonSide: addSide.currentIndex
    property alias cfg_showAddLabel: showAddLabel.checked
    property alias cfg_addButtonSize: addSize.value
    property alias cfg_addButtonOrder: addOrder.value

    property alias cfg_showSubButton: showSub.checked
    property alias cfg_subButtonSide: subSide.currentIndex
    property alias cfg_showSubLabel: showSubLabel.checked
    property alias cfg_subButtonSize: subSize.value
    property alias cfg_subButtonOrder: subOrder.value

    property alias cfg_quickStepSeconds: quickStep.value
    property alias cfg_lateralButtonsRow: lateralRow.checked

    Translations { id: lang }

    Kirigami.FormLayout {

        // --- Global layout ---
        QQC2.CheckBox {
            id: lateralRow
            Kirigami.FormData.label: lang.t("layout")
            text: lang.t("lateralRow")
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Start / Pause ---
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
        QQC2.SpinBox {
            id: startSize
            Kirigami.FormData.label: lang.t("buttonSize")
            enabled: showStart.checked
            from: 0
            to: 100
            stepSize: 2
        }
        QQC2.SpinBox {
            id: startOrder
            Kirigami.FormData.label: lang.t("order")
            enabled: showStart.checked
            from: 0
            to: 9
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Reset ---
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
        QQC2.SpinBox {
            id: resetSize
            Kirigami.FormData.label: lang.t("buttonSize")
            enabled: showReset.checked
            from: 0
            to: 100
            stepSize: 2
        }
        QQC2.SpinBox {
            id: resetOrder
            Kirigami.FormData.label: lang.t("order")
            enabled: showReset.checked
            from: 0
            to: 9
        }
        QQC2.CheckBox {
            id: resetTwice
            enabled: showReset.checked
            text: lang.t("resetTwice")
        }

        Item { Kirigami.FormData.isSection: true }

        // --- + (add time) ---
        QQC2.CheckBox {
            id: showAdd
            Kirigami.FormData.label: lang.t("addBtn")
            text: lang.t("show")
        }
        QQC2.ComboBox {
            id: addSide
            Kirigami.FormData.label: lang.t("position")
            enabled: showAdd.checked
            model: [lang.t("left"), lang.t("right"), lang.t("top"), lang.t("bottom")]
        }
        QQC2.CheckBox {
            id: showAddLabel
            enabled: showAdd.checked
            text: lang.t("showLabel")
        }
        QQC2.SpinBox {
            id: addSize
            Kirigami.FormData.label: lang.t("buttonSize")
            enabled: showAdd.checked
            from: 0
            to: 100
            stepSize: 2
        }
        QQC2.SpinBox {
            id: addOrder
            Kirigami.FormData.label: lang.t("order")
            enabled: showAdd.checked
            from: 0
            to: 9
        }

        Item { Kirigami.FormData.isSection: true }

        // --- − (remove time) ---
        QQC2.CheckBox {
            id: showSub
            Kirigami.FormData.label: lang.t("subBtn")
            text: lang.t("show")
        }
        QQC2.ComboBox {
            id: subSide
            Kirigami.FormData.label: lang.t("position")
            enabled: showSub.checked
            model: [lang.t("left"), lang.t("right"), lang.t("top"), lang.t("bottom")]
        }
        QQC2.CheckBox {
            id: showSubLabel
            enabled: showSub.checked
            text: lang.t("showLabel")
        }
        QQC2.SpinBox {
            id: subSize
            Kirigami.FormData.label: lang.t("buttonSize")
            enabled: showSub.checked
            from: 0
            to: 100
            stepSize: 2
        }
        QQC2.SpinBox {
            id: subOrder
            Kirigami.FormData.label: lang.t("order")
            enabled: showSub.checked
            from: 0
            to: 9
        }

        Item { Kirigami.FormData.isSection: true }

        // --- Shared step for +/- ---
        QQC2.SpinBox {
            id: quickStep
            Kirigami.FormData.label: lang.t("quickStep")
            enabled: showAdd.checked || showSub.checked
            from: 5
            to: 3600
            stepSize: 5
        }
    }
}
