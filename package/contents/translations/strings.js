.pragma library

// Traductions de Big Timer.
// Chargé via import JS (fiable, synchrone) au lieu d'un XHR sur strings.json
// qui échouait silencieusement dans le plasmoïde installé.
// Pour ajouter une langue : ajouter un bloc { "xx": { ... } }.

var data = {
    "en": {
        "start": "Start",
        "pause": "Pause",
        "reset": "Reset",
        "setMin": "Set %1 min",
        "appearance": "Appearance",
        "fontSize": "Font size:",
        "defaultDuration": "Default duration (seconds):",
        "buttonsMenu": "Buttons & menu",
        "startBtn": "Start/Pause button:",
        "resetBtn": "Reset button:",
        "show": "Show",
        "position": "Position:",
        "left": "Left",
        "right": "Right",
        "top": "Top",
        "bottom": "Bottom",
        "showLabel": "Show text",
        "menuDurations": "Right-click menu durations (min):",
        "menuDurationsHint": "Minutes separated by commas. They appear as \"Set X min\" in the right-click menu.",
        "sound": "Sound",
        "beepRepeats": "Beep repeats at end:",
        "beepHint": "How many times the beep plays when the countdown reaches zero. 0 = no sound."
    },
    "fr": {
        "start": "Démarrer",
        "pause": "Pause",
        "reset": "Réinitialiser",
        "setMin": "Régler %1 min",
        "appearance": "Apparence",
        "fontSize": "Taille de police :",
        "defaultDuration": "Durée par défaut (secondes) :",
        "buttonsMenu": "Boutons & menu",
        "startBtn": "Bouton Démarrer/Pause :",
        "resetBtn": "Bouton Réinitialiser :",
        "show": "Afficher",
        "position": "Position :",
        "left": "Gauche",
        "right": "Droite",
        "top": "Haut",
        "bottom": "Bas",
        "showLabel": "Afficher le texte",
        "menuDurations": "Durées du menu clic droit (min) :",
        "menuDurationsHint": "Minutes séparées par des virgules. Apparaissent en « Régler X min » dans le menu clic droit.",
        "sound": "Son",
        "beepRepeats": "Répétitions du bip à la fin :",
        "beepHint": "Nombre de fois que le bip est joué quand le compte arrive à zéro. 0 = aucun son."
    }
}
