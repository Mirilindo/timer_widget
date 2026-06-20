import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtMultimedia
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.notification

PlasmoidItem {
    id: root

    // target   = chosen duration (default, or picked from the menu)
    // remaining = seconds left (shown)
    // endTime   = wall-clock epoch (ms) at which it hits zero; valid only while running.
    //             Counting from the clock instead of ticks keeps it accurate over long
    //             durations and survives system sleep.
    property int target: Plasmoid.configuration.defaultDuration
    property int remaining: target
    property bool running: false
    property double endTime: 0

    readonly property int startSide: Plasmoid.configuration.startButtonSide
    readonly property int resetSide: Plasmoid.configuration.resetButtonSide

    // Warning color: active when the remaining time is <= warnPercent % of the total (and > 0)
    readonly property bool warnActive: Plasmoid.configuration.warnEnabled
        && root.target > 0
        && root.remaining > 0
        && root.remaining <= root.target * Plasmoid.configuration.warnPercent / 100

    // Translations (strings.js)
    Translations { id: lang }

    function pad(n) { return n < 10 ? "0" + n : "" + n }
    function fmt(s) {
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        var sec = s % 60
        return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(sec)
    }

    function start() {
        if (root.remaining <= 0) root.remaining = root.target
        root.endTime = Date.now() + root.remaining * 1000
        root.running = true
    }
    function pause() {
        // freeze the remaining time from the clock
        root.remaining = Math.max(0, Math.ceil((root.endTime - Date.now()) / 1000))
        root.running = false
    }
    function toggle() {
        if (root.running) root.pause()
        else root.start()
    }
    function reset() {
        // If already reset (nothing running, remaining == target), another click goes
        // back to the default duration. Otherwise just reset to the targeted duration.
        if (!root.running && root.remaining === root.target) {
            root.target = Plasmoid.configuration.defaultDuration
        }
        root.running = false
        root.endTime = 0
        root.remaining = root.target
    }
    function setSeconds(s) {
        root.running = false
        root.endTime = 0
        root.target = s
        root.remaining = s
    }
    function playBeep() {
        var n = Plasmoid.configuration.beepCount
        if (n > 0) {
            beep.stop()
            beep.loops = n
            beep.play()
        }
    }
    // Called when the countdown reaches zero
    function onFinished() {
        root.playBeep()
        if (Plasmoid.configuration.showNotification) {
            doneNotification.sendEvent()
        }
    }

    // End sound: custom file if set, otherwise the bundled beep
    MediaPlayer {
        id: beep
        source: Plasmoid.configuration.customSoundPath !== ""
                ? Plasmoid.configuration.customSoundPath
                : Qt.resolvedUrl("../sounds/freesound_community-beep-6-96243.mp3")
        audioOutput: AudioOutput { }
    }

    // End-of-countdown notification
    Notification {
        id: doneNotification
        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "chronometer"
        title: lang.t("notifTitle")
        text: lang.t("notifBody")
    }

    // Recompute the remaining time from the clock while running. A short interval keeps
    // the second boundary crisp; the value itself is derived from endTime, so there is no
    // drift and a wake-from-sleep simply catches up.
    Timer {
        interval: 200
        repeat: true
        running: root.running
        onTriggered: {
            var left = (root.endTime - Date.now()) / 1000
            if (left <= 0) {
                root.remaining = 0
                root.running = false
                root.endTime = 0
                root.onFinished()
            } else {
                root.remaining = Math.ceil(left)
            }
        }
    }

    // Re-align to the default duration when it is changed in the settings (while stopped)
    Connections {
        target: Plasmoid.configuration
        function onDefaultDurationChanged() {
            if (!root.running) {
                root.target = Plasmoid.configuration.defaultDuration
                root.remaining = root.target
            }
        }
        function onPresetDurationsChanged() {
            root.rebuildPresets()
        }
    }

    // ----- Right-click menu -----
    PlasmaCore.Action {
        id: startAction
        text: root.running ? lang.t("pause") : lang.t("start")
        icon.name: root.running ? "media-playback-pause" : "media-playback-start"
        onTriggered: root.toggle()
    }
    PlasmaCore.Action {
        id: resetAction
        text: lang.t("reset")
        icon.name: "edit-reset"
        onTriggered: root.reset()
    }
    PlasmaCore.Action {
        id: separatorAction
        isSeparator: true
    }
    PlasmaCore.Action {
        id: separator2Action
        isSeparator: true
    }
    PlasmaCore.Action {
        id: setTimeAction
        text: lang.t("setTime")
        icon.name: "document-edit"
        // Always open the free-duration dialog at 00:00:00.
        onTriggered: setTimeWindow.openWith(0)
    }

    property var presetActions: []
    Component {
        id: actionComponent
        PlasmaCore.Action { }
    }
    function rebuildPresets() {
        var old = root.presetActions
        var arr = []
        // presetDurations = JSON [{"s":seconds,"n":"name"}]; array order = menu order.
        // Falls back to the old CSV-of-seconds format for existing configs.
        var raw = String(Plasmoid.configuration.presetDurations).trim()
        var list = null
        try { list = JSON.parse(raw) } catch (e) { list = null }
        if (!Array.isArray(list)) {
            list = []
            var csv = raw.split(",")
            for (var k = 0; k < csv.length; k++) {
                var v = parseInt(csv[k])
                if (v > 0) list.push({ "s": v, "n": "" })
            }
        }
        for (var i = 0; i < list.length; i++) {
            var s = parseInt(list[i].s) || 0
            if (s <= 0) continue
            // "Set hh:mm:ss [name]" — fmt() already handles hours.
            var label = lang.tr("set", root.fmt(s))
            if (list[i].n) label += " " + list[i].n
            var a = actionComponent.createObject(root, { text: label })
            a.triggered.connect((function (ss) { return function () { root.setSeconds(ss) } })(s))
            arr.push(a)
        }
        root.presetActions = arr
        for (var j = 0; j < old.length; j++) old[j].destroy()
    }
    Component.onCompleted: rebuildPresets()

    Plasmoid.contextualActions: [startAction, resetAction, separatorAction]
        .concat(root.presetActions)
        .concat([separator2Action, setTimeAction])

    // Free-duration input window (right-click -> "Set a time…")
    Window {
        id: setTimeWindow
        width: Kirigami.Units.gridUnit * 18
        height: Kirigami.Units.gridUnit * 9
        minimumWidth: width
        minimumHeight: height
        flags: Qt.Dialog
        modality: Qt.ApplicationModal
        title: lang.t("setTimeTitle")
        color: Kirigami.Theme.backgroundColor

        function openWith(sec) {
            inH.value = Math.floor(sec / 3600)
            inM.value = Math.floor((sec % 3600) / 60)
            inS.value = sec % 60
            setTimeWindow.visible = true
            setTimeWindow.raise()
            setTimeWindow.requestActivate()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing
                QQC2.SpinBox { id: inH; from: 0; to: 99 }
                QQC2.Label { text: ":" }
                QQC2.SpinBox { id: inM; from: 0; to: 59 }
                QQC2.Label { text: ":" }
                QQC2.SpinBox { id: inS; from: 0; to: 59 }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Kirigami.Units.smallSpacing
                QQC2.Button {
                    text: lang.t("cancel")
                    onClicked: setTimeWindow.visible = false
                }
                QQC2.Button {
                    text: lang.t("ok")
                    onClicked: {
                        root.setSeconds(inH.value * 3600 + inM.value * 60 + inS.value)
                        setTimeWindow.visible = false
                    }
                }
            }
        }
    }

    // ----- Reusable buttons -----
    // Sides: 0 = left, 1 = right, 2 = top, 3 = bottom (relative to the digits)
    Component {
        id: startButton
        PlasmaComponents.Button {
            icon.name: root.running ? "media-playback-pause" : "media-playback-start"
            text: Plasmoid.configuration.showStartLabel
                  ? (root.running ? lang.t("pause") : lang.t("start")) : ""
            display: Plasmoid.configuration.showStartLabel
                     ? QQC2.AbstractButton.TextBesideIcon : QQC2.AbstractButton.IconOnly
            onClicked: root.toggle()
        }
    }
    Component {
        id: resetButton
        PlasmaComponents.Button {
            icon.name: "edit-reset"
            text: Plasmoid.configuration.showResetLabel ? lang.t("reset") : ""
            display: Plasmoid.configuration.showResetLabel
                     ? QQC2.AbstractButton.TextBesideIcon : QQC2.AbstractButton.IconOnly
            onClicked: root.reset()
        }
    }

    // On the desktop we always want the inline digits. In a panel, honor the user's
    // choice: a compact progress ring (click -> popup with the digits) when enabled,
    // otherwise keep the inline digits (the project's original behavior).
    preferredRepresentation: Plasmoid.configuration.compactInPanel ? null : fullRepresentation

    // By default Plasma caps a compact applet to the standard panel icon size, leaving a
    // big margin in a thick panel. CanFillArea lets the ring fill the whole thickness.
    // (The enum lives on Plasma::Applet, i.e. the Plasmoid attached object.)
    Plasmoid.constraintHints: Plasmoid.configuration.compactInPanel
        ? Plasmoid.CanFillArea : Plasmoid.NoHint

    // Tooltip on the compact ring: remaining time
    toolTipSubText: root.fmt(root.remaining)

    // Compact panel representation: a logo (chronometer icon or a custom image) with the
    // progress shown either as a ring around it or as a bar below it.
    compactRepresentation: MouseArea {
        id: compactRoot
        // Keep the applet square against the panel thickness: in a horizontal panel the
        // height is fixed -> lock the width to it; in a vertical panel the width is fixed
        // -> lock the height to it. (Avoids the width<->height binding loop.)
        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        Layout.minimumWidth: vertical ? Kirigami.Units.iconSizes.small : compactRoot.height
        Layout.maximumWidth: vertical ? Infinity : compactRoot.height
        Layout.minimumHeight: vertical ? compactRoot.width : Kirigami.Units.iconSizes.small
        Layout.maximumHeight: vertical ? compactRoot.width : Infinity

        onClicked: root.expanded = !root.expanded

        // Largest square that fits the applet, used to size the ring and the logo.
        readonly property int face: Math.min(width, height)
        readonly property bool barMode: Plasmoid.configuration.compactBar

        // Progress shared by both styles. "Empty" mode (default) shows the time left
        // (full at start -> empties); "Fill" mode shows the time elapsed (empty at start).
        readonly property real progress: root.target > 0
            ? Math.max(0, Math.min(1, root.remaining / root.target)) : 0
        readonly property real fraction: Plasmoid.configuration.compactRingFill
            ? (1 - progress) : progress
        readonly property color trackColor: Kirigami.Theme.textColor
        readonly property color arcColor: root.remaining <= 0
            ? Kirigami.Theme.negativeTextColor
            : root.warnActive
                ? (Plasmoid.configuration.warnColor !== ""
                   ? Plasmoid.configuration.warnColor
                   : Kirigami.Theme.negativeTextColor)
                : Kirigami.Theme.highlightColor

        // The logo source: a custom image if set, otherwise the chronometer icon.
        readonly property string logoSource: Plasmoid.configuration.compactIconPath !== ""
            ? Plasmoid.configuration.compactIconPath : "chronometer"

        // ----- RING STYLE: ring drawn around a centered logo -----
        Canvas {
            id: ring
            anchors.fill: parent
            visible: !compactRoot.barMode

            Component.onCompleted: requestPaint()
            Connections {
                target: compactRoot
                function onFractionChanged() { ring.requestPaint() }
                function onArcColorChanged() { ring.requestPaint() }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var size = Math.min(width, height)
                var lineW = Math.max(2, Math.round(size * 0.14))
                // Centered on the whole canvas; outer edge of the stroke on the square edge.
                var cx = width / 2
                var cy = height / 2
                var r = size / 2 - lineW / 2
                if (r <= 0) return

                // Track (full circle, faint)
                ctx.beginPath()
                ctx.lineWidth = lineW
                ctx.strokeStyle = compactRoot.trackColor
                ctx.globalAlpha = 0.25
                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                ctx.stroke()

                // Progress arc, clockwise from 12 o'clock
                ctx.globalAlpha = 1.0
                ctx.beginPath()
                ctx.lineWidth = lineW
                ctx.strokeStyle = compactRoot.arcColor
                ctx.lineCap = "round"
                var start = -Math.PI / 2
                ctx.arc(cx, cy, r, start, start + 2 * Math.PI * compactRoot.fraction)
                ctx.stroke()
            }
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            visible: !compactRoot.barMode && Plasmoid.configuration.compactIconScale > 0
            width: Math.round(compactRoot.face * Plasmoid.configuration.compactIconScale / 100)
            height: width
            source: compactRoot.logoSource
        }

        // ----- BAR STYLE: logo on top, progress bar below -----
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(compactRoot.face * 0.08)
            visible: compactRoot.barMode
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumHeight: compactRoot.face * Plasmoid.configuration.compactIconScale / 100
                visible: Plasmoid.configuration.compactIconScale > 0
                source: compactRoot.logoSource
            }

            // Progress bar (faint track + colored fill)
            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                implicitHeight: Math.max(3, Math.round(compactRoot.face * 0.14))
                radius: height / 2
                color: Qt.rgba(compactRoot.trackColor.r, compactRoot.trackColor.g,
                               compactRoot.trackColor.b, 0.25)

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * compactRoot.fraction
                    height: parent.height
                    radius: parent.radius
                    color: compactRoot.arcColor
                }
            }
        }
    }

    // A button loader: instantiated only when active, and excluded from the layout
    // otherwise (visible:false) so it takes no cell nor spacing.
    component BtnLoader: Loader {
        property bool show: false
        Layout.alignment: Qt.AlignCenter
        active: show
        visible: show
    }

    fullRepresentation: Item {
        Layout.minimumWidth: stack.implicitWidth + Kirigami.Units.largeSpacing * 2
        Layout.minimumHeight: stack.implicitHeight + Kirigami.Units.largeSpacing * 2

        // Top / (left - digits - right) / bottom
        ColumnLayout {
            id: stack
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            // --- TOP ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing
                visible: (Plasmoid.configuration.showStartButton && root.startSide === 2)
                         || (Plasmoid.configuration.showResetButton && root.resetSide === 2)
                BtnLoader {
                    sourceComponent: startButton
                    show: Plasmoid.configuration.showStartButton && root.startSide === 2
                }
                BtnLoader {
                    sourceComponent: resetButton
                    show: Plasmoid.configuration.showResetButton && root.resetSide === 2
                }
            }

            // --- MIDDLE: left | digits | right ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter   // vertically centered on the digits
                    Layout.fillHeight: false            // do not stretch to full height
                    spacing: Kirigami.Units.smallSpacing
                    visible: (Plasmoid.configuration.showStartButton && root.startSide === 0)
                             || (Plasmoid.configuration.showResetButton && root.resetSide === 0)
                    BtnLoader {
                        sourceComponent: startButton
                        show: Plasmoid.configuration.showStartButton && root.startSide === 0
                    }
                    BtnLoader {
                        sourceComponent: resetButton
                        show: Plasmoid.configuration.showResetButton && root.resetSide === 0
                    }
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignVCenter
                    text: root.fmt(root.remaining)
                    font.pointSize: Plasmoid.configuration.fontSize
                    font.family: Plasmoid.configuration.fontFamily !== ""
                                 ? Plasmoid.configuration.fontFamily
                                 : Kirigami.Theme.defaultFont.family
                    color: root.remaining <= 0
                           ? Kirigami.Theme.negativeTextColor
                           : root.warnActive
                             ? (Plasmoid.configuration.warnColor !== ""
                                ? Plasmoid.configuration.warnColor
                                : Kirigami.Theme.negativeTextColor)
                             : (Plasmoid.configuration.fontColor !== ""
                                ? Plasmoid.configuration.fontColor
                                : Kirigami.Theme.textColor)
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillHeight: false
                    spacing: Kirigami.Units.smallSpacing
                    visible: (Plasmoid.configuration.showStartButton && root.startSide === 1)
                             || (Plasmoid.configuration.showResetButton && root.resetSide === 1)
                    BtnLoader {
                        sourceComponent: startButton
                        show: Plasmoid.configuration.showStartButton && root.startSide === 1
                    }
                    BtnLoader {
                        sourceComponent: resetButton
                        show: Plasmoid.configuration.showResetButton && root.resetSide === 1
                    }
                }
            }

            // --- BOTTOM ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing
                visible: (Plasmoid.configuration.showStartButton && root.startSide === 3)
                         || (Plasmoid.configuration.showResetButton && root.resetSide === 3)
                BtnLoader {
                    sourceComponent: startButton
                    show: Plasmoid.configuration.showStartButton && root.startSide === 3
                }
                BtnLoader {
                    sourceComponent: resetButton
                    show: Plasmoid.configuration.showResetButton && root.resetSide === 3
                }
            }
        }
    }
}
