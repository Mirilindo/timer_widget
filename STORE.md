# store.kde.org listing — Big Timer

Category: **Plasma 6 Extensions** — this is the exact category the desktop
"Add Widgets → Get New Widgets" dialog queries (from `plasmoids.knsrc`,
`Categories=Plasma 6 Extensions`). Do NOT use "Plasma Mobile Widgets" (that is for phones).
License: **GPL-3.0-or-later**. Tags: `timer, countdown, stopwatch, clock, panel, font`.

## Title
Big Timer

## Summary (one line)
A countdown timer and stopwatch with an adjustable font size — big, readable digits anywhere.

## Description (EN)
Big Timer is a countdown timer and stopwatch for KDE Plasma 6 whose digits you can actually make big.

Unlike the built-in timer, the font (size, family and color) is fully configurable, so the
digits stay readable on the desktop, and the time fits the panel it sits in.

Features:
- Countdown and stopwatch in the same widget, started from the right-click menu or by clicking
  the digits while stopped
- Adjustable font: size, family and color of the digits
- Start / Pause / Reset, clock-based (accurate, survives system sleep)
- Right-click menu: your countdowns in plain words ("Countdown 15 min"), any other duration,
  and "Start stopwatch"
- Countdown editor (hh:mm:ss, optional names, reordering)
- Remembers the mode and the last chosen duration
- In a panel: the time, the icon with a progress ring or bar, or the icon while idle and the
  time once started
- Four button layouts, optional text, adjustable size, optional +/− buttons
- Warning color near the end of a countdown
- End of countdown: bundled beep (repeatable or off) or a custom sound, plus an optional notification
- 26 languages (all official EU languages + Russian + Ukrainian); English and French are
  reviewed, the others are machine translations: corrections are welcome on GitHub

Upgrading from 1.2 or earlier: the widget ID changed, so remove the old Big Timer from your
desktop or panel and add it again (settings start from the new defaults).

Source code: https://github.com/Mirilindo/timer_widget

## Description (FR)
Big Timer est un minuteur et un chronomètre pour KDE Plasma 6 dont on peut enfin grossir les
chiffres. Contrairement au minuteur intégré, la police (taille, famille, couleur) est entièrement
réglable : les chiffres restent lisibles sur le bureau, et le temps s'adapte au panneau.

Fonctions : minuteur et chronomètre dans le même widget, lancés depuis le clic droit ou d'un clic
sur les chiffres à l'arrêt ; police réglable ; Démarrer/Pause/Réinitialiser calés sur l'horloge
(précis, résistent à la veille) ; menu clic droit avec vos minuteurs en clair (« Minuteur 15 min »),
une durée libre et « Lancer le chronomètre » ; éditeur de durées hh:mm:ss avec noms et ordre ;
mémorise le mode et la dernière durée ; dans un panneau : le temps, l'icône avec un anneau ou une
barre de progression, ou l'icône au repos puis le temps une fois lancé ; quatre dispositions de
boutons, texte et taille réglables, boutons +/− en option ; couleur d'alerte en fin de minuteur ;
son de fin personnalisable + notification ; 26 langues (anglais et français relus, les autres
traduites automatiquement : vos corrections sont les bienvenues sur GitHub).

Mise à jour depuis la 1.2 ou avant : l'identifiant du widget a changé, retirez l'ancien Big Timer
du bureau ou du panneau et ajoutez-le de nouveau (les réglages repartent des nouveaux défauts).

## Changelog — v1.3
Stopwatch mode, and a simpler widget.
- **Stopwatch**: "Start stopwatch" in the right-click menu counts up from zero. Picking a
  countdown switches back. With the "icon with progress" panel view, the ring or bar turns
  once per minute.
- **Right-click menu** rewritten: your countdowns in plain words ("Countdown 15 min",
  "Countdown 1 h"), "Countdown… (other duration)", then "Start stopwatch", separated from
  Plasma's own entries.
- **Click the digits while stopped** to pick a countdown or start the stopwatch (the
  right-click menu without Start/Reset).
- **In a panel, the time is shown by default**, sized to the panel (it also fits vertical
  panels). Click it to open the full timer in the standard Plasma popup. Two other choices:
  the icon with progress, or the icon while idle and the time once started.
- **Reset always does the same thing**: back to the chosen duration, or to zero for the
  stopwatch. The widget remembers the mode and the last chosen duration.
- **Settings reorganized**, from 41 to 21: *Appearance*, *Panel*, *Buttons* (four layouts
  instead of per-button settings), *Countdowns*, *End of countdown*.
- Removed: the "default duration", the second-Reset-click option and the three display modes
  of 1.2 (Normal / Compact / Compact + click-to-switch).
- Buttons without text by default (the name shows as a tooltip).
- **New widget ID** (`io.github.mirilindo.bigtimer`): remove the old Big Timer and add it again.

### Changelog — v1.3 (FR)
Mode chronomètre, et un widget plus simple.
- **Chronomètre** : « Lancer le chronomètre » dans le clic droit compte à partir de zéro. Choisir
  un minuteur repasse en minuteur. Avec l'affichage « icône avec la progression » du panneau,
  l'anneau ou la barre fait un tour par minute.
- **Menu clic droit** refait : vos minuteurs en clair (« Minuteur 15 min », « Minuteur 1 h »),
  « Minuteur… (autre durée) », puis « Lancer le chronomètre », séparés des entrées de Plasma.
- **Clic sur les chiffres à l'arrêt** : choisir un minuteur ou lancer le chronomètre (le menu
  clic droit, sans Démarrer/Réinitialiser).
- **Dans un panneau, le temps est affiché par défaut**, à la taille du panneau (y compris
  vertical). Un clic ouvre le minuteur complet dans la bulle standard de Plasma. Deux autres
  choix : l'icône avec la progression, ou l'icône au repos puis le temps une fois lancé.
- **Réinitialiser fait toujours la même chose** : retour à la durée choisie, ou à zéro pour le
  chronomètre. Le widget mémorise le mode et la dernière durée choisie.
- **Réglages réorganisés**, de 41 à 21, en cinq pages (titres en anglais) : *Appearance*,
  *Panel*, *Buttons* (quatre dispositions au lieu des réglages par bouton), *Countdowns*,
  *End of countdown*.
- Supprimés : la « durée par défaut », l'option du 2ᵉ clic sur Réinitialiser et les trois modes
  d'affichage de la 1.2 (Normal / Compact / Compact avec clic pour basculer).
- Boutons sans texte par défaut (le nom s'affiche en infobulle).
- **Nouvel identifiant** (`io.github.mirilindo.bigtimer`) : retirez l'ancien Big Timer et
  ajoutez-le de nouveau.

## Changelog — v1.2
Button overhaul and three display modes.
- **Per-button configuration** for Start/Pause, Reset, **+1 min** and **−1 min**: show,
  position (4 sides), label, **size** and **order**.
- New **+1 / −1 min** quick buttons with a **configurable step** (in seconds).
- Option to lay the **side buttons in a row** instead of stacked.
- Option: a **second Reset click** returns to the default duration (toggleable).
- **3 display modes**: *Normal* (digits always shown), *Compact* (logo + ring/bar), and
  *Compact + click-to-switch* (click the logo to reveal the timer inline in the panel — no
  popup; click again to go back to the logo).
- In the compact modes: **just the logo when idle**, ring or bar progress **while running**.
- **Custom rectangular logo** support (keeps its aspect ratio; the applet follows the
  image shape, except the ring which stays square).
- **End notification** now shows the duration's name (if any) and how long it was.
- New **defaults**: compact click-to-switch, 15 min, font size 32, durations
  5/10/15/30/45/60 min, progress bar, end-color warning enabled.
- 62 i18n keys across all 26 languages.

### Changelog — v1.2 (FR)
- **Configuration par bouton** pour Démarrer/Pause, Réinitialiser, **+1 min** et **−1 min** :
  afficher, position (4 côtés), texte, **taille** et **ordre**.
- Nouveaux boutons rapides **+1 / −1 min** avec **pas réglable** (en secondes).
- Option **« boutons latéraux en ligne »** (au lieu d'empilés).
- Option : **2ᵉ clic sur Réinitialiser** → durée par défaut (activable).
- **3 modes d'affichage** : *Normal* (chiffres toujours visibles), *Compact* (logo +
  anneau/barre) et *Compact avec clic pour basculer* (clic sur le logo → minuteur inline
  dans le panneau, sans fenêtre ; reclic → retour au logo).
- En mode compact : **logo seul au repos**, anneau ou barre **pendant le décompte**.
- Prise en charge des **logos personnalisés rectangulaires** (ratio respecté).
- **Notification de fin** : nom de la durée + durée écoulée.
- Nouveaux **défauts** : compact clic-pour-basculer, 15 min, police 32, durées
  5/10/15/30/45/60 min, barre, alerte de fin activée.

## Changelog — v1.1
Compact panel mode and a few refinements.
- Optional **compact representation in panels**: a logo with the progress shown as a
  ring around it or as a bar below it (click to open the full timer). Off by default,
  so the inline big digits stay the default everywhere.
- Ring/bar can **empty** (time left) or **fill** (time elapsed); adjustable icon size.
- **Custom logo image** for the compact mode (square recommended for the ring style).
- Fills the full panel thickness in thick panels (`CanFillArea`).
- "Set a time…" dialog now opens at 00:00:00.
- Compact-mode labels translated into all 26 languages.

## Changelog — v1.0
First public release.
- Adjustable digit font (size, family, color)
- Start / Pause / Reset with a clock-based countdown (accurate, sleep-safe)
- Buttons on 4 sides, hideable, optional text labels
- Right-click menu with configurable preset durations and a free "Set a time…" dialog
- hh:mm:ss duration editor with optional names and reordering
- Warning color near the end (configurable threshold)
- Custom end sound (MP3) and end-of-countdown notification
- 26 languages (EU + Russian + Ukrainian)

## Screenshots to attach (in screenshots/) — the Store allows 5 images
1. `widget.png` — widget on the desktop with big digits
2. `menu.png` — right-click menu (countdowns + stopwatch)
3. `popup.png` — the full timer opened from the panel
4. `settings.png` — settings (Panel page)
5. `settings_duration.png` — settings (Countdowns editor)

`panel.png` and `compact.png` are shown in the README only.
