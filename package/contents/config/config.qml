import QtQuick
import org.kde.plasma.configuration

// Noms de catégories en anglais (le dialogue de config ne charge pas le JSON).
ConfigModel {
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: "Buttons & menu"
        icon: "configure"
        source: "configButtons.qml"
    }
    ConfigCategory {
        name: "Sound"
        icon: "audio-volume-high"
        source: "configSound.qml"
    }
}
