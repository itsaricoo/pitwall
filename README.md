# Pitwall (Toon QML-app voor Formule 1) - versie 1.1.0

Werkt op Toon 1 (800x480) en Toon 2 (1024x600): alle afmetingen schalen mee met de schermbreedte
en de lettertjes zijn op Toon 1 iets groter. Net als de andere TSC-apps gebruikt Pitwall `import QtQuick 2.1`.

## Functies
- Tile: volgende GP, afteltijd naar de eerstvolgende sessie en de leider in het kampioenschap
- Scherm met 5 tabbladen: Volgende (alle sessietijden), Coureurs, Teams, Uitslag, Kalender
- Teamkleur als streepje voor elke rij (coureurs, teams, uitslag)
- Meldingen vlak voor de race, kwalificatie en sprint: wekt het scherm, toont een meldingsscherm en speelt een geluid
  (vijf startlichten-pieptonen). Elke sessie wordt maar een keer gemeld, ook na een herstart.
- Instellingen (knop rechtsboven in het hoofdscherm): Nederlandse namen aan/uit, meldingen per type aan/uit,

## Bestanden
- PitwallApp.qml: logica (MOET <Mapnaam>App.qml heten)
- PitwallTile.qml, PitwallScreen.qml, PitwallSettingsScreen.qml, PitwallAlertScreen.qml
- PitwallRow.qml, PitwallTable.qml, PitwallSwitch.qml, PitwallSwitchRow.qml: herbruikbare onderdelen

## Data en opslag
Data: Jolpica F1 API (https://api.jolpi.ca/ergast/f1/), gratis en zonder sleutel. Elke 30 minuten ververst.
- Cache: `/mnt/data/tsc/pitwall_cache.json`
- Instellingen: `/mnt/data/tsc/pitwall_userSettings.json`

## Installeren
1. Kopieer de map `pitwall` naar `/qmf/qml/apps/pitwall/` (of via ToonStore: `pitwall-1.1.0` met symlink `pitwall`).
2. Herstart de GUI en voeg de tile "Pitwall F1" toe via het tegel-overzicht.

## Aanpassen
- Teamkleuren: functie `teamColor()` in PitwallApp.qml
- Nederlandse GP-namen, landen en uitvalredenen: `gpNl`, `countryNl`, `statusNlMap` bovenin PitwallApp.qml

## Let op
- Geen data? Controleer of de Toon https naar api.jolpi.ca kan bereiken.
