import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtMultimedia
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // target = durée visée (par défaut ou choisie via le menu) ; remaining = ce qui reste
    property int target: Plasmoid.configuration.defaultDuration
    property int remaining: target
    property bool running: false

    readonly property int startSide: Plasmoid.configuration.startButtonSide
    readonly property int resetSide: Plasmoid.configuration.resetButtonSide

    // Traductions (strings.json)
    Translations { id: lang }

    function pad(n) { return n < 10 ? "0" + n : "" + n }
    function fmt(s) {
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        var sec = s % 60
        return (h > 0 ? pad(h) + ":" : "") + pad(m) + ":" + pad(sec)
    }

    function toggle() {
        if (root.remaining <= 0) root.remaining = root.target
        root.running = !root.running
    }
    function reset() {
        root.running = false
        root.remaining = root.target
    }
    function setMinutes(m) {
        root.running = false
        root.target = m * 60
        root.remaining = m * 60
    }
    function playBeep() {
        var n = Plasmoid.configuration.beepCount
        if (n > 0) {
            beep.stop()
            beep.loops = n
            beep.play()
        }
    }

    // Son de fin
    MediaPlayer {
        id: beep
        source: Qt.resolvedUrl("../sounds/freesound_community-beep-6-96243.mp3")
        audioOutput: AudioOutput { }
    }

    // Tic d'une seconde, actif seulement quand le minuteur tourne
    Timer {
        interval: 1000
        repeat: true
        running: root.running && root.remaining > 0
        onTriggered: {
            root.remaining--
            if (root.remaining <= 0) {
                root.running = false
                root.playBeep()
            }
        }
    }

    // Recalage sur la durée par défaut quand on la change dans les réglages (à l'arrêt)
    Connections {
        target: Plasmoid.configuration
        function onDefaultDurationChanged() {
            if (!root.running) {
                root.target = Plasmoid.configuration.defaultDuration
                root.remaining = root.target
            }
        }
        function onPresetMinutesChanged() {
            root.rebuildPresets()
        }
    }

    // ----- Menu clic droit -----
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

    property var presetActions: []
    Component {
        id: actionComponent
        PlasmaCore.Action { }
    }
    function rebuildPresets() {
        var old = root.presetActions
        var arr = []
        var parts = String(Plasmoid.configuration.presetMinutes).split(",")
        for (var i = 0; i < parts.length; i++) {
            var m = parseInt(parts[i])
            if (!(m > 0)) continue
            // strings.js est chargé d'office -> lang.tr() est fiable immédiatement
            var a = actionComponent.createObject(root, { text: lang.tr("setMin", m) })
            a.triggered.connect((function (mm) { return function () { root.setMinutes(mm) } })(m))
            arr.push(a)
        }
        root.presetActions = arr
        for (var j = 0; j < old.length; j++) old[j].destroy()
    }
    Component.onCompleted: rebuildPresets()

    Plasmoid.contextualActions: [startAction, resetAction, separatorAction].concat(root.presetActions)

    // ----- Boutons réutilisables -----
    // Côtés : 0 = gauche, 1 = droite, 2 = haut, 3 = bas (par rapport aux chiffres)
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

    preferredRepresentation: fullRepresentation

    // Un Loader de bouton : instancié seulement si actif, et exclu du layout sinon
    // (visible:false) pour ne pas occuper de case ni d'espacement.
    component BtnLoader: Loader {
        property bool show: false
        Layout.alignment: Qt.AlignCenter
        active: show
        visible: show
    }

    fullRepresentation: Item {
        Layout.minimumWidth: stack.implicitWidth + Kirigami.Units.largeSpacing * 2
        Layout.minimumHeight: stack.implicitHeight + Kirigami.Units.largeSpacing * 2

        // Haut / (gauche - chiffres - droite) / bas
        ColumnLayout {
            id: stack
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            // --- HAUT ---
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

            // --- MILIEU : gauche | chiffres | droite ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter   // centré vertical sur les chiffres
                    Layout.fillHeight: false            // ne pas s'étirer sur toute la hauteur
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
                    color: root.remaining <= 0 ? Kirigami.Theme.negativeTextColor
                                               : Kirigami.Theme.textColor
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

            // --- BAS ---
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
