import QtQuick
import "../translations/strings.js" as Strings

// Système de traduction maison basé sur translations/strings.js.
// Usage : Translations { id: lang }  puis  lang.t("start") / lang.tr("setMin", 5)
// Les données sont importées en JS (résolues au chargement) -> fiable et synchrone,
// contrairement à l'ancien chargement XHR de strings.json qui échouait dans le plasmoïde.
QtObject {
    id: root

    // "en", "fr", ... d'après la locale système
    readonly property string locale: Qt.locale().name.substring(0, 2)

    // Renvoie la chaîne traduite ; repli sur l'anglais ; repli sur la clé brute.
    function t(key) {
        var loc = Strings.data[root.locale]
        if (loc && loc[key] !== undefined) return loc[key]
        var en = Strings.data["en"]
        if (en && en[key] !== undefined) return en[key]
        return key
    }

    // Comme t() mais remplace %1 par une valeur.
    function tr(key, a1) {
        return String(t(key)).replace("%1", a1)
    }
}
