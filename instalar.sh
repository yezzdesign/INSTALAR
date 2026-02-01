#!/bin/bash
#================================================================================
# INSTALAR v2.0 - Laravel + Filament Installationsskript
#================================================================================
# Erstellt ein vollständiges Laravel-Projekt mit modernem Stack
# 
# AUTOR:       yezz.design <design@schodie.de>
# VERSION:     2.0.0
# DATENBANK:   SQLite
# STACK:       Laravel + Filament 5.1 + Livewire + Pest
# 
# NUTZUNG:
#   chmod +x instalar.sh
#   ./instalar.sh
#
#================================================================================

# Bei Fehlern sofort beenden
set -e
set -o pipefail

#================================================================================
# KONFIGURATION & KONSTANTEN
#================================================================================

# Exit-Codes für Fehlerbehandlung
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR_GENERAL=1
readonly EXIT_ERROR_PREREQ=2
readonly EXIT_ERROR_LARAVEL=3
readonly EXIT_ERROR_DB=4
readonly EXIT_ERROR_PERMISSIONS=5
readonly EXIT_ERROR_GIT=6
readonly EXIT_ERROR_USER_CANCEL=130

# Projektkonfiguration
readonly SCRIPT_NAME="INSTALAR"
readonly SCRIPT_VERSION="2.0.0"
readonly DEFAULT_PROJECT_NAME="Laravel-2026"
readonly DEFAULT_DATABASE_TYPE="sqlite"

# Installationsvariablen
INSTALLATION_MODE="automatic"
USE_DEV_VERSION=false
JETSTREAM_STACK="livewire"
ENABLE_GIT=false
PROJECT_NAME="$DEFAULT_PROJECT_NAME"

# Paket-Flags
INSTALL_FILAMENT=true
INSTALL_LIVEWIRE=true
INSTALL_PEST=true
INSTALL_BOOST=true

# Versionen
FILAMENT_VERSION="^5.1"
LIVEWIRE_VERSION="^4.1"
PEST_VERSION="^2.0"

# Git-Konfiguration
GIT_INITIAL_COMMIT_MESSAGE="Initial commit"
GIT_USER_NAME="${USER:-user}"
GIT_USER_EMAIL="${USER:-user}@localhost"

# Datenbank-Konfiguration
DATABASE_TYPE="$DEFAULT_DATABASE_TYPE"
DB_HOST="127.0.0.1"
DB_PORT=""
DB_DATABASE=""
DB_USERNAME=""
DB_PASSWORD=""

# Datenbank-Typen verfügbar
readonly DATABASE_TYPES=(sqlite mysql pgsql sqlsrv)
declare -A DATABASE_LABEL=(
    [sqlite]="SQLite (Datei-basiert, empfohlen für Entwicklung)"
    [mysql]="MySQL / MariaDB"
    [pgsql]="PostgreSQL"
    [sqlsrv]="SQL Server"
)
declare -A DATABASE_DEFAULT_PORT=(
    [sqlite]=""
    [mysql]="3306"
    [pgsql]="5432"
    [sqlsrv]="1433"
)

# Arrays für Pakete
EXTRA_PACKAGES=()
EXTRA_DEV_PACKAGES=()
SELECTED_PACKAGE_IDS=()
SELECTED_PACKAGE_LABELS=()
SELECTED_FEATURE_IDS=()
SELECTED_FEATURE_LABELS=()

#================================================================================
# PAKET-DEFINITIONEN
#================================================================================

# Paket-Keys (Reihenfolge der Anzeige)
PACKAGE_KEYS=(
    filament livewire pest boost
    fortify sanctum passport socialite
    permission scout horizon telescope
    health backup activitylog settings
    medialibrary csp honeypot excel
    sentry debugbar pint larastan ide-helper
)

# Paket-Labels
declare -A PACKAGE_LABEL=(
    [filament]="Filament (Admin Panel)"
    [livewire]="Livewire (Frontend)"
    [pest]="Pest (Testing)"
    [boost]="Laravel Boost"
    [fortify]="Laravel Fortify (Auth Backend)"
    [sanctum]="Laravel Sanctum (API/SPA Auth)"
    [passport]="Laravel Passport (OAuth2)"
    [socialite]="Laravel Socialite (OAuth)"
    [permission]="Spatie Permission (Roles/Permissions)"
    [scout]="Laravel Scout (Search)"
    [horizon]="Laravel Horizon (Queues)"
    [telescope]="Laravel Telescope (Debug)"
    [health]="Spatie Health (Health Checks)"
    [backup]="Spatie Backup (Backups)"
    [activitylog]="Spatie Activitylog (Audit)"
    [settings]="Spatie Settings (App Settings)"
    [medialibrary]="Spatie Medialibrary (Media)"
    [csp]="Spatie CSP (Security)"
    [honeypot]="Spatie Honeypot (Bot Protection)"
    [excel]="Maatwebsite Excel (Import/Export)"
    [sentry]="Sentry (Error Tracking)"
    [debugbar]="Laravel Debugbar"
    [pint]="Laravel Pint (Formatter)"
    [larastan]="Larastan (Static Analysis)"
    [ide-helper]="IDE Helper (Autoload Hints)"
)

# Composer-Paketnamen
declare -A PACKAGE_COMPOSER=(
    [filament]="filament/filament"
    [livewire]="livewire/livewire"
    [pest]="pestphp/pest"
    [boost]="laravel/boost"
    [fortify]="laravel/fortify"
    [sanctum]="laravel/sanctum"
    [passport]="laravel/passport"
    [socialite]="laravel/socialite"
    [permission]="spatie/laravel-permission"
    [scout]="laravel/scout"
    [horizon]="laravel/horizon"
    [telescope]="laravel/telescope"
    [health]="spatie/laravel-health"
    [backup]="spatie/laravel-backup"
    [activitylog]="spatie/laravel-activitylog"
    [settings]="spatie/laravel-settings"
    [medialibrary]="spatie/laravel-medialibrary"
    [csp]="spatie/laravel-csp"
    [honeypot]="spatie/laravel-honeypot"
    [excel]="maatwebsite/excel"
    [sentry]="sentry/sentry-laravel"
    [debugbar]="barryvdh/laravel-debugbar"
    [pint]="laravel/pint"
    [larastan]="nunomaduro/larastan"
    [ide-helper]="barryvdh/laravel-ide-helper"
)

# Dev-Pakete (werden mit --dev installiert)
declare -A PACKAGE_DEV=(
    [pest]=true
    [telescope]=true
    [debugbar]=true
    [pint]=true
    [larastan]=true
    [ide-helper]=true
)

# Standard-Pakete (im Automatik-Modus)
declare -A PACKAGE_DEFAULT=(
    [filament]=true
    [livewire]=true
    [pest]=true
    [boost]=true
    [debugbar]=true
)

# Feature-Definitionen
FEATURE_KEYS=(breeze jetstream redis scout-meilisearch horizon)

declare -A FEATURE_LABEL=(
    [breeze]="Laravel Breeze (Auth Starter)"
    [jetstream]="Laravel Jetstream (Auth + Teams)"
    [redis]="Redis Support (predis)"
    [scout-meilisearch]="Scout + Meilisearch (Search)"
    [horizon]="Laravel Horizon (Queues Setup)"
)

declare -A FEATURE_COMPOSER=(
    [breeze]="laravel/breeze"
    [jetstream]="laravel/jetstream"
    [redis]="predis/predis"
    [scout-meilisearch]="laravel/scout meilisearch/meilisearch-php"
    [horizon]="laravel/horizon"
)

declare -A FEATURE_DEV=([breeze]=true [jetstream]=true)

declare -A FEATURE_DEFAULT=()

# PHP-Extensions
REQUIRED_EXTENSIONS=(mbstring xml ctype iconv intl pdo tokenizer bcmath json fileinfo pdo_sqlite openssl zip)

#================================================================================
# FARBDEFINITIONEN & AUSGABEFUNKTIONEN
#================================================================================

readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_NC='\033[0m'

# Zeigt einen formatierten Header an
print_header() {
    echo -e "\n${COLOR_BLUE}================================================================================${COLOR_NC}"
    echo -e "${COLOR_BLUE}$1${COLOR_NC}"
    echo -e "${COLOR_BLUE}================================================================================${COLOR_NC}"
}

# Zeigt das ASCII-Logo
print_logo() {
    cat <<'EOF'
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
EOF
}

# Erfolgsnachricht
print_success() {
    echo -e "${COLOR_GREEN}✓ $1${COLOR_NC}"
}

# Fehlermeldung
print_error() {
    echo -e "${COLOR_RED}✗ $1${COLOR_NC}"
}

# Warnung
print_warning() {
    echo -e "${COLOR_YELLOW}⚠ $1${COLOR_NC}"
}

# Info
print_info() {
    echo -e "${COLOR_CYAN}ℹ $1${COLOR_NC}"
}

# Schritt
print_step() {
    echo -e "\n${COLOR_PURPLE}► $1${COLOR_NC}"
}

#================================================================================
# FEHLERBEHANDLUNG & UTILITIES
#================================================================================

# Behandelt Fehler und beendet das Skript
# Usage: handle_error "Beschreibung" [exit_code]
handle_error() {
    local step="$1"
    local exit_code="${2:-$EXIT_ERROR_GENERAL}"
    
    print_error "Installation fehlgeschlagen bei: $step"
    print_info "Debug-Informationen werden gespeichert..."
    
    {
        echo "========================================"
        echo "Fehlerzeitpunkt: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Schritt: $step"
        echo "Exit-Code: $exit_code"
        echo "Arbeitsverzeichnis: $(pwd)"
        echo "========================================"
    } >> installation_errors.log
    
    exit "$exit_code"
}

# Prüft ob ein Befehl existiert
command_exists() {
    command -v "$1" &> /dev/null
}

# Fügt ein Element nur hinzu, wenn es noch nicht existiert
append_unique() {
    local -n arr=$1
    local val="$2"
    for item in "${arr[@]}"; do
        [[ "$item" == "$val" ]] && return 0
    done
    arr+=("$val")
    return 0
}

# Zeigt den Fortschritt als Prozentbalken
# Usage: show_progress current_step total_steps "Beschreibung"
show_progress() {
    local current="$1"
    local total="$2"
    local description="${3:-}"
    local percent=$((current * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    
    printf "\r${COLOR_BLUE}["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "]${COLOR_NC} %3d%% (%d/%d)" "$percent" "$current" "$total"
    [[ -n "$description" ]] && printf " - %s" "$description"
    printf "\n"
}

# Validiert einen Projektnamen
validate_project_name() {
    local name="$1"
    [[ -z "$name" ]] && return 1
    [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]] && return 0 || return 1
}

#================================================================================
# BENUTZERINTERAKTION
#================================================================================

# Fragt den Benutzer nach dem Projektnamen
ask_project_name() {
    print_step "Projektnamen festlegen"
    echo -e "${COLOR_CYAN}Bitte geben Sie den Namen für Ihr Laravel-Projekt ein:${COLOR_NC}"
    read -r -p "Projektname (Standard: $DEFAULT_PROJECT_NAME): " INPUT_PROJECT_NAME || true
    
    if [[ -n "$INPUT_PROJECT_NAME" ]]; then
        if validate_project_name "$INPUT_PROJECT_NAME"; then
            PROJECT_NAME="$INPUT_PROJECT_NAME"
            print_success "Projektname: $PROJECT_NAME"
        else
            print_error "Ungültiger Projektname! Nur Buchstaben, Zahlen, _ und - erlaubt."
            print_info "Verwende Standard: $DEFAULT_PROJECT_NAME"
            PROJECT_NAME="$DEFAULT_PROJECT_NAME"
            sleep 2
        fi
    else
        PROJECT_NAME="$DEFAULT_PROJECT_NAME"
        print_success "Verwende Standard: $PROJECT_NAME"
    fi
    echo
}

# Fragt den Benutzer nach dem Installationsmodus
ask_installation_mode() {
    print_step "Installationsmodus auswählen"
    echo -e "${COLOR_CYAN}Möchten Sie die Installation automatisch oder manuell durchführen?${COLOR_NC}"
    echo "1) Automatisch (empfohlen) - Standard-Pakete"
    echo "2) Manuell - Einzelne Pakete wählen"
    
    while true; do
        read -r -p "Wählen Sie (1-2, Standard: 1): " MODE_CHOICE || true
        case "$MODE_CHOICE" in
            1|"") 
                INSTALLATION_MODE="automatic"
                print_success "Automatische Installation ausgewählt"
                break
                ;;
            2)
                INSTALLATION_MODE="manual"
                print_success "Manuelle Installation ausgewählt"
                break
                ;;
            *)
                print_error "Ungültige Auswahl! Bitte 1 oder 2."
                ;;
        esac
    done
    echo
}

# Fragt nach Git-Setup
ask_git_setup() {
    print_step "Git Setup"
    echo -e "${COLOR_CYAN}Möchten Sie ein Git-Repository initialisieren?${COLOR_NC}"
    read -r -p "Git initialisieren? (J/n): " -n 1 || true
    echo
    if [[ "$REPLY" =~ ^[Nn]$ ]]; then
        ENABLE_GIT=false
        print_info "Git Setup übersprungen"
    else
        ENABLE_GIT=true
        print_success "Git Setup aktiviert"
    fi
    echo
}

# Fragt nach Datenbank-Auswahl
ask_database_selection() {
    print_step "Datenbank auswählen"
    echo -e "${COLOR_CYAN}Welche Datenbank möchten Sie verwenden?${COLOR_NC}"
    echo
    
    local i
    for ((i=0; i<${#DATABASE_TYPES[@]}; i++)); do
        local db_type="${DATABASE_TYPES[$i]}"
        local label="${DATABASE_LABEL[$db_type]}"
        local marker=""
        [[ "$db_type" == "$DEFAULT_DATABASE_TYPE" ]] && marker=" (Standard)"
        echo "$((i+1))) $label$marker"
    done
    echo
    
    while true; do
        read -r -p "Wählen Sie (1-${#DATABASE_TYPES[@]}, Standard: 1): " DB_CHOICE || true
        
        # Standardwert
        [[ -z "$DB_CHOICE" ]] && DB_CHOICE=1
        
        # Validierung
        if [[ "$DB_CHOICE" =~ ^[0-9]+$ ]] && [[ "$DB_CHOICE" -ge 1 ]] && [[ "$DB_CHOICE" -le ${#DATABASE_TYPES[@]} ]]; then
            DATABASE_TYPE="${DATABASE_TYPES[$((DB_CHOICE-1))]}"
            print_success "Datenbank: ${DATABASE_LABEL[$DATABASE_TYPE]}"
            break
        else
            print_error "Ungültige Auswahl! Bitte 1-${#DATABASE_TYPES[@]} eingeben."
        fi
    done
    
    # Zusätzliche Konfiguration für externe Datenbanken
    if [[ "$DATABASE_TYPE" != "sqlite" ]]; then
        echo
        print_info "Datenbank-Verbindung konfigurieren"
        
        # Host
        read -r -p "Host [127.0.0.1]: " INPUT_HOST || true
        DB_HOST="${INPUT_HOST:-127.0.0.1}"
        
        # Port
        local default_port="${DATABASE_DEFAULT_PORT[$DATABASE_TYPE]}"
        read -r -p "Port [$default_port]: " INPUT_PORT || true
        DB_PORT="${INPUT_PORT:-$default_port}"
        
        # Datenbankname
        local default_dbname=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '-_' '_')
        read -r -p "Datenbankname [$default_dbname]: " INPUT_DBNAME || true
        DB_DATABASE="${INPUT_DBNAME:-$default_dbname}"
        
        # Benutzername
        read -r -p "Benutzername [root]: " INPUT_USER || true
        DB_USERNAME="${INPUT_USER:-root}"
        
        # Passwort
        read -r -s -p "Passwort: " DB_PASSWORD || true
        echo
        
        print_success "Datenbank-Konfiguration gespeichert"
    fi
    
    echo
}

# Fragt nach Laravel-Version
ask_laravel_version() {
    print_step "Laravel Version auswählen"
    echo -e "${COLOR_CYAN}Möchten Sie die Development-Version (master) nutzen?${COLOR_NC}"
    read -r -p "Dev-Version? (j/N): " -n 1 || true
    echo
    if [[ "$REPLY" =~ ^[Jj]$ ]]; then
        USE_DEV_VERSION=true
        print_warning "Master-Version ist NICHT SAFE"
    else
        USE_DEV_VERSION=false
        print_success "Stable Version ausgewählt"
    fi
    echo
}

# Zeigt eine interaktive Mehrfachauswahlliste
show_multiselect() {
    local -n keys_ref=$1
    local -n selected_ref=$2
    local -n label_ref=$3
    local -n dev_ref=$4
    local -n default_ref=$5
    
    local index=0
    local list_lines=${#keys_ref[@]}
    local use_tput=false
    
    if command_exists tput; then
        use_tput=true
        tput civis 2>/dev/null || true
        trap 'tput cnorm 2>/dev/null' EXIT
    fi
    
    local input
    while true; do
        local i
        for ((i=0; i<list_lines; i++)); do
            local key="${keys_ref[$i]}"
            local label="${label_ref[$key]}"
            local mark="[ ]"
            local prefix="  "
            local dev_tag=""
            local default_tag=""
            
            [[ "${selected_ref[$i]}" -eq 1 ]] && mark="[x]"
            [[ $i -eq $index ]] && prefix="> "
            [[ "${dev_ref[$key]}" == "true" ]] && dev_tag=" [dev]"
            [[ "${default_ref[$key]}" == "true" ]] && default_tag=" *"
            
            printf "\033[2K\r%s%s %s%s%s\n" "$prefix" "$mark" "$label" "$dev_tag" "$default_tag"
        done
        
        IFS= read -rs -n 1 input || true
        case "$input" in
            $'\x1b')
                IFS= read -rs -n 2 -t 0.1 input || true
                case "$input" in
                    '[A') 
                        ((index--))
                        [[ $index -lt 0 ]] && index=$((list_lines - 1))
                        ;;
                    '[B')
                        ((index++))
                        [[ $index -ge $list_lines ]] && index=0
                        ;;
                esac
                ;;
            ' ')
                [[ "${selected_ref[$index]}" -eq 1 ]] && selected_ref[$index]=0 || selected_ref[$index]=1
                ;;
            'a'|'A')
                for ((i=0; i<${#keys_ref[@]}; i++)); do selected_ref[$i]=1; done
                ;;
            '0')
                for ((i=0; i<${#keys_ref[@]}; i++)); do selected_ref[$i]=0; done
                ;;
            ''|$'\n')
                break
                ;;
        esac
        
        if $use_tput; then
            tput cuu "$list_lines" 2>/dev/null || true
        else
            printf '\033[%dA' "$list_lines"
        fi
    done
    
    if $use_tput; then
        tput cnorm 2>/dev/null || true
        trap - EXIT
    fi
    echo
}

# Paketauswahl
ask_package_selection() {
    print_step "Pakete auswählen"
    echo -e "${COLOR_CYAN}Navigation: Pfeil hoch/runter, Leertaste zum Auswählen, Enter zum Bestätigen${COLOR_NC}"
    echo "a = alle | 0 = keine | * = Standard"
    echo
    
    local -a selected=()
    local i
    for ((i=0; i<${#PACKAGE_KEYS[@]}; i++)); do
        local key="${PACKAGE_KEYS[$i]}"
        [[ "${PACKAGE_DEFAULT[$key]}" == "true" ]] && selected[$i]=1 || selected[$i]=0
    done
    
    show_multiselect PACKAGE_KEYS selected PACKAGE_LABEL PACKAGE_DEV PACKAGE_DEFAULT
    
    # Zurücksetzen
    INSTALL_FILAMENT=false
    INSTALL_LIVEWIRE=false
    INSTALL_PEST=false
    INSTALL_BOOST=false
    EXTRA_PACKAGES=()
    EXTRA_DEV_PACKAGES=()
    SELECTED_PACKAGE_IDS=()
    SELECTED_PACKAGE_LABELS=()
    
    for ((i=0; i<${#PACKAGE_KEYS[@]}; i++)); do
        if [[ "${selected[$i]}" -eq 1 ]]; then
            local key="${PACKAGE_KEYS[$i]}"
            SELECTED_PACKAGE_IDS+=("$key")
            SELECTED_PACKAGE_LABELS+=("${PACKAGE_LABEL[$key]}")
            case "$key" in
                filament) INSTALL_FILAMENT=true ;;
                livewire) INSTALL_LIVEWIRE=true ;;
                pest) INSTALL_PEST=true ;;
                boost) INSTALL_BOOST=true ;;
                *)
                    local pkg="${PACKAGE_COMPOSER[$key]}"
                    if [[ "${PACKAGE_DEV[$key]}" == "true" ]]; then
                        append_unique EXTRA_DEV_PACKAGES "$pkg"
                    else
                        append_unique EXTRA_PACKAGES "$pkg"
                    fi
                    ;;
            esac
        fi
    done
    
    print_success "Paketauswahl gespeichert"
    echo
}

# Feature-Auswahl
ask_feature_selection() {
    print_step "Features auswählen"
    echo -e "${COLOR_CYAN}Navigation: Pfeil hoch/runter, Leertaste zum Auswählen, Enter zum Bestätigen${COLOR_NC}"
    echo "a = alle | 0 = keine"
    echo
    
    local -a selected=()
    local i
    for ((i=0; i<${#FEATURE_KEYS[@]}; i++)); do
        local key="${FEATURE_KEYS[$i]}"
        [[ "${FEATURE_DEFAULT[$key]}" == "true" ]] && selected[$i]=1 || selected[$i]=0
    done
    
    show_multiselect FEATURE_KEYS selected FEATURE_LABEL FEATURE_DEV FEATURE_DEFAULT
    
    # Konfliktprüfung Breeze vs Jetstream
    local breeze_idx=-1
    local jetstream_idx=-1
    for ((i=0; i<${#FEATURE_KEYS[@]}; i++)); do
        [[ "${FEATURE_KEYS[$i]}" == "breeze" ]] && breeze_idx=$i
        [[ "${FEATURE_KEYS[$i]}" == "jetstream" ]] && jetstream_idx=$i
    done
    
    if [[ $breeze_idx -ge 0 && $jetstream_idx -ge 0 ]]; then
        if [[ "${selected[$breeze_idx]}" -eq 1 && "${selected[$jetstream_idx]}" -eq 1 ]]; then
            print_warning "Breeze und Jetstream ausgewählt. Jetstream hat Vorrang."
            selected[$breeze_idx]=0
        fi
    fi
    
    # Jetstream Stack anpassen
    if [[ $jetstream_idx -ge 0 && "${selected[$jetstream_idx]}" -eq 1 ]]; then
        if [[ "$INSTALL_FILAMENT" == "true" || "$INSTALL_LIVEWIRE" == "true" ]]; then
            JETSTREAM_STACK="inertia"
            print_warning "Jetstream Stack auf Inertia umgeschaltet (Livewire 4/Filament Kompatibilität)"
        fi
    fi
    
    SELECTED_FEATURE_IDS=()
    SELECTED_FEATURE_LABELS=()
    for ((i=0; i<${#FEATURE_KEYS[@]}; i++)); do
        if [[ "${selected[$i]}" -eq 1 ]]; then
            local key="${FEATURE_KEYS[$i]}"
            SELECTED_FEATURE_IDS+=("$key")
            SELECTED_FEATURE_LABELS+=("${FEATURE_LABEL[$key]}")
            local pkgs="${FEATURE_COMPOSER[$key]}"
            local pkg
            for pkg in $pkgs; do
                if [[ "${FEATURE_DEV[$key]}" == "true" ]]; then
                    append_unique EXTRA_DEV_PACKAGES "$pkg"
                else
                    append_unique EXTRA_PACKAGES "$pkg"
                fi
            done
        fi
    done
    
    print_success "Feature-Auswahl gespeichert"
    echo
}

# Manuelle Installation
manual_installation() {
    print_step "Manuelle Konfiguration"
    ask_laravel_version
    ask_package_selection
    ask_feature_selection
    ask_database_selection
    ask_git_setup

    # Zusammenfassung
    print_step "Zusammenfassung"
    echo -e "${COLOR_CYAN}Modus:${COLOR_NC} Manuell"
    [[ "$USE_DEV_VERSION" == "true" ]] && echo -e "${COLOR_CYAN}Laravel:${COLOR_NC} master" || echo -e "${COLOR_CYAN}Laravel:${COLOR_NC} latest"
    [[ ${#SELECTED_PACKAGE_LABELS[@]} -eq 0 ]] && echo -e "${COLOR_CYAN}Pakete:${COLOR_NC} Keine" || echo -e "${COLOR_CYAN}Pakete:${COLOR_NC} ${SELECTED_PACKAGE_LABELS[*]}"
    [[ ${#SELECTED_FEATURE_LABELS[@]} -eq 0 ]] && echo -e "${COLOR_CYAN}Features:${COLOR_NC} Keine" || echo -e "${COLOR_CYAN}Features:${COLOR_NC} ${SELECTED_FEATURE_LABELS[*]}"
    echo -e "${COLOR_CYAN}Datenbank:${COLOR_NC} ${DATABASE_LABEL[$DATABASE_TYPE]}"
    if [[ "$DATABASE_TYPE" != "sqlite" ]]; then
        echo -e "${COLOR_CYAN}DB-Verbindung:${COLOR_NC} $DB_USERNAME@$DB_HOST:$DB_PORT/$DB_DATABASE"
    fi
    echo -e "${COLOR_CYAN}Git:${COLOR_NC} $([[ "$ENABLE_GIT" == "true" ]] && echo "Ja" || echo "Nein")"
    echo
    
    read -r -p "Fortfahren? (J/n): " -n 1 || true
    echo
    if [[ "$REPLY" =~ ^[Nn]$ ]]; then
        print_info "Installation abgebrochen."
        exit $EXIT_SUCCESS
    fi
    print_success "Konfiguration bestätigt"
    echo
}

#================================================================================
# SYSTEMVORAUSSETZUNGEN
#================================================================================

check_prerequisites() {
    print_step "Systemvoraussetzungen prüfen"
    
    # Schreibzugriff
    if [[ ! -w "." ]]; then
        print_error "Kein Schreibzugriff: $(pwd)"
        exit $EXIT_ERROR_PERMISSIONS
    fi
    print_success "Schreibzugriff OK"
    
    # PHP
    if command_exists php; then
        local php_version
        php_version=$(php -r "echo PHP_VERSION;")
        local php_major
        php_major=$(echo "$php_version" | cut -d. -f1)
        local php_minor
        php_minor=$(echo "$php_version" | cut -d. -f2)
        
        if [[ "$php_major" -ge 8 && "$php_minor" -ge 1 ]]; then
            print_success "PHP $php_version (>= 8.1)"
        else
            print_error "PHP $php_version zu alt. Minimum 8.1 erforderlich."
            exit $EXIT_ERROR_PREREQ
        fi
    else
        print_error "PHP nicht gefunden."
        exit $EXIT_ERROR_PREREQ
    fi
    
    # Composer
    if command_exists composer; then
        local cv
        cv=$(composer --version | awk '{print $3}')
        print_success "Composer $cv"
        [[ "${cv%%.*}" -lt 2 ]] && print_warning "Composer 2.x empfohlen"
    else
        print_error "Composer nicht gefunden."
        exit $EXIT_ERROR_PREREQ
    fi
    
    # Node.js
    if command_exists node; then
        local nv
        nv=$(node --version)
        print_success "Node.js $nv"
        local nv_major
        nv_major=$(echo "$nv" | sed 's/^v//' | cut -d. -f1)
        [[ "$nv_major" -lt 18 ]] && print_warning "Node.js 18+ empfohlen"
    else
        print_error "Node.js nicht gefunden."
        exit $EXIT_ERROR_PREREQ
    fi
    
    # NPM
    if command_exists npm; then
        print_success "NPM $(npm --version)"
    else
        print_error "NPM nicht gefunden."
        exit $EXIT_ERROR_PREREQ
    fi
    
    # Weitere Tools
    command_exists curl && print_success "curl OK" || { print_error "curl fehlt"; exit $EXIT_ERROR_PREREQ; }
    command_exists unzip && print_success "unzip OK" || print_warning "unzip fehlt"
    
    # Git
    if [[ "$ENABLE_GIT" == "true" ]]; then
        if command_exists git; then
            print_success "Git $(git --version | awk '{print $3}')"
        else
            print_error "Git nicht gefunden."
            exit $EXIT_ERROR_PREREQ
        fi
    fi
    
    # PHP Extensions
    print_info "Prüfe PHP-Extensions..."
    local ext
    for ext in "${REQUIRED_EXTENSIONS[@]}"; do
        if php -m | grep -q "$ext"; then
            print_success "PHP-Extension '$ext' OK"
        else
            print_warning "PHP-Extension '$ext' fehlt"
        fi
    done
}

#================================================================================
# LARAVEL INSTALLATION
#================================================================================

install_or_update_laravel_installer() {
    print_step "Laravel Installer"
    
    if command_exists laravel; then
        print_info "Laravel Installer wird aktualisiert..."
        composer global update laravel/installer --no-interaction >/dev/null 2>&1 || handle_error "Laravel Installer Update" $EXIT_ERROR_LARAVEL
        print_success "Laravel Installer aktualisiert"
    else
        print_info "Laravel Installer wird installiert..."
        composer global require laravel/installer --no-interaction >/dev/null 2>&1 || handle_error "Laravel Installer Installation" $EXIT_ERROR_LARAVEL
        print_success "Laravel Installer installiert"
        
        local cbp="$HOME/.composer/vendor/bin"
        if [[ -d "$cbp" ]] && [[ ":$PATH:" != *":$cbp:"* ]]; then
            echo "export PATH=\"$cbp:\$PATH\"" >> ~/.bashrc
            export PATH="$cbp:$PATH"
        fi
    fi
}

create_laravel_project() {
    print_step "Laravel-Projekt '$PROJECT_NAME' erstellen"
    
    local project_dir="$PROJECT_NAME"
    local project_dir_lower
    local project_dir_slug
    project_dir_lower=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
    project_dir_slug=$(printf '%s' "$project_dir_lower" | tr '_' '-')
    
    # Prüfen ob existiert
    if [[ -d "$project_dir" ]] || [[ -d "$project_dir_lower" ]] || [[ -d "$project_dir_slug" ]]; then
        local existing_dir="$project_dir"
        [[ -d "$project_dir_lower" ]] && existing_dir="$project_dir_lower"
        [[ -d "$project_dir_slug" ]] && existing_dir="$project_dir_slug"
        
        print_error "Verzeichnis '$existing_dir' existiert bereits!"
        read -r -p "Löschen? (j/N): " -n 1 || true
        echo
        if [[ "$REPLY" =~ ^[Jj]$ ]]; then
            rm -rf "$existing_dir"
            print_success "Gelöscht"
        else
            print_error "Abgebrochen"
            exit $EXIT_ERROR_GENERAL
        fi
    fi
    
    # Laravel Flags
    local laravel_flags="--npm --no-interaction"
    [[ "$INSTALL_PEST" == "true" || "$INSTALLATION_MODE" == "automatic" ]] && laravel_flags="$laravel_flags --pest"
    [[ "$INSTALL_BOOST" == "true" || "$INSTALLATION_MODE" == "automatic" ]] && laravel_flags="$laravel_flags --boost"
    [[ "$USE_DEV_VERSION" == "true" ]] && laravel_flags="$laravel_flags --dev"
    
    print_info "Laravel Flags: $laravel_flags"
    local laravel_log
    laravel_log=$(mktemp)
    
    if ! laravel new "$PROJECT_NAME" $laravel_flags >/dev/null 2>&1; then
        handle_error "Laravel Projekt Erstellung" $EXIT_ERROR_LARAVEL
    fi
    
    # Verzeichnis finden
    if [[ -d "$project_dir" ]]; then
        :
    elif [[ -d "$project_dir_lower" ]]; then
        project_dir="$project_dir_lower"
        print_warning "Projekt als '$project_dir' erstellt"
    elif [[ -d "$project_dir_slug" ]]; then
        project_dir="$project_dir_slug"
        print_warning "Projekt als '$project_dir' erstellt"
    else
        tail -n 50 "$laravel_log" >> installation_errors.log
        rm -f "$laravel_log"
        handle_error "Projektverzeichnis nicht gefunden" $EXIT_ERROR_LARAVEL
    fi
    
    rm -f "$laravel_log"
    print_success "Laravel-Projekt '$project_dir' erstellt"
    
    cd "$project_dir" || exit $EXIT_ERROR_GENERAL
    print_success "Wechsle in: $(pwd)"
}

#================================================================================
# PAKETE INSTALLIEREN
#================================================================================

install_livewire() {
    [[ "$INSTALL_LIVEWIRE" != "true" ]] && { print_info "Livewire übersprungen"; return 0; }
    
    print_step "Livewire Installation"
    print_info "Installiere Livewire $LIVEWIRE_VERSION..."
    composer require livewire/livewire:"$LIVEWIRE_VERSION" --no-interaction >/dev/null 2>&1 || handle_error "Livewire Installation" $EXIT_ERROR_LARAVEL
    php artisan livewire:publish --config >/dev/null 2>&1 || handle_error "Livewire Konfiguration" $EXIT_ERROR_LARAVEL
    print_success "Livewire installiert"
}

install_filament() {
    [[ "$INSTALL_FILAMENT" != "true" ]] && { print_info "Filament übersprungen"; return 0; }
    
    print_step "Filament Installation"
    print_info "Installiere Filament $FILAMENT_VERSION..."
    composer require filament/filament:"$FILAMENT_VERSION" --no-interaction >/dev/null 2>&1 || handle_error "Filament Installation" $EXIT_ERROR_LARAVEL
    php artisan filament:install --panels --no-interaction >/dev/null 2>&1 || handle_error "Filament Panel Installation" $EXIT_ERROR_LARAVEL
    php artisan vendor:publish --tag=filament-config --force >/dev/null 2>&1 || handle_error "Filament Konfiguration" $EXIT_ERROR_LARAVEL
    print_success "Filament installiert"
}

install_features() {
    [[ ${#SELECTED_FEATURE_IDS[@]} -eq 0 ]] && { print_info "Keine Features ausgewählt"; return 0; }
    
    print_step "Feature-Installation"
    local key
    for key in "${SELECTED_FEATURE_IDS[@]}"; do
        case "$key" in
            breeze)
                print_info "Installiere Laravel Breeze..."
                php artisan breeze:install --stack=blade --no-interaction >/dev/null 2>&1 || handle_error "Breeze Installation" $EXIT_ERROR_LARAVEL
                print_success "Breeze installiert"
                ;;
            jetstream)
                print_info "Installiere Laravel Jetstream..."
                php artisan jetstream:install "$JETSTREAM_STACK" --no-interaction >/dev/null 2>&1 || handle_error "Jetstream Installation" $EXIT_ERROR_LARAVEL
                print_success "Jetstream installiert (Stack: $JETSTREAM_STACK)"
                ;;
            redis)
                print_success "Redis Support hinzugefügt"
                ;;
            scout-meilisearch)
                print_info "Scout Konfiguration..."
                php artisan vendor:publish --provider="Laravel\\Scout\\ScoutServiceProvider" --force >/dev/null 2>&1 && print_success "Scout OK" || print_warning "Scout fehlgeschlagen"
                ;;
            horizon)
                print_info "Installiere Horizon..."
                php artisan horizon:install >/dev/null 2>&1 || handle_error "Horizon Installation" $EXIT_ERROR_LARAVEL
                print_success "Horizon konfiguriert"
                ;;
        esac
    done
}

install_extra_packages() {
    print_step "Zusätzliche Pakete"
    
    if [[ ${#EXTRA_PACKAGES[@]} -gt 0 ]]; then
        print_info "Installiere ${#EXTRA_PACKAGES[@]} Pakete..."
        composer require "${EXTRA_PACKAGES[@]}" --no-interaction >/dev/null 2>&1 || handle_error "Paket-Installation" $EXIT_ERROR_LARAVEL
        print_success "Pakete installiert"
    else
        print_info "Keine zusätzlichen Pakete"
    fi
    
    if [[ ${#EXTRA_DEV_PACKAGES[@]} -gt 0 ]]; then
        print_info "Installiere ${#EXTRA_DEV_PACKAGES[@]} Dev-Pakete..."
        composer require --dev "${EXTRA_DEV_PACKAGES[@]}" --no-interaction >/dev/null 2>&1 || handle_error "Dev-Paket Installation" $EXIT_ERROR_LARAVEL
        print_success "Dev-Pakete installiert"
    else
        print_info "Keine Dev-Pakete"
    fi
}

configure_laravel_boost() {
    [[ "$INSTALL_BOOST" != "true" ]] && { print_info "Boost übersprungen"; return 0; }
    
    print_info "Konfiguriere Laravel Boost..."
    if php artisan boost:install 2>/dev/null; then
        print_success "Laravel Boost konfiguriert"
    else
        print_warning "Boost Konfiguration fehlgeschlagen"
    fi
}

#================================================================================
# DATENBANK SETUP
#================================================================================

# Testet die Datenbankverbindung
test_database_connection() {
    local db_type="$1"
    local host="$2"
    local port="$3"
    local database="$4"
    local username="$5"
    local password="$6"
    
    case "$db_type" in
        mysql)
            mysql -h "$host" -P "$port" -u "$username" -p"$password" -e "SELECT 1;" 2>/dev/null
            return $?
            ;;
        pgsql)
            PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$username" -d "$database" -c "SELECT 1;" 2>/dev/null
            return $?
            ;;
        sqlsrv)
            print_warning "SQL Server Verbindungstest wird übersprungen"
            return 0
            ;;
        sqlite)
            return 0
            ;;
    esac
}

# Erstellt die Datenbank falls sie nicht existiert
create_database_if_not_exists() {
    local db_type="$1"
    local host="$2"
    local port="$3"
    local database="$4"
    local username="$5"
    local password="$6"
    
    case "$db_type" in
        mysql)
            if ! mysql -h "$host" -P "$port" -u "$username" -p"$password" -e "USE \`$database\`;" 2>/dev/null; then
                print_info "Erstelle MySQL-Datenbank '$database'..."
                if mysql -h "$host" -P "$port" -u "$username" -p"$password" -e "CREATE DATABASE \`$database\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null; then
                    print_success "Datenbank '$database' erstellt"
                else
                    print_error "Datenbank konnte nicht erstellt werden"
                    return 1
                fi
            else
                print_info "Datenbank '$database' existiert bereits"
            fi
            ;;
        pgsql)
            if ! PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$username" -d "$database" -c "SELECT 1;" 2>/dev/null; then
                print_info "Erstelle PostgreSQL-Datenbank '$database'..."
                if PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$username" -c "CREATE DATABASE \"$database\" ENCODING 'UTF8';" 2>/dev/null; then
                    print_success "Datenbank '$database' erstellt"
                else
                    print_error "Datenbank konnte nicht erstellt werden"
                    return 1
                fi
            else
                print_info "Datenbank '$database' existiert bereits"
            fi
            ;;
        sqlsrv)
            print_warning "SQL Server Datenbank muss manuell erstellt werden"
            ;;
    esac
    
    return 0
}

setup_database() {
    print_step "${DATABASE_LABEL[$DATABASE_TYPE]} einrichten"
    
    if [[ -f ".env" ]]; then
        cp .env ".env.backup.$(date +%Y%m%d_%H%M%S)"
        
        case "$DATABASE_TYPE" in
            sqlite)
                [[ -d "database" ]] || mkdir -p database
                touch database/database.sqlite
                print_success "SQLite-Datenbank erstellt"
                
                sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
                sed -i 's|# DB_DATABASE=.*|DB_DATABASE=database/database.sqlite|' .env
                sed -i 's/^DB_HOST=.*/# DB_HOST=127.0.0.1/' .env
                sed -i 's/^DB_PORT=.*/# DB_PORT=3306/' .env
                sed -i 's/^DB_USERNAME=.*/# DB_USERNAME=root/' .env
                sed -i 's/^DB_PASSWORD=.*/# DB_PASSWORD=/' .env
                ;;
            
            mysql)
                sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
                sed -i "s/^#\?DB_HOST=.*/DB_HOST=$DB_HOST/" .env
                sed -i "s/^#\?DB_PORT=.*/DB_PORT=$DB_PORT/" .env
                sed -i "s/^#\?DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" .env
                sed -i "s/^#\?DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" .env
                sed -i "s/^#\?DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
                
                print_info "Teste MySQL-Verbindung..."
                if command_exists mysql; then
                    if test_database_connection "mysql" "$DB_HOST" "$DB_PORT" "" "$DB_USERNAME" "$DB_PASSWORD"; then
                        print_success "Verbindung OK"
                        create_database_if_not_exists "mysql" "$DB_HOST" "$DB_PORT" "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"
                    else
                        print_warning "Verbindungstest fehlgeschlagen - MySQL Client nicht verfügbar oder falsche Zugangsdaten"
                        print_info "Stellen Sie sicher, dass die Datenbank manuell erstellt wird"
                    fi
                else
                    print_warning "MySQL Client nicht installiert - Verbindungstest übersprungen"
                    print_info "Stellen Sie sicher, dass die Datenbank existiert"
                fi
                ;;
            
            pgsql)
                sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=pgsql/' .env
                sed -i "s/^#\?DB_HOST=.*/DB_HOST=$DB_HOST/" .env
                sed -i "s/^#\?DB_PORT=.*/DB_PORT=$DB_PORT/" .env
                sed -i "s/^#\?DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" .env
                sed -i "s/^#\?DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" .env
                sed -i "s/^#\?DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
                
                print_info "Teste PostgreSQL-Verbindung..."
                if command_exists psql; then
                    if test_database_connection "pgsql" "$DB_HOST" "$DB_PORT" "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"; then
                        print_success "Verbindung OK"
                    else
                        print_info "Versuche Datenbank zu erstellen..."
                        create_database_if_not_exists "pgsql" "$DB_HOST" "$DB_PORT" "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"
                    fi
                else
                    print_warning "PostgreSQL Client (psql) nicht installiert - Verbindungstest übersprungen"
                    print_info "Stellen Sie sicher, dass die Datenbank existiert"
                fi
                ;;
            
            sqlsrv)
                sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=sqlsrv/' .env
                sed -i "s/^#\?DB_HOST=.*/DB_HOST=$DB_HOST/" .env
                sed -i "s/^#\?DB_PORT=.*/DB_PORT=$DB_PORT/" .env
                sed -i "s/^#\?DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" .env
                sed -i "s/^#\?DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" .env
                sed -i "s/^#\?DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
                print_warning "SQL Server: Bitte stellen Sie sicher, dass die Datenbank manuell existiert"
                ;;
        esac
        
        print_success ".env für ${DATABASE_LABEL[$DATABASE_TYPE]} konfiguriert"
    else
        print_error ".env nicht gefunden!"
        handle_error "Datenbank Konfiguration" $EXIT_ERROR_DB
    fi
    
    php artisan key:generate >/dev/null 2>&1 || handle_error "Application Key" $EXIT_ERROR_DB
    print_success "Application Key generiert"
}

run_migrations() {
    print_step "Migrationen durchführen"
    php artisan migrate --force >/dev/null 2>&1 || handle_error "Migrationen" $EXIT_ERROR_DB
    print_success "Migrationen erfolgreich"
}

#================================================================================
# ADMIN USER & FRONTEND
#================================================================================

create_admin_user() {
    [[ "$INSTALL_FILAMENT" != "true" ]] && { print_info "Admin-User übersprungen"; return 0; }
    
    print_step "Filament Admin-User erstellen"
    local default_name="Admin User"
    local default_email="admin@example.com"
    local default_password="password"
    
    if [[ "$INSTALLATION_MODE" == "manual" ]]; then
        print_info "Admin-Daten eingeben (Enter für Standard):"
        read -r -p "Name [$default_name]: " ADMIN_NAME || true
        read -r -p "Email [$default_email]: " ADMIN_EMAIL || true
        read -r -s -p "Passwort [$default_password]: " ADMIN_PASSWORD || true
        echo
    fi
    
    ADMIN_NAME="${ADMIN_NAME:-$default_name}"
    ADMIN_EMAIL="${ADMIN_EMAIL:-$default_email}"
    ADMIN_PASSWORD="${ADMIN_PASSWORD:-$default_password}"
    
    php artisan make:filament-user --name="$ADMIN_NAME" --email="$ADMIN_EMAIL" --password="$ADMIN_PASSWORD" >/dev/null 2>&1 || handle_error "Admin User Erstellung"
    
    print_success "Admin-User erstellt"
    print_info "Login: $ADMIN_EMAIL / $ADMIN_PASSWORD"
    print_info "URL: http://localhost:8000/admin"
}

fix_frontend_dependencies() {
    print_step "Frontend-Abhängigkeiten prüfen"
    
    [[ -f "package.json" ]] || { print_info "Kein package.json"; return 0; }
    command_exists node || { print_warning "Node.js nicht gefunden"; return 0; }
    
    node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const deps = pkg.dependencies || {};
const dev = pkg.devDependencies || {};
const viteKey = dev.vite ? "dev" : (deps.vite ? "prod" : null);
const pluginVue = dev["@vitejs/plugin-vue"] || deps["@vitejs/plugin-vue"];
if (!viteKey || !pluginVue) process.exit(0);
const viteVersion = viteKey === "dev" ? dev.vite : deps.vite;
const viteMajor = parseInt((String(viteVersion).match(/(\d+)/) || [])[1], 10);
const pluginMajor = parseInt((String(pluginVue).match(/(\d+)/) || [])[1], 10);
if (!Number.isNaN(viteMajor) && !Number.isNaN(pluginMajor) && viteMajor >= 7 && pluginMajor <= 5) {
  if (dev["@vitejs/plugin-vue"]) dev["@vitejs/plugin-vue"] = "^6.0.0";
  else deps["@vitejs/plugin-vue"] = "^6.0.0";
  pkg.dependencies = deps;
  pkg.devDependencies = dev;
  fs.writeFileSync("package.json", JSON.stringify(pkg, null, 4) + "\n");
  console.log("changed");
}
' 2>/dev/null | grep -q "changed" && print_warning "Vue Plugin auf v6 angepasst" || true
}

build_frontend() {
    print_step "Frontend-Assets bauen"
    fix_frontend_dependencies
    npm install >/dev/null 2>&1 || handle_error "NPM Installation"
    npm run build >/dev/null 2>&1 || handle_error "Frontend Build"
    print_success "Frontend-Assets gebaut"
}

#================================================================================
# GIT & BERECHTIGUNGEN
#================================================================================

setup_git_repository() {
    [[ "$ENABLE_GIT" != "true" ]] && { print_info "Git übersprungen"; return 0; }
    
    print_step "Git Repository initialisieren"
    
    [[ -d ".git" ]] && { print_warning "Git existiert bereits"; return 0; }
    
    git init >/dev/null 2>&1 || handle_error "Git Init" $EXIT_ERROR_GIT
    
    git config user.name "$GIT_USER_NAME" 2>/dev/null || true
    git config user.email "$GIT_USER_EMAIL" 2>/dev/null || true
    
    git add -A >/dev/null 2>&1 || handle_error "Git Add" $EXIT_ERROR_GIT
    git diff --cached --quiet && { print_info "Keine Änderungen"; return 0; }
    
    git commit -m "$GIT_INITIAL_COMMIT_MESSAGE" >/dev/null 2>&1 || handle_error "Git Commit" $EXIT_ERROR_GIT
    print_success "Git Repository initialisiert"
}

set_permissions() {
    print_step "Berechtigungen setzen"
    chmod -R 775 storage bootstrap/cache
    if command_exists sudo; then
        sudo chown -R "$USER:$USER" storage bootstrap/cache 2>/dev/null || true
    fi
    print_success "Berechtigungen gesetzt"
}

optimize_application() {
    print_step "Anwendung optimieren"
    php artisan cache:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan route:clear 2>/dev/null || true
    php artisan view:clear 2>/dev/null || true
    php artisan config:cache >/dev/null 2>&1 || print_warning "Config-Cache fehlgeschlagen"
    php artisan route:cache >/dev/null 2>&1 || print_warning "Route-Cache fehlgeschlagen"
    php artisan view:cache >/dev/null 2>&1 || print_warning "View-Cache fehlgeschlagen"
    print_success "Anwendung optimiert"
}

#================================================================================
# SANITY REPORT & ABSCHLUSS
#================================================================================

sanity_report() {
    print_step "Sanity Report"
    
    local lv="unbekannt"
    local pv="unbekannt"
    local cv="unbekannt"
    local nv="unbekannt"
    local nm="unbekannt"
    
    command_exists php && pv=$(php -r "echo PHP_VERSION;")
    command_exists composer && cv=$(composer --version | awk '{print $3}')
    command_exists node && nv=$(node --version)
    command_exists npm && nm=$(npm --version)
    command_exists php && [[ -f artisan ]] && lv=$(php artisan --version)
    
    print_info "Projekt: $PROJECT_NAME"
    print_info "Pfad: $(pwd)"
    print_info "Laravel: $lv"
    print_info "PHP: $pv | Composer: $cv"
    print_info "Node: $nv | NPM: $nm"
    print_info "Modus: $INSTALLATION_MODE"
    print_info "Datenbank: ${DATABASE_LABEL[$DATABASE_TYPE]}"
    if [[ "$DATABASE_TYPE" != "sqlite" ]]; then
        print_info "DB-Verbindung: $DB_USERNAME@$DB_HOST:$DB_PORT/$DB_DATABASE"
    fi
    
    if [[ "$DATABASE_TYPE" == "sqlite" ]]; then
        [[ -f "database/database.sqlite" ]] && print_success "SQLite: OK" || print_warning "SQLite: Fehlt"
    fi
    [[ -w "storage" ]] && print_success "storage/: Schreibbar" || print_warning "storage/: Nicht schreibbar"
    [[ -w "bootstrap/cache" ]] && print_success "bootstrap/cache: Schreibbar" || print_warning "bootstrap/cache: Nicht schreibbar"
    
    local -a labels=()
    if [[ ${#SELECTED_PACKAGE_LABELS[@]} -gt 0 ]]; then
        labels=("${SELECTED_PACKAGE_LABELS[@]}")
    else
        [[ "$INSTALL_FILAMENT" == "true" ]] && labels+=("${PACKAGE_LABEL[filament]}")
        [[ "$INSTALL_LIVEWIRE" == "true" ]] && labels+=("${PACKAGE_LABEL[livewire]}")
        [[ "$INSTALL_PEST" == "true" ]] && labels+=("${PACKAGE_LABEL[pest]}")
        [[ "$INSTALL_BOOST" == "true" ]] && labels+=("${PACKAGE_LABEL[boost]}")
    fi
    
    [[ ${#labels[@]} -eq 0 ]] && print_info "Pakete: Keine" || print_info "Pakete: ${labels[*]}"
    [[ ${#SELECTED_FEATURE_LABELS[@]} -eq 0 ]] && print_info "Features: Keine" || print_info "Features: ${SELECTED_FEATURE_LABELS[*]}"
    
    if [[ -d ".git" ]]; then
        local gh
        gh=$(git rev-parse --short HEAD 2>/dev/null)
        [[ -n "$gh" ]] && print_info "Git: Initialisiert ($gh)" || print_info "Git: Initialisiert"
    else
        print_info "Git: Nicht initialisiert"
    fi
}

start_development_server() {
    print_step "Installation abgeschlossen!"
    echo
    print_success "Projekt erfolgreich erstellt!"
    echo
    print_info "Projekt: $PROJECT_NAME"
    print_info "Pfad: $(pwd)"
    print_info "Datenbank: ${DATABASE_LABEL[$DATABASE_TYPE]}"
    print_info "Laravel: $(php artisan --version 2>/dev/null || echo 'unbekannt')"
    [[ "$INSTALL_FILAMENT" == "true" ]] && print_info "Admin: http://localhost:8000/admin"
    echo
    print_info "Befehle:"
    print_info "  composer run dev     - Server starten"
    print_info "  php artisan serve    - Laravel Server"
    [[ "$INSTALL_PEST" == "true" ]] && print_info "  ./vendor/bin/pest    - Tests"
    [[ "$INSTALL_FILAMENT" == "true" ]] && print_info "  php artisan make:filament-resource Name"
    echo
    
    read -r -p "Server jetzt starten? (J/n): " -n 1 || true
    echo
    if [[ "$REPLY" =~ ^[Nn]$ ]]; then
        print_info "Starten Sie manuell mit: composer run dev"
    else
        print_info "Starte Server unter http://localhost:8000"
        print_info "STRG+C zum Stoppen"
        echo
        composer run dev
    fi
}

#================================================================================
# HAUPTFUNKTION
#================================================================================

main() {
    clear
    print_logo
    print_header "Laravel + Filament Installationsskript v${SCRIPT_VERSION}"
    print_info "Erstellt ein vollständiges Laravel-Projekt mit modernem Stack"
    
    ask_project_name
    ask_installation_mode
    
    if [[ "$INSTALLATION_MODE" == "manual" ]]; then
        manual_installation
    else
        print_success "Automatische Installation"
        ENABLE_GIT=true
        print_info "Git wird automatisch initialisiert"
    fi
    
    print_info "Projekt: $PROJECT_NAME | DB: $DATABASE_TYPE | Modus: $INSTALLATION_MODE"
    
    # Installation mit Fortschrittsanzeige
    local total_steps=14
    local current_step=0
    
    ((++current_step))
    check_prerequisites
    show_progress "$current_step" "$total_steps" "Systemvoraussetzungen OK"
    
    ((++current_step))
    install_or_update_laravel_installer
    show_progress "$current_step" "$total_steps" "Laravel Installer bereit"
    
    ((++current_step))
    create_laravel_project
    show_progress "$current_step" "$total_steps" "Projekt erstellt"
    
    ((++current_step))
    install_extra_packages
    show_progress "$current_step" "$total_steps" "Pakete installiert"
    
    ((++current_step))
    install_features
    show_progress "$current_step" "$total_steps" "Features eingerichtet"
    
    ((++current_step))
    install_filament
    show_progress "$current_step" "$total_steps" "Filament installiert"
    
    ((++current_step))
    install_livewire
    show_progress "$current_step" "$total_steps" "Livewire installiert"
    
    ((++current_step))
    setup_database
    show_progress "$current_step" "$total_steps" "Datenbank bereit"
    
    ((++current_step))
    run_migrations
    show_progress "$current_step" "$total_steps" "Migrationen abgeschlossen"
    
    ((++current_step))
    create_admin_user
    show_progress "$current_step" "$total_steps" "Admin erstellt"
    
    ((++current_step))
    configure_laravel_boost
    show_progress "$current_step" "$total_steps" "Boost konfiguriert"
    
    ((++current_step))
    build_frontend
    show_progress "$current_step" "$total_steps" "Frontend gebaut"
    
    ((++current_step))
    setup_git_repository
    set_permissions
    optimize_application
    show_progress "$current_step" "$total_steps" "Optimierung abgeschlossen"
    
    ((++current_step))
    sanity_report
    show_progress "$current_step" "$total_steps" "Installation komplett"
    
    start_development_server
}

#================================================================================
# SKRIPT STARTEN
#================================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
