import QtQuick
import "../translations/strings.js" as Strings

// Small in-house translation system based on translations/strings.js.
// Usage: Translations { id: lang }  then  lang.t("start") / lang.tr("notifTitleNamed", "Tea")
// Data is imported as JS (resolved at load time) -> reliable and synchronous, unlike the
// old XHR loading of strings.json which failed silently inside the installed plasmoid.
QtObject {
    id: root

    // "en", "fr", ... from the system locale
    readonly property string locale: Qt.locale().name.substring(0, 2)

    // Returns the translated string; falls back to English; falls back to the raw key.
    function t(key) {
        var loc = Strings.data[root.locale]
        if (loc && loc[key] !== undefined) return loc[key]
        var en = Strings.data["en"]
        if (en && en[key] !== undefined) return en[key]
        return key
    }

    // Like t() but substitutes %1 (and optionally %2) with values.
    function tr(key, a1, a2) {
        var s = String(t(key)).replace("%1", a1)
        if (a2 !== undefined) s = s.replace("%2", a2)
        return s
    }
}
