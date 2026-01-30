```txt
  ___           _        _
 |_ _|_ __  ___| |_ __ _| | __ _ _ __
  | || '_ \/ __| __/ _` | |/ _` | '__|
  | || | | \__ \ || (_| | | (_| | |
 |___|_| |_|___/\__\__,_|_|\__,_|_|

 [ Laravel + Filament Install Script ]
```

# INSTALAR

Instalar ist ein Bash-Skript, das ein frisches Laravel-Projekt inklusive Filament aufsetzt.
Es automatisiert das komplette Setup für einen modernen Laravel-Stack mit SQLite,
Livewire, Pest und Laravel Boost.

## Features
- Erstellt ein neues Laravel-Projekt per Laravel Installer
- Installiert Filament 5.1 und Livewire 4.x
- Richtet SQLite inklusive .env-Konfiguration ein
- Führt Migrationen aus und erstellt einen Filament Admin-User
- Baut Frontend Assets (npm install + npm run build)
- Setzt Berechtigungen und optimiert Caches
- Optionaler Start des Entwicklungsservers

## Voraussetzungen
- Bash
- PHP >= 8.1 (falls nicht vorhanden, versucht das Skript PHP 8.5 per php.new zu installieren)
- Composer
- Node.js + npm
- PHP Extensions: mbstring, xml, ctype, iconv, intl, pdo, tokenizer, bcmath, json, fileinfo, pdo_sqlite

## Installation und Nutzung
```bash
chmod +x instalar.sh
./instalar.sh
```

Das Skript fragt interaktiv nach einer bestätigten Löschung, falls das Projektverzeichnis bereits existiert.
Am Ende kannst du entscheiden, ob der Dev-Server direkt gestartet werden soll.

## Konfiguration
Die wichtigsten Variablen stehen am Anfang der Datei `instalar.sh`:
- `PROJECT_NAME`: Name des erzeugten Projekts (Standard: `WebApp-2025`)
- `DATABASE_TYPE`: Wird nur für die Anzeige genutzt (Standard: `sqlite`)

Admin-User Daten kannst du optional über Umgebungsvariablen setzen:
```bash
ADMIN_NAME="Admin User" \
ADMIN_EMAIL="admin@example.com" \
ADMIN_PASSWORD="password" \
./instalar.sh
```

## Ergebnis
Nach dem Lauf findest du ein neues Projektverzeichnis mit:
- `database/database.sqlite`
- `.env` (sowie `.env.backup`)
- Filament Panel unter `http://localhost:8000/admin`

## Hinweise
- Das Skript kann ein bestehendes Projektverzeichnis löschen (nach Rückfrage).
- Es aktualisiert/ installiert den Laravel Installer global und passt ggf. `~/.bashrc` an.
- Standard-Login ist `admin@example.com` / `password` (bitte ändern!).
- Bei Fehlern wird `installation_errors.log` angelegt.
