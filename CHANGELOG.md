# Changelog

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

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/), und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [2.1.0] - 2026-02-01

### ✨ Neue Funktionen

#### Datenbank-Auswahl im manuellen Modus
- **Unterstützte Datenbanken:**
  - ✅ SQLite (Datei-basiert, Standard)
  - ✅ MySQL / MariaDB
  - ✅ PostgreSQL
  - ✅ SQL Server

- **Interaktive Datenbank-Konfiguration:**
  - Host (Standard: 127.0.0.1)
  - Port (Standard-Ports je nach DB: 3306, 5432, 1433)
  - Datenbankname (Standard: Projektname)
  - Benutzername (Standard: root)
  - Passwort (sicherer Eingabemodus)

- **Automatische Datenbank-Erstellung:**
  - MySQL: Erstellt Datenbank mit `utf8mb4` Charset automatisch
  - PostgreSQL: Erstellt Datenbank mit UTF8 Encoding automatisch
  - SQL Server: Zeigt Warnung (muss manuell erstellt werden)
  - SQLite: Erstellt Datei wie bisher

- **Verbindungstests:**
  - Testet Datenbank-Verbindung vor Migrationen (falls Client installiert)
  - Zeigt Warnungen bei fehlenden Datenbank-Clients (mysql, psql)
  - Fallback zu manueller Konfiguration bei Verbindungsfehlern

- **Intelligente `.env` Konfiguration:**
  - Automatische Konfiguration je nach DB-Typ
  - Für SQLite: Host/Port/User/Password werden auskommentiert
  - Für externe DBs: Alle Werte werden korrekt gesetzt
  - Backup der Original-.env mit Zeitstempel

#### Neue Hilfsfunktionen
- `ask_database_selection()` - Interaktive Datenbank-Auswahl mit Validierung
- `test_database_connection()` - Testet Verbindung zu MySQL/PostgreSQL/SQL Server
- `create_database_if_not_exists()` - Erstellt Datenbank automatisch falls nicht vorhanden

### 🔧 Verbesserungen

#### Datenbank-Setup
- Verbesserte `setup_database()` Funktion unterstützt jetzt alle 4 Datenbank-Typen
- Case-Statement für verschiedene DB-Konfigurationen
- Intelligente Port-Standardwerte je nach Datenbanktyp

#### Reports und Zusammenfassungen
- Sanity Report zeigt jetzt Datenbank-Typ und Verbindungsdetails
- Zusammenfassung im manuellen Modus zeigt DB-Details
- Finale Übersicht zeigt korrekte Datenbank-Informationen

### 📦 Technische Details

#### Neue Variablen
```bash
DATABASE_TYPE="sqlite"          # sqlite, mysql, pgsql, sqlsrv
DB_HOST="127.0.0.1"
DB_PORT=""                      # 3306 (MySQL), 5432 (PostgreSQL), 1433 (SQL Server)
DB_DATABASE=""
DB_USERNAME=""
DB_PASSWORD=""
```

#### Neue Konstanten
```bash
DATABASE_TYPES=(sqlite mysql pgsql sqlsrv)
declare -A DATABASE_LABEL        # Anzeigenamen für jede DB
declare -A DATABASE_DEFAULT_PORT # Standard-Ports
```

### 📝 Dokumentation
- README.md aktualisiert mit Datenbank-Sektion
- VERBESSEUNGEN.md erweitert mit neuen Features
- Inline-Dokumentation für alle neuen Funktionen

---

## [2.0.0] - 2026-01-31

### ✨ Neue Funktionen

#### Code-Struktur
- **Logische Organisation**: Code ist in 11 thematische Abschnitte gruppiert:
  1. Konfiguration & Konstanten (Exit-Codes, Versionen, Paket-Definitionen)
  2. Paket-Definitionen (Arrays mit allen verfügbaren Paketen)
  3. Farben & Ausgabe (Farbcodes und formatierte Ausgabefunktionen)
  4. Fehlerbehandlung & Utilities (Error-Handling, Logging, Validierung)
  5. Benutzerinteraktion (Menüs, TUI, Eingabevalidierung)
  6. Systemvoraussetzungen (Prüfung von PHP, Composer, Node.js, etc.)
  7. Laravel-Installation (Projekt-Erstellung mit Installer)
  8. Paket-Installation (Composer-Pakete, Features, Filament/Livewire)
  9. Datenbank-Setup (SQLite-Konfiguration, Migrationen)
  10. Frontend & Git (NPM-Build, Git-Initialisierung)
  11. Abschluss (Sanity-Report, Server-Start)

- **Exit-Codes**: Standardisierte Exit-Codes für bessere Fehlerbehandlung
  - `0` - Erfolg
  - `1` - Allgemeiner Fehler
  - `2` - Voraussetzungen nicht erfüllt
  - `3` - Laravel-Fehler
  - `4` - Datenbank-Fehler
  - `5` - Berechtigungsfehler
  - `6` - Git-Fehler

#### Code-Qualität
- **Bessere Kommentare**: Jeder Abschnitt hat einen DocBlock mit Beschreibung
- **Konsistente Benennung**: Verbesserte Namenskonventionen für Funktionen und Variablen
  - Farbcodes mit `COLOR_` Präfix (`COLOR_RED`, `COLOR_GREEN`, etc.)
  - Konstanten mit Uppercase (`EXIT_SUCCESS`, `SCRIPT_VERSION`, etc.)
- **Code-Deduplizierung**: Gemeinsame Logik in wiederverwendbare Funktionen ausgelagert
- **Fehlerbehandlung**: Verbesserte Error-Handling mit kontextspezifischen Exit-Codes

#### Neue Hilfsfunktionen
- `command_exists()` - Prüft ob ein Befehl verfügbar ist
- `append_unique()` - Fügt Array-Element nur hinzu wenn noch nicht vorhanden
- `validate_project_name()` - Validiert Projektnamen (Buchstaben, Zahlen, _, -)
- `backup_file()` - Sichert Dateien vor Änderungen (für .env mit Zeitstempel)
- `show_progress()` - Zeigt echten Fortschritt als Prozentbalken (aktueller Schritt / Gesamtzahl)
- `handle_error()` - Zentrale Fehlerbehandlung mit Logging

#### Dokumentation
- **README.md komplett überarbeitet**:
  - Übersichtliche Struktur mit Badges
  - Feature-Matrizen in Tabellenform
  - Systemanforderungen als Vergleichstabelle
  - Klarer Schnellstart-Guide
  - Skript-Architektur Dokumentation
  - Danksagungen und Community-Links
- **Diese CHANGELOG.md**: Neu strukturiert mit Semantic Versioning

### 🔧 Verbesserungen

#### Lesbarkeit
- Konsistente Farbcodes mit `COLOR_` Präfix
- Einheitliche Ausgabe-Funktionen (`print_*`)
  - `print_header()` - Formatierte Header
  - `print_success()` - Erfolgsnachrichten mit ✓
  - `print_error()` - Fehlermeldungen mit ✗
  - `print_warning()` - Warnungen mit ⚠
  - `print_info()` - Info-Nachrichten mit ℹ
  - `print_step()` - Schritt-Indikatoren mit ►
- Bessere Einrückung und Formatierung
- Klare Abschnitts-Trenner mit Kommentar-Blöcken (`#====...`)

#### Wartbarkeit
- Zentrale Konfiguration am Anfang der Datei
- Keine Magic Numbers (alles als Konstanten definiert)
- Trennung von UI-Logik und Business-Logik
- Einfaches Hinzufügen neuer Pakete durch Arrays

#### Robustheit
- Bessere Validierung von Benutzereingaben
- Verbesserte Datei-Backup-Funktion (mit Zeitstempel)
- Sicheres Verzeichnis-Handling
- Graceful Degradation bei fehlenden Tools
- Trap für Terminal-Cursor bei TUI

### 📦 Technische Änderungen

#### Dateistruktur
```
v2/
├── instalar.sh          # Hauptskript (alles in einer Datei, ~650 Zeilen)
├── README.md            # ~300 Zeilen (Dokumentation)
└── CHANGELOG.md         # Diese Datei
```

**Vorteile der Ein-Datei-Struktur:**
- Einfacher zu kopieren/verteilen
- Keine Abhängigkeiten zwischen Dateien
- Einfacheres Debugging
- Selbst-contained

### 🐛 Bugfixes
- Keine funktionalen Änderungen, nur Refactoring
- Keine neuen Bugs eingeführt

### 📝 Dokumentation
- README komplett neu geschrieben
- CHANGELOG im Semantic Versioning Format
- Inline-Kommentare für alle Funktionen
- Architektur-Beschreibung hinzugefügt

---

## [1.0.0] - 2026-01-30 (ursprüngliche Version)

### ✨ Features
- Interaktive Projektnamensvergabe
- Installationsmodus (automatisch/manuell)
- Manuelle Paketauswahl für Filament, Livewire, Pest, Laravel Boost
- PHP-Version Auswahl (8.3, 8.4, 8.5) mit Auto-Install
- System-Checks für PHP, Composer, Node.js, npm
- Laravel Installer Installation/Update
- Projekt-Scaffolding mit `laravel new`
- SQLite Setup mit .env Backup
- Filament Panel Installation
- Livewire Konfiguration
- Migrationen und Admin-User Erstellung
- Frontend Build (npm install + build)
- Berechtigungen für storage/ und bootstrap/cache
- Optimierung: Cache-Clears und Cache-Aufbau
- Entwicklungsserver Start
- Fehlerbehandlung mit installation_errors.log
- Fortschrittsbalken
- Farbige Konsolenausgabe
- TUI-Navigation mit Pfeiltasten
- Feature-Auswahl (Breeze, Jetstream, Redis, Scout, Horizon)
- Git Repository Initialisierung
- Sanity Report am Ende

### 📦 Pakete
- Filament 5.1
- Livewire 4.x
- Pest 2.x
- Laravel Boost
- Laravel Debugbar

---

## Vergleich: v1 vs v2

| Aspekt | v1 | v2 |
|--------|-----|-----|
| **Dateien** | 1 (1581 Zeilen) | 1 (modular organisiert) |
| **Architektur** | Monolithisch | Logisch strukturiert |
| **Exit-Codes** | Keine | 6 Standard-Codes |
| **Dokumentation** | Basic (~60 Zeilen) | Umfassend (~300 Zeilen) |
| **Kommentare** | Minimal | Umfassend (DocBlocks) |
| **Wartbarkeit** | Schwer | Einfach |
| **Lesbarkeit** | Durchschnitt | Sehr gut |
| **Erweiterbarkeit** | Schwer | Einfach |

---

## Upgrade-Guide

### Von v1 zu v2

1. **Neue Dateistruktur**: Alle Dateien sind jetzt im `v2/` Verzeichnis
2. **Keine funktionalen Änderungen**: Der Workflow ist identisch
3. **Nur eine Datei**: `instalar.sh` enthält alles
4. **Kompatibilität**: Gleiche Kommandozeilen-Schnittstelle

### Verwendung bleibt gleich

```bash
# Alt (v1)
./instalar.sh

# Neu (v2)
cd v2
./instalar.sh
```

---

## Roadmap

### Erreicht in v2.1 ✅
- [x] **Datenbank-Auswahl im manuellen Modus** - MySQL, PostgreSQL, SQL Server, SQLite
- [x] **Automatische Datenbank-Erstellung** - Für MySQL und PostgreSQL
- [x] **Verbindungstests** - Vor Migrationen

### Geplant für v2.2
- [ ] Konfigurationsdatei (YAML/JSON) für wiederholbare Installationen
- [ ] Docker-Support für containerisierte Entwicklung
- [ ] Template-System für verschiedene Projekttypen
- [ ] Plugin-System für benutzerdefinierte Pakete

### Geplant für v2.2
- [ ] GUI-Modus (zenity/dialog)
- [ ] Batch-Modus für CI/CD
- [ ] Update-Checker für Pakete
- [ ] Offline-Modus mit lokalen Caches

---

## Mitwirken

Hast du einen Fehler gefunden oder möchtest du ein Feature vorschlagen?

1. Issue erstellen
2. Fork & Pull Request
3. Changelog aktualisieren

---

**Historie anzeigen:** `git log --oneline --decorate`

**Autor:** yezz.design <design@schodie.de>
**Lizenz:** MIT
