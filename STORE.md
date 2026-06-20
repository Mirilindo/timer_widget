# store.kde.org listing — Big Timer

Category: **Plasma 6 Extensions** — this is the exact category the desktop
"Add Widgets → Get New Widgets" dialog queries (from `plasmoids.knsrc`,
`Categories=Plasma 6 Extensions`). Do NOT use "Plasma Mobile Widgets" (that is for phones).
License: **GPL-3.0-or-later**. Tags: `timer, countdown, clock, panel, font`.

## Title
Big Timer

## Summary (one line)
A countdown timer with an adjustable font size — big, readable digits anywhere.

## Description (EN)
Big Timer is a countdown timer for KDE Plasma 6 whose digits you can actually make big.

Unlike the built-in timer, the font (size, family and color) is fully configurable, so the
digits stay readable on the desktop or in a panel.

Features:
- Adjustable font: size, family and color of the digits
- Start / Pause / Reset, clock-based countdown (accurate, survives system sleep)
- Buttons on any side of the digits (left/right/top/bottom), each hideable, icon-only possible
- Right-click menu: Start, Reset, configurable preset durations (shown as "Set hh:mm:ss [name]"),
  and a "Set a time…" dialog for any custom duration
- Clean duration editor (hh:mm:ss, optional names, reordering)
- Warning color when the remaining time drops below a configurable threshold
- End sound: bundled beep (repeatable or off) or a custom MP3, plus an optional notification
- Optional compact panel mode: a logo with a progress ring around it or a bar below it
  (with a custom logo image), for thin panels
- 26 languages (all official EU languages + Russian + Ukrainian)

Source code: https://github.com/Mirilindo/timer_widget

## Description (FR)
Big Timer est un minuteur (compte à rebours) pour KDE Plasma 6 dont on peut enfin grossir les
chiffres. Contrairement au minuteur intégré, la police (taille, famille, couleur) est entièrement
réglable, pour des chiffres lisibles sur le bureau comme dans un panneau.

Fonctions : police réglable ; Démarrer/Pause/Réinitialiser (compte à rebours calé sur l'horloge,
résiste à la veille) ; boutons sur les 4 côtés, masquables, icône seule possible ; menu clic droit
(durées prédéfinies + saisie d'une durée libre) ; éditeur de durées hh:mm:ss avec noms et ordre ;
couleur d'alerte en fin de compte ; son de fin personnalisable (MP3) + notification ;
mode compact pour les panneaux (logo + anneau ou barre de progression, image de logo perso) ;
26 langues.

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

## Screenshots to attach (in screenshots/)
1. `widget.png` — widget on the desktop with big digits
2. `panel.png` — widget in a panel
3. `compact.png` — compact panel mode (progress ring / bar around a logo)
4. `settings.png` — settings (Appearance, incl. the compact options)
5. `settings_duration.png` — settings (Menu durations editor)
