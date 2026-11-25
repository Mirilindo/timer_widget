import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    // JSON: [{"s": seconds, "n": "name"}, ...]. Source of truth = the config.
    property string cfg_presetDurations

    Translations { id: lang }

    property bool loading: true
    // JS array of objects { h, m, s, n }
    property var entries: []

    function persist() {
        if (page.loading) return
        var arr = []
        for (var i = 0; i < entries.length; i++) {
            var e = entries[i]
            var total = e.h * 3600 + e.m * 60 + e.s
            if (total > 0) arr.push({ "s": total, "n": e.n })
        }
        page.cfg_presetDurations = JSON.stringify(arr)
    }

    function load() {
        page.loading = true
        var raw = String(page.cfg_presetDurations).trim()
        var arr = null
        try { arr = JSON.parse(raw) } catch (e) { arr = null }
        if (!Array.isArray(arr)) { // fall back to the old CSV-of-seconds format
            arr = []
            var csv = raw.split(",")
            for (var k = 0; k < csv.length; k++) {
                var v = parseInt(csv[k]); if (v > 0) arr.push({ "s": v, "n": "" })
            }
        }
        var list = []
        for (var i = 0; i < arr.length; i++) {
            var s = parseInt(arr[i].s) || 0
            if (s <= 0) continue
            list.push({ "h": Math.floor(s / 3600), "m": Math.floor((s % 3600) / 60),
                        "s": s % 60, "n": arr[i].n || "" })
        }
        page.entries = list
        page.loading = false
    }

    function addEntry() {
        page.entries = page.entries.concat([{ "h": 0, "m": 5, "s": 0, "n": "" }])
        persist()
    }
    function removeAt(i) {
        if (i < 0 || i >= page.entries.length) return
        var copy = page.entries.slice()
        copy.splice(i, 1)
        page.entries = copy
        persist()
    }
    // Write DIRECTLY into the array (the Repeater's modelData is a copy, mutating it does
    // not propagate back). No reassignment -> no Repeater rebuild (the field being edited
    // keeps focus).
    function setField(i, key, val) {
        if (i < 0 || i >= page.entries.length) return
        page.entries[i][key] = val
        persist()
    }
    function moveAt(i, dir) {
        var j = i + dir
        if (i < 0 || j < 0 || j >= page.entries.length) return
        var copy = page.entries.slice()
        var tmp = copy[i]
        copy.splice(i, 1)
        copy.splice(j, 0, tmp)
        page.entries = copy
        persist()
    }
    Component.onCompleted: load()

    ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        // --- Countdowns offered in the menus ---
        Kirigami.Heading { level: 3; text: lang.t("menuDurationsTitle") }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 26
            text: lang.t("menuDurationsHint")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            wrapMode: Text.WordWrap
        }

        Item { implicitHeight: Kirigami.Units.smallSpacing }

        Repeater {
            model: page.entries

            delegate: RowLayout {
                id: row
                required property var modelData
                required property int index

                spacing: Kirigami.Units.smallSpacing

                // action buttons on the LEFT (always visible/clickable)
                QQC2.ToolButton {
                    icon.name: "go-up"
                    enabled: row.index > 0
                    QQC2.ToolTip.text: lang.t("moveUp")
                    QQC2.ToolTip.visible: hovered
                    onClicked: page.moveAt(row.index, -1)
                }
                QQC2.ToolButton {
                    icon.name: "go-down"
                    enabled: row.index < page.entries.length - 1
                    QQC2.ToolTip.text: lang.t("moveDown")
                    QQC2.ToolTip.visible: hovered
                    onClicked: page.moveAt(row.index, 1)
                }
                QQC2.ToolButton {
                    icon.name: "list-remove"
                    QQC2.ToolTip.text: lang.t("removeDuration")
                    QQC2.ToolTip.visible: hovered
                    onClicked: page.removeAt(row.index)
                }

                QQC2.SpinBox {
                    from: 0; to: 99
                    value: row.modelData.h
                    onValueModified: page.setField(row.index, "h", value)
                }
                QQC2.Label { text: ":" }
                QQC2.SpinBox {
                    from: 0; to: 59
                    value: row.modelData.m
                    onValueModified: page.setField(row.index, "m", value)
                }
                QQC2.Label { text: ":" }
                QQC2.SpinBox {
                    from: 0; to: 59
                    value: row.modelData.s
                    onValueModified: page.setField(row.index, "s", value)
                }

                QQC2.TextField {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 7
                    text: row.modelData.n
                    placeholderText: lang.t("namePlaceholder")
                    onTextEdited: page.setField(row.index, "n", text)
                }
            }
        }

        QQC2.Button {
            text: lang.t("addDuration")
            icon.name: "list-add"
            onClicked: page.addEntry()
        }
    }
}
