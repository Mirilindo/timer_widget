import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtMultimedia
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.notification

PlasmoidItem {
    id: root

    // ===== State =====
    // Two modes share the same display and buttons:
    //  - countdown: counts down from `target` (a duration picked in the menu);
    //  - stopwatch: counts up from zero, with no end.
    // The mode and the last picked duration are remembered in hidden config entries, so
    // the widget comes back as it was left (but stopped) after a Plasma restart.
    readonly property bool chrono: Plasmoid.configuration.timerMode === 1
    property bool running: false

    // Countdown.
    // target    = picked duration (seconds); remaining = seconds left (shown);
    // endTime   = wall-clock epoch (ms) at which it hits zero, valid only while running.
    //             Counting from the clock instead of ticks keeps it accurate over long
    //             durations and survives system sleep.
    // total     = reference of the current run for the ring and the warning color: the
    //             picked duration, raised when the + button goes above it. Reset always
    //             goes back to `target`, never to `total`.
    // targetName = optional name of the picked duration, shown in the notification.
    property int target: 0
    property int total: 0
    property int remaining: 0
    property double endTime: 0
    property string targetName: ""

    // Stopwatch.
    // elapsedMs    = time accumulated by finished run segments (the paused value);
    // runStartTime = wall-clock epoch (ms) at which the current segment started;
    // elapsed      = whole seconds shown, refreshed by the Timer below.
    property double elapsedMs: 0
    property double runStartTime: 0
    property int elapsed: 0

    // Seconds shown by the digits and the tooltip, whatever the mode.
    readonly property int shown: root.chrono ? root.elapsed : root.remaining
    // Something has happened since the last reset (drives the compact ring/bar).
    readonly property bool active: root.chrono
        ? (root.running || root.elapsed > 0)
        : (root.running || (root.target > 0 && root.remaining !== root.target))

    // Warning color: when the remaining time is <= warnPercent % of the total (and > 0).
    readonly property bool warnActive: !root.chrono
        && Plasmoid.configuration.warnEnabled
        && root.total > 0
        && root.remaining > 0
        && root.remaining <= root.total * Plasmoid.configuration.warnPercent / 100

    // A configured color if it is a valid hex code (#rgb, #rrggbb, #aarrggbb), otherwise
    // the fallback: a half-typed code must not break the digits color.
    function colorOr(value, fallback) {
        return /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(value) ? value : fallback
    }

    // Digits color, shared by every view: red once the countdown is over, warning color
    // near the end, otherwise the configured (or theme) color.
    readonly property color digitsColor: (!root.chrono && root.remaining <= 0)
        ? Kirigami.Theme.negativeTextColor
        : root.warnActive
          ? root.colorOr(Plasmoid.configuration.warnColor, Kirigami.Theme.negativeTextColor)
          : root.colorOr(Plasmoid.configuration.fontColor, Kirigami.Theme.textColor)
    readonly property string digitsFamily: Plasmoid.configuration.fontFamily !== ""
        ? Plasmoid.configuration.fontFamily : Kirigami.Theme.defaultFont.family

    Component.onCompleted: {
        root.target = Math.max(1, Plasmoid.configuration.lastDuration)
        root.total = root.target
        root.remaining = root.target
        root.targetName = Plasmoid.configuration.lastDurationName
        root.rebuildPresets()
    }

    // Translations (strings.js)
    Translations { id: lang }

    // ===== Formatting =====
    function pad(n) { return n < 10 ? "0" + n : "" + n }
    // Digits: mm:ss, or hh:mm:ss from one hour.
    function fmt(s) {
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        var sec = s % 60
        return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(sec)
    }
    // Readable duration, zero parts omitted: 15 min / 1 h / 1 h 30 min / 45 s.
    // Used by the menu, the notification and the +/- button texts.
    function fmtLong(s) {
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        var sec = s % 60
        var parts = []
        if (h > 0) parts.push(h + " h")
        if (m > 0) parts.push(m + " min")
        if (sec > 0) parts.push(sec + " s")
        return parts.length > 0 ? parts.join(" ") : "0 s"
    }

    // ===== Actions =====
    function liveElapsedMs() {
        return root.elapsedMs + (root.running ? (Date.now() - root.runStartTime) : 0)
    }
    function start() {
        if (root.chrono) {
            root.runStartTime = Date.now()
            root.running = true
            return
        }
        if (root.remaining <= 0) {
            root.total = root.target
            root.remaining = root.target
        }
        root.endTime = Date.now() + root.remaining * 1000
        root.running = true
    }
    function pause() {
        if (root.chrono) {
            root.elapsedMs = root.liveElapsedMs()
            root.running = false
            root.elapsed = Math.floor(root.elapsedMs / 1000)
            return
        }
        root.remaining = Math.max(0, Math.ceil((root.endTime - Date.now()) / 1000))
        root.running = false
    }
    function toggle() {
        if (root.running) root.pause()
        else root.start()
    }
    // Always the same thing: back to the picked duration (countdown) or to zero (stopwatch).
    function reset() {
        root.running = false
        root.endTime = 0
        root.total = root.target
        root.remaining = root.target
        root.elapsedMs = 0
        root.runStartTime = 0
        root.elapsed = 0
    }
    function setMode(m) {
        if (Plasmoid.configuration.timerMode !== m) Plasmoid.configuration.timerMode = m
    }
    // Menu: a countdown duration. Switches to the countdown, ready to start (not started),
    // and remembers the duration for the next session.
    function chooseDuration(s, name) {
        root.setMode(0)
        root.reset()
        root.target = s
        root.total = s
        root.remaining = s
        root.targetName = name ? name : ""
        Plasmoid.configuration.lastDuration = s
        Plasmoid.configuration.lastDurationName = root.targetName
    }
    // Menu: start the stopwatch from zero (restarts it if it was running). Written without
    // relying on root.chrono, which may update only after the mode change is processed.
    function startStopwatch() {
        root.setMode(1)
        root.reset()
        root.runStartTime = Date.now()
        root.running = true
    }
    // +/- buttons: add (or remove) time to the countdown, running or paused.
    function addSeconds(delta) {
        if (root.chrono) return
        var base = root.running
            ? Math.max(0, Math.ceil((root.endTime - Date.now()) / 1000))
            : root.remaining
        var v = Math.max(0, base + delta)
        root.remaining = v
        // Keep the ring/progress consistent if we went above the run's total (the picked
        // duration itself is left alone, so Reset still goes back to it).
        if (v > root.total) root.total = v
        if (root.running) {
            if (v <= 0) {
                // Reached zero by removing time: stop silently (no beep/notification).
                root.running = false
                root.endTime = 0
            } else {
                root.endTime = Date.now() + v * 1000
            }
        }
    }
    function onFinished() {
        var n = Plasmoid.configuration.beepCount
        if (n > 0) {
            beep.stop()
            beep.loops = n
            beep.play()
        }
        if (Plasmoid.configuration.showNotification) doneNotification.sendEvent()
    }

    // End sound: custom file if set, otherwise the bundled beep
    MediaPlayer {
        id: beep
        source: Plasmoid.configuration.customSoundPath !== ""
                ? Plasmoid.configuration.customSoundPath
                : Qt.resolvedUrl("../sounds/freesound_community-beep-6-96243.mp3")
        audioOutput: AudioOutput { }
    }

    Notification {
        id: doneNotification
        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "chronometer"
        // Name in the title (if the duration has one); the body is just the duration.
        title: root.targetName !== ""
               ? lang.tr("notifTitleNamed", root.targetName)
               : lang.t("notifTitle")
        text: root.fmtLong(root.target)
    }

    // Recompute the shown time from the clock while running. The value is derived from
    // endTime / runStartTime, so there is no drift and a wake-from-sleep simply catches up.
    Timer {
        interval: 200
        repeat: true
        running: root.running
        onTriggered: {
            if (root.chrono) {
                root.elapsed = Math.floor(root.liveElapsedMs() / 1000)
                return
            }
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

    Connections {
        target: Plasmoid.configuration
        function onPresetDurationsChanged() { root.rebuildPresets() }
    }

    // ===== Menus =====
    // Right-click menu:  Start/Pause, Reset | countdowns, other duration | stopwatch |
    // (Plasma's own entries). Clicking the stopped digits opens the same menu, without
    // Start/Reset (the "launch menu").
    PlasmaCore.Action {
        id: startAction
        text: root.running ? lang.t("pause") : lang.t("start")
        icon.name: root.running ? "media-playback-pause" : "media-playback-start"
        onTriggered: root.toggle()
    }
    PlasmaCore.Action {
        id: resetAction
        text: lang.t("reset")
        icon.name: "chronometer-reset"
        onTriggered: root.reset()
    }
    PlasmaCore.Action { id: sep1; isSeparator: true }
    PlasmaCore.Action {
        id: customAction
        text: lang.t("customCountdown")
        icon.name: "document-edit"
        onTriggered: setTimeWindow.openWith(0)
    }
    PlasmaCore.Action { id: sep2; isSeparator: true }
    PlasmaCore.Action {
        id: stopwatchAction
        text: lang.t("startStopwatch")
        icon.name: "chronometer-start"
        onTriggered: root.startStopwatch()
    }
    // Separates our entries from the ones Plasma appends ("Configure Big Timer…").
    PlasmaCore.Action { id: sep3; isSeparator: true }

    property var presetActions: []
    Component {
        id: actionComponent
        PlasmaCore.Action { }
    }
    // presetDurations = JSON [{"s":seconds,"n":"name"}]; array order = menu order.
    function parsePresets() {
        var list = null
        try { list = JSON.parse(Plasmoid.configuration.presetDurations) } catch (e) { list = null }
        return Array.isArray(list) ? list : []
    }
    function rebuildPresets() {
        var old = root.presetActions
        var arr = []
        var list = root.parsePresets()
        for (var i = 0; i < list.length; i++) {
            var s = parseInt(list[i].s) || 0
            if (s <= 0) continue
            var nm = list[i].n ? String(list[i].n) : ""
            // "Countdown 15 min [name]"
            var label = lang.t("modeCountdown") + " " + root.fmtLong(s) + (nm ? " " + nm : "")
            var a = actionComponent.createObject(root, { text: label })
            a.triggered.connect((function (ss, nn) {
                return function () { root.chooseDuration(ss, nn) }
            })(s, nm))
            arr.push(a)
        }
        root.presetActions = arr
        for (var j = 0; j < old.length; j++) old[j].destroy()
    }
    readonly property var launchActions: root.presetActions
        .concat([customAction, sep2, stopwatchAction])

    Plasmoid.contextualActions: [startAction, resetAction, sep1]
        .concat(root.launchActions)
        .concat([sep3])

    PlasmaExtras.Menu {
        id: launchMenu
        placement: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
    }
    Component {
        id: menuItemComponent
        PlasmaExtras.MenuItem { }
    }
    // Items of the last opening, destroyed before building new ones (clearMenuItems only
    // takes them out of the menu).
    property var launchMenuItems: []
    // Opens the launch menu under `item` (the clicked digits).
    function openLaunchMenu(item) {
        launchMenu.clearMenuItems()
        for (var j = 0; j < root.launchMenuItems.length; j++) {
            // null if Plasma already deleted it.
            if (root.launchMenuItems[j]) root.launchMenuItems[j].destroy()
        }
        var created = []
        for (var i = 0; i < root.launchActions.length; i++) {
            var mi = menuItemComponent.createObject(launchMenu, { action: root.launchActions[i] })
            launchMenu.addMenuItem(mi)
            created.push(mi)
        }
        root.launchMenuItems = created
        launchMenu.visualParent = item
        launchMenu.openRelative()
    }

    // "Other duration…" window
    Window {
        id: setTimeWindow
        // Wide enough for the three boxes and their units.
        width: Math.max(Kirigami.Units.gridUnit * 18,
                        timeRow.implicitWidth + Kirigami.Units.largeSpacing * 2)
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

            // Each box followed by its unit, written like in the menu ("1 h 30 min").
            RowLayout {
                id: timeRow
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing
                QQC2.SpinBox { id: inH; from: 0; to: 99 }
                QQC2.Label { text: "h" }
                Item { implicitWidth: Kirigami.Units.largeSpacing }
                QQC2.SpinBox { id: inM; from: 0; to: 59 }
                QQC2.Label { text: "min" }
                Item { implicitWidth: Kirigami.Units.largeSpacing }
                QQC2.SpinBox { id: inS; from: 0; to: 59 }
                QQC2.Label { text: "s" }
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
                        var s = inH.value * 3600 + inM.value * 60 + inS.value
                        if (s > 0) root.chooseDuration(s, "")
                        setTimeWindow.visible = false
                    }
                }
            }
        }
    }

    // ===== Buttons =====
    // One shared size (points, 0 = theme default) and one "show text" option.
    // The icon is scaled ~1.4x the point size so it matches the text.
    readonly property int btnSize: Plasmoid.configuration.buttonSize
    readonly property bool btnText: Plasmoid.configuration.showButtonLabels
    // +/- only change a countdown.
    readonly property bool plusMinus: Plasmoid.configuration.showPlusMinus && !root.chrono

    component TimerButton: PlasmaComponents.Button {
        // Computed once and given to both sides: "icon.height: icon.width" is a binding loop,
        // since `icon` is a single grouped value.
        readonly property int iconPx: root.btnSize > 0 ? Math.round(root.btnSize * 1.4)
                                                       : Kirigami.Units.iconSizes.smallMedium  // 22 px: Breeze draws these icons up to 24
        icon.width: iconPx
        icon.height: iconPx
        font.pointSize: root.btnSize > 0 ? root.btnSize : Kirigami.Theme.defaultFont.pointSize
        display: root.btnText ? QQC2.AbstractButton.TextBesideIcon : QQC2.AbstractButton.IconOnly
        // Icon only: the text becomes a tooltip.
        QQC2.ToolTip.text: text
        QQC2.ToolTip.visible: hovered && !root.btnText
        // Keep the button square when it shows no text.
        Binding on implicitWidth {
            when: !root.btnText
            value: implicitHeight
        }
    }
    component StartButton: TimerButton {
        icon.name: root.running ? "media-playback-pause" : "media-playback-start"
        text: root.running ? lang.t("pause") : lang.t("start")
        onClicked: root.toggle()
    }
    component ResetButton: TimerButton {
        icon.name: "chronometer-reset"
        text: lang.t("reset")
        onClicked: root.reset()
    }
    // +/- : plain "+"/"−" text (theme-neutral), with the step as suffix when texts are shown.
    component StepButton: PlasmaComponents.Button {
        property int sign: 1
        visible: root.plusMinus
        display: QQC2.AbstractButton.TextOnly
        font.pointSize: root.btnSize > 0 ? root.btnSize : Kirigami.Theme.defaultFont.pointSize
        text: (sign > 0 ? "+" : "−")
              + (root.btnText ? root.fmtLong(Plasmoid.configuration.quickStepSeconds) : "")
        onClicked: root.addSeconds(sign * Plasmoid.configuration.quickStepSeconds)
        Binding on implicitWidth {
            when: !root.btnText
            value: implicitHeight
        }
    }

    // ===== Views =====
    // The digits. Clicking them while stopped opens the launch menu.
    component Digits: QQC2.Label {
        id: digits
        text: root.fmt(root.shown)
        font.family: root.digitsFamily
        color: root.digitsColor
        MouseArea {
            anchors.fill: parent
            enabled: !root.running
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.openLaunchMenu(digits)
        }
    }

    // Button layout: 0 = Reset left / Start right of the digits, 1 = below, 2 = above,
    // 3 = no buttons.
    readonly property int btnLayout: Plasmoid.configuration.buttonLayout

    component ButtonRow: RowLayout {
        spacing: Kirigami.Units.largeSpacing
        ResetButton { }
        StepButton { sign: -1 }
        StepButton { sign: 1 }
        StartButton { }
    }

    // Full view (desktop, and the popup opened from a panel).
    component TimerView: Item {
        implicitWidth: tvStack.implicitWidth + Kirigami.Units.largeSpacing * 2
        implicitHeight: tvStack.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: tvStack
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            ButtonRow {
                Layout.alignment: Qt.AlignHCenter
                visible: root.btnLayout === 2
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                RowLayout {
                    visible: root.btnLayout === 0
                    spacing: Kirigami.Units.largeSpacing
                    ResetButton { }
                    StepButton { sign: -1 }
                }
                Digits {
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: Plasmoid.configuration.fontSize
                }
                RowLayout {
                    visible: root.btnLayout === 0
                    spacing: Kirigami.Units.largeSpacing
                    StepButton { sign: 1 }
                    StartButton { }
                }
            }

            ButtonRow {
                Layout.alignment: Qt.AlignHCenter
                visible: root.btnLayout === 1
            }
        }
    }

    // Plasma picks the representation: full view on the desktop, compact one in a panel.
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                                    || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    preferredRepresentation: root.inPanel ? compactRepresentation : fullRepresentation

    fullRepresentation: TimerView {
        // Without preferred/maximum sizes, the panel popup falls back to a default size
        // larger than the content.
        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        Layout.maximumWidth: implicitWidth
        Layout.maximumHeight: implicitHeight
    }

    // Let the compact view use the panel's whole thickness instead of the standard icon
    // size. (The enum lives on Plasma::Applet, i.e. the Plasmoid attached object.)
    Plasmoid.constraintHints: Plasmoid.CanFillArea

    toolTipMainText: root.chrono ? lang.t("modeStopwatch") : lang.t("modeCountdown")
    toolTipSubText: root.fmt(root.shown)
    // Custom tooltip content so both lines are centered (Plasma's default one is
    // left-aligned). The two texts above are kept for accessibility.
    toolTipItem: Item {
        implicitWidth: tipColumn.implicitWidth + Kirigami.Units.gridUnit
        implicitHeight: tipColumn.implicitHeight + Kirigami.Units.gridUnit
        ColumnLayout {
            id: tipColumn
            anchors.centerIn: parent
            spacing: 0
            Kirigami.Heading {
                Layout.alignment: Qt.AlignHCenter
                level: 3
                text: root.toolTipMainText
                horizontalAlignment: Text.AlignHCenter
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.toolTipSubText
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.75
            }
        }
    }

    // Logo: a theme icon (drawn square by Kirigami.Icon) or a custom image (PreserveAspectFit,
    // so a rectangular logo keeps its ratio).
    component CompactLogo: Item {
        readonly property bool custom: Plasmoid.configuration.compactIconPath !== ""
        Kirigami.Icon {
            anchors.fill: parent
            visible: !parent.custom
            source: parent.custom ? "" : "chronometer"
            roundToIconSize: false
        }
        Image {
            anchors.fill: parent
            visible: parent.custom
            source: parent.custom ? Plasmoid.configuration.compactIconPath : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            asynchronous: true
        }
    }

    // Panel: the time (default) or the icon with a progress ring/bar. A click opens the
    // full view in the standard Plasma popup.
    compactRepresentation: MouseArea {
        id: compactRoot
        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        // panelDisplay: 0 = time, 1 = icon while idle, then the time once started (running
        // or paused, until reset), 2 = icon with progress.
        readonly property int display: Plasmoid.configuration.panelDisplay
        readonly property bool iconMode: compactRoot.display === 2
                                         || (compactRoot.display === 1 && !root.active)

        onClicked: root.expanded = !root.expanded

        // --- Time mode: digits sized to the panel thickness ---
        QQC2.Label {
            id: panelDigits
            anchors.centerIn: parent
            visible: !compactRoot.iconMode
            text: root.fmt(root.shown)
            font.family: root.digitsFamily
            color: root.digitsColor
            // Horizontal panel: 60 % of its height (the applet widens to fit the text).
            // Vertical panel: the largest size at which the actual text fits the width, so
            // "01:02:03" (stopwatch past an hour) does not overflow, capped at the horizontal rule.
            font.pixelSize: Math.max(6, compactRoot.vertical
                ? Math.min(Math.round(compactRoot.width * 0.6),
                           digitsMetrics.advanceWidth > 0
                           ? Math.floor((compactRoot.width - Kirigami.Units.smallSpacing * 2)
                                        * 100 / digitsMetrics.advanceWidth)
                           : Math.round(compactRoot.width / 3.2))
                : Math.round(compactRoot.height * 0.6))
        }
        // Width of the current text at 100 px, to scale it to a vertical panel's width.
        TextMetrics {
            id: digitsMetrics
            font.family: root.digitsFamily
            font.pixelSize: 100
            text: panelDigits.text
        }

        // --- Icon mode: a custom rectangular logo sets the applet ratio (except the ring,
        // which needs a square). Capped so a very wide logo does not make a huge applet.
        readonly property bool customLogo: Plasmoid.configuration.compactIconPath !== ""
        Image {
            id: logoProbe
            source: Plasmoid.configuration.compactIconPath
            visible: false
            asynchronous: true
        }
        readonly property real logoAspect: (customLogo && logoProbe.sourceSize.height > 0)
            ? Math.max(0.25, Math.min(4, logoProbe.sourceSize.width / logoProbe.sourceSize.height))
            : 1
        readonly property bool barMode: Plasmoid.configuration.compactBar
        readonly property real boxAspect: (customLogo && !(root.active && !barMode)) ? logoAspect : 1

        Layout.minimumWidth: !iconMode
            ? (vertical ? Kirigami.Units.iconSizes.small
                        : panelDigits.implicitWidth + Kirigami.Units.smallSpacing * 2)
            : (vertical ? Kirigami.Units.iconSizes.small : Math.round(compactRoot.height * boxAspect))
        Layout.maximumWidth: !iconMode
            ? (vertical ? Infinity : Layout.minimumWidth)
            : (vertical ? Infinity : Math.round(compactRoot.height * boxAspect))
        Layout.minimumHeight: !iconMode
            ? (vertical ? panelDigits.implicitHeight + Kirigami.Units.smallSpacing * 2
                        : Kirigami.Units.iconSizes.small)
            : (vertical ? Math.round(compactRoot.width / boxAspect) : Kirigami.Units.iconSizes.small)
        Layout.maximumHeight: !iconMode
            ? (vertical ? Layout.minimumHeight : Infinity)
            : (vertical ? Math.round(compactRoot.width / boxAspect) : Infinity)

        // Largest square that fits the applet, used to size the ring and the logo.
        readonly property int face: Math.min(width, height)
        // Lone logo while nothing is going on, progress once active.
        readonly property bool bigLogo: !root.active

        // Countdown: time left (empties) or elapsed (fills). Stopwatch: no target, so the
        // ring/bar works like a second hand, one full turn per minute.
        readonly property real progress: root.total > 0
            ? Math.max(0, Math.min(1, root.remaining / root.total)) : 0
        readonly property real sweep: root.elapsed > 0 && root.elapsed % 60 === 0
            ? 1 : (root.elapsed % 60) / 60
        readonly property real fraction: root.chrono
            ? sweep
            : (Plasmoid.configuration.compactRingFill ? (1 - progress) : progress)
        readonly property color trackColor: Kirigami.Theme.textColor
        readonly property color arcColor: root.chrono
            ? Kirigami.Theme.highlightColor
            : (root.remaining <= 0 || root.warnActive) ? root.digitsColor
                                                       : Kirigami.Theme.highlightColor

        // Ring style
        Canvas {
            id: ring
            anchors.fill: parent
            visible: compactRoot.iconMode && root.active && !compactRoot.barMode
            onVisibleChanged: if (visible) requestPaint()
            Component.onCompleted: requestPaint()
            Connections {
                target: compactRoot
                function onFractionChanged() { ring.requestPaint() }
                function onArcColorChanged() { ring.requestPaint() }
            }
            Connections {
                target: Plasmoid.configuration
                function onCompactRingThicknessChanged() { ring.requestPaint() }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                // Inset from the panel edges, then a stroke whose thickness is a % of the
                // remaining diameter.
                var margin = Math.round(Math.min(width, height) * 0.07)
                var size = Math.min(width, height) - margin * 2
                if (size <= 0) return
                var lineW = Math.max(2, Math.round(size * Plasmoid.configuration.compactRingThickness / 100))
                var cx = width / 2
                var cy = height / 2
                var r = size / 2 - lineW / 2
                if (r <= 0) return

                ctx.beginPath()
                ctx.lineWidth = lineW
                ctx.strokeStyle = compactRoot.trackColor
                ctx.globalAlpha = 0.25
                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                ctx.stroke()

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

        CompactLogo {
            anchors.centerIn: parent
            visible: compactRoot.iconMode
                     && (compactRoot.bigLogo
                         || (!compactRoot.barMode && Plasmoid.configuration.compactIconScale > 0))
            width: compactRoot.bigLogo
                   ? Math.round(compactRoot.width * 0.9)
                   : Math.round(compactRoot.face * Plasmoid.configuration.compactIconScale / 100)
            height: compactRoot.bigLogo ? Math.round(compactRoot.height * 0.9) : width
        }

        // Bar style: logo on top, progress bar below
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(compactRoot.face * 0.08)
            visible: compactRoot.iconMode && root.active && compactRoot.barMode
            spacing: Kirigami.Units.smallSpacing

            CompactLogo {
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumHeight: compactRoot.face * Plasmoid.configuration.compactIconScale / 100
                visible: Plasmoid.configuration.compactIconScale > 0
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                implicitHeight: Math.max(3, Math.round(compactRoot.face
                                * Plasmoid.configuration.compactRingThickness / 100))
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
}
