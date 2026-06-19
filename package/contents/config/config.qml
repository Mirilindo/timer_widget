import QtQuick
import org.kde.plasma.configuration

// Category names are hardcoded in English (the config dialog title list is not translated here).
ConfigModel {
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: "Buttons"
        icon: "configure"
        source: "configButtons.qml"
    }
    ConfigCategory {
        name: "Menu durations"
        icon: "chronometer"
        source: "configDurations.qml"
    }
    ConfigCategory {
        name: "Sound"
        icon: "audio-volume-high"
        source: "configSound.qml"
    }
}
