# INSTALAR v2

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗  ║
║   ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗ ║
║   ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ███████║██████╔╝ ║
║   ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██╔══██║██╔══██╗ ║
║   ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗██║  ██║██║  ██║ ║
║   ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ║
║                                                                  ║
║              Laravel + Filament Installation System v2.0         ║
╚══════════════════════════════════════════════════════════════════╝
```

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-4.0%2B-yellow.svg)](https://www.gnu.org/software/bash/)

## Überblick

**INSTALAR v2** ist ein modernes Bash-Skript für die automatisierte Erstellung von Laravel-Projekten mit einem vollständigen, produktionsreifen Stack.

### Was macht INSTALAR v2?

- 🚀 **Schnelle Projekt-Erstellung** - Laravel mit einem Befehl aufsetzen
- 📦 **Paket-Verwaltung** - 25+ Laravel-Pakete zur Auswahl
- 🎨 **Interaktive TUI** - Einfache Auswahl mit Pfeiltasten
- 🗄️ **Flexible Datenbank** - SQLite, MySQL, PostgreSQL oder SQL Server
- 🔧 **Automatische Konfiguration** - Datenbank-Setup, .env, Berechtigungen
- 🧪 **Testing-Ready** - Mit Pest PHP vorkonfiguriert
- 📊 **Admin-Panel** - Filament 5.1 mit Admin-User
- 🔄 **Git-Integration** - Automatische Repository-Initialisierung

## Features

### Kernfunktionen

| Feature | Beschreibung |
|---------|--------------|
| **Projekt-Setup** | Automatische Laravel-Projekt-Erstellung |
| **Datenbank** | SQLite (Standard), MySQL, PostgreSQL, SQL Server |
| **DB-Setup** | Automatische Datenbank-Erstellung (MySQL/PostgreSQL) |
| **Pakete** | Filament 5.1, Livewire 4.x, Pest 2.x, Laravel Boost |
| **Frontend** | Automatischer Build (npm install + build) |
| **Berechtigungen** | Korrekte storage/ und bootstrap/cache Rechte |
| **Optimierung** | Caching für Produktionsumgebung |

### Verfügbare Pakete

#### Core (Standard)
- ✅ Filament 5.1 (Admin Panel)
- ✅ Livewire 4.x (Frontend)
- ✅ Pest 2.x (Testing)
- ✅ Laravel Boost
- ✅ Laravel Debugbar

#### Authentifizierung
- Laravel Fortify
- Laravel Sanctum
- Laravel Passport (OAuth2)
- Laravel Socialite
- Laravel Breeze / Jetstream

#### Spatie-Pakete
- Permission (Rollen/Rechte)
- Health Checks
- Backup
- Activity Log
- Settings
- Medialibrary
- CSP (Security)
- Honeypot (Bot Protection)

#### Weitere
- Laravel Scout + Meilisearch
- Laravel Horizon (Queues)
- Laravel Telescope (Debug)
- Maatwebsite Excel
- Sentry (Error Tracking)
- Laravel Pint (Formatter)
- Larastan (Static Analysis)
- IDE Helper

## Voraussetzungen

### Systemanforderungen

| Tool | Minimum | Empfohlen |
|------|---------|-----------|
| PHP | 8.1 | 8.4+ |
| Composer | 2.0 | 2.8+ |
| Node.js | 18 | 20+ |
| NPM | 9 | 10+ |
| Bash | 4.0 | 5.0+ |

### PHP-Extensions

**Erforderlich (alle Datenbanken):**
```
mbstring, xml, ctype, iconv, intl, pdo, tokenizer,
bcmath, json, fileinfo, pdo_sqlite, openssl, zip
```

**Zusätzlich für externe Datenbanken:**
```
pdo_mysql    # Für MySQL/MariaDB
pdo_pgsql    # Für PostgreSQL
pdo_sqlsrv   # Für SQL Server (benötigt Microsoft-Treiber)
```

## Installation & Nutzung

### Schnellstart

```bash
# Repository klonen oder herunterladen
cd instalar/v2

# Ausführbar machen
chmod +x instalar.sh

# Skript starten
./instalar.sh
```

### Installationsmodi

#### Automatisch (Empfohlen)

Installiert alle empfohlenen Pakete mit Standard-Versionen:

```bash
./instalar.sh
# Wähle: 1) Automatisch
```

**Was wird installiert:**
- Laravel (latest stable)
- Filament 5.1
- Livewire 4.x
- Pest 2.x
- Laravel Boost
- SQLite Datenbank
- Git Repository

#### Manuell

Individuelle Paketauswahl und Konfiguration:

```bash
./instalar.sh
# Wähle: 2) Manuell
```

**Konfigurationsmöglichkeiten:**
- Laravel Version (stable/master)
- Individuelle Paketauswahl (25+ Pakete)
- Feature-Auswahl (Breeze/Jetstream/Redis/Horizon/Scout)
- **Datenbank-Auswahl** (SQLite/MySQL/PostgreSQL/SQL Server)
  - Bei externen DBs: Host, Port, Datenbankname, User, Passwort
  - Automatische Datenbank-Erstellung (MySQL/PostgreSQL)
- Git Setup (ja/nein)
- Admin-User Daten

### Datenbank-Konfiguration

INSTALAR v2.1 unterstützt jetzt mehrere Datenbanken:

| Datenbank | Modus | Auto-Erstellung | Verbindungstest |
|-----------|-------|-----------------|-----------------|
| **SQLite** | Automatisch & Manuell | ✅ Datei wird erstellt | N/A |
| **MySQL** | Manuell | ✅ Datenbank + User | ✅ Wenn Client verfügbar |
| **PostgreSQL** | Manuell | ✅ Datenbank + User | ✅ Wenn Client verfügbar |
| **SQL Server** | Manuell | ❌ Manuelle Erstellung nötig | ⚠️ Kein Test |

#### SQLite (Standard)
```bash
# Wird automatisch im Projekt-Verzeichnis erstellt
database/database.sqlite
```

#### MySQL / MariaDB
```bash
# Konfiguration im manuellen Modus:
Host: 127.0.0.1 (Standard)
Port: 3306 (Standard)
Datenbank: projektname
User: root
Passwort: [Eingabe]

# Automatisch erstellt wenn:
- mysql Client ist installiert
- Verbindung zu MySQL Server möglich
- User hat CREATE DATABASE Rechte
```

#### PostgreSQL
```bash
# Konfiguration im manuellen Modus:
Host: 127.0.0.1 (Standard)
Port: 5432 (Standard)
Datenbank: projektname
User: postgres
Passwort: [Eingabe]

# Automatisch erstellt wenn:
- psql Client ist installiert
- Verbindung zu PostgreSQL Server möglich
- User hat CREATE DATABASE Rechte
```

#### SQL Server
```bash
# Konfiguration im manuellen Modus:
Host: 127.0.0.1 (Standard)
Port: 1433 (Standard)
Datenbank: projektname
User: sa
Passwort: [Eingabe]

# Hinweis:
Datenbank muss manuell vor der Installation erstellt werden!
```

### Umgebungsvariablen

Admin-User Daten können vorab gesetzt werden:

```bash
ADMIN_NAME="Mein Name" \
ADMIN_EMAIL="admin@meinefirma.de" \
ADMIN_PASSWORD="sicheres-passwort" \
./instalar.sh
```

## Dateistruktur

```
v2/
├── instalar.sh          # Hauptskript (alles in einer Datei)
├── README.md            # Diese Datei
└── CHANGELOG.md         # Änderungsprotokoll
```

## Skript-Architektur

Das Skript ist in logische Abschnitte unterteilt:

1. **Konfiguration & Konstanten** - Alle Einstellungen, Exit-Codes, Versionen
2. **Paket-Definitionen** - Arrays mit allen verfügbaren Paketen
3. **Farben & Ausgabe** - Farbcodes und formatierte Ausgabefunktionen
4. **Fehlerbehandlung** - Error-Handling, Logging, Validierung
5. **Benutzerinteraktion** - Menüs, TUI, Eingabevalidierung
6. **Systemvoraussetzungen** - Prüfung von PHP, Composer, Node.js, etc.
7. **Laravel-Installation** - Projekt-Erstellung mit Installer
8. **Paket-Installation** - Composer-Pakete, Features, Filament/Livewire
9. **Datenbank-Setup** - SQLite-Konfiguration, Migrationen
10. **Frontend & Git** - NPM-Build, Git-Initialisierung
11. **Abschluss** - Sanity-Report, Server-Start

## Bedienung

### TUI-Navigation

In den Mehrfachauswahllisten:

| Taste | Aktion |
|-------|--------|
| `↑` / `↓` | Navigation |
| `Leertaste` | Auswahl umschalten |
| `a` | Alle auswählen |
| `0` | Alle abwählen |
| `Enter` | Bestätigen |

### Nach der Installation

Das erstellte Projekt enthält:

**Bei SQLite:**
```
mein-projekt/
├── .env                  # Konfiguriert für SQLite
├── .env.backup.*         # Backup der Original-.env (mit Zeitstempel)
├── database/
│   └── database.sqlite   # SQLite Datenbank
├── storage/              # Schreibbar (775)
├── bootstrap/cache/      # Schreibbar (775)
└── .git/                 # Git Repository (initialer Commit)
```

**Bei MySQL/PostgreSQL/SQL Server:**
```
mein-projekt/
├── .env                  # Konfiguriert für externe DB
├── .env.backup.*         # Backup der Original-.env (mit Zeitstempel)
├── storage/              # Schreibbar (775)
├── bootstrap/cache/      # Schreibbar (775)
└── .git/                 # Git Repository (initialer Commit)
# Datenbank wurde automatisch (MySQL/PostgreSQL) oder manuell (SQL Server) erstellt
```

### Standard-Zugangsdaten

**Filament Admin-Panel:**
- URL: http://localhost:8000/admin
- Email: admin@example.com
- Passwort: password

⚠️ **Ändern Sie diese Zugangsdaten nach der Installation!**

## Befehle nach der Installation

```bash
# In das Projektverzeichnis wechseln
cd mein-projekt

# Entwicklungsserver starten
composer run dev

# Nur Laravel-Server
php artisan serve

# Tests ausführen (falls Pest installiert)
./vendor/bin/pest

# Neue Filament-Resource erstellen
php artisan make:filament-resource UserResource

# Migration erstellen
php artisan make:migration create_posts_table
```

## Fehlerbehebung

### Häufige Probleme

#### "Permission denied"
```bash
chmod +x instalar.sh
```

#### "PHP nicht gefunden"
PHP 8.1+ muss installiert sein. Alternativ über php.new:
```bash
/bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.4)"
```

#### "Composer nicht gefunden"
```bash
# Composer installieren
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### Log-Dateien

Bei Fehlern wird eine `installation_errors.log` erstellt:

```bash
# Logs anzeigen
cat installation_errors.log
```

## Verbesserungen in v2.0

### Code-Qualität
- **Exit-Codes**: Standardisierte Konstanten für bessere Fehlerbehandlung
- **Bessere Kommentare**: Jeder Abschnitt hat einen DocBlock mit Beschreibung
- **Konstanten**: Farbcodes mit `COLOR_` Präfix, `SCRIPT_VERSION`, etc.
- **Neue Hilfsfunktionen**: `command_exists()`, `append_unique()`, `validate_project_name()`

### Struktur
- **Logische Abschnitte**: Code ist in 11 thematische Bereiche gruppiert
- **Klare Trennung**: Konfiguration, UI, Logik und Installation getrennt
- **Bessere Lesbarkeit**: Einheitliche Namenskonventionen und Formatierung

### Dokumentation
- **README**: Umfassend mit Tabellen und Beispielen
- **CHANGELOG**: Semantic Versioning Format
- **Inline-Kommentare**: Jede Funktion ist dokumentiert

Siehe [CHANGELOG.md](CHANGELOG.md) für alle Änderungen.

## Changelog

Siehe [CHANGELOG.md](CHANGELOG.md) für das vollständige Änderungsprotokoll.

## Mitwirken

Beiträge sind willkommen! Bitte:

1. Fork erstellen
2. Feature-Branch: `git checkout -b feature/neues-feature`
3. Commits: `git commit -am 'Neues Feature hinzugefügt'`
4. Push: `git push origin feature/neues-feature`
5. Pull Request öffnen

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

## Danksagung

- [Laravel](https://laravel.com) - Das Web-Framework
- [Filament](https://filamentphp.com) - Das Admin-Panel
- [Pest](https://pestphp.com) - Das Testing-Framework
- Alle [Spatie](https://spatie.be) Packages

## Autor

**yezz.design** - design@schodie.de

---

<p align="center">
  Mit ❤️ erstellt für die Laravel-Community
</p>
