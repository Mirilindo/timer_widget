#!/usr/bin/env bash
# Installe / met à jour le plasmoïde Big Timer puis recharge plasmashell.
# Usage : ./install.sh
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PKG="$DIR/package"
ID="io.github.mirilindo.bigtimer"

echo ">> Installation/maj de $ID depuis $PKG"
# --upgrade si déjà installé, sinon --install
if ! kpackagetool6 --type Plasma/Applet --upgrade "$PKG" 2>/dev/null; then
    kpackagetool6 --type Plasma/Applet --install "$PKG"
fi

echo ">> Redémarrage de plasmashell (pour recharger le widget)"
kquitapp6 plasmashell 2>/dev/null || true
sleep 1
setsid -f kstart plasmashell >/dev/null 2>&1 || true
sleep 2

echo ">> Terminé. Ajoute le widget : clic droit sur le bureau / barre -> Ajouter des widgets -> 'Big Timer'."
