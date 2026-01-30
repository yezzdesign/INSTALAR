#!/bin/bash
#================================================================================
# Laravel + Filament 5.1 Installationsskript
# Erstellt ein vollständiges Laravel-Projekt mit modernem Stack
# Projektname: INSTALAR
# Datenbank: SQLite
# Packages: Full Stack (Filament + Livewire + Pest + alle empfohlenen Packages)
# Author: yezz.design <design@schodie.de>
# AI-Disclaimer: AI used for formatting, comments and planning
#================================================================================

# Skript-Konfiguration
set -e  # Bei Fehlern sofort beenden
PROJECT_NAME="Laravel-2026"
DATABASE_TYPE="sqlite"
USE_DEV_VERSION=false
JETSTREAM_STACK="livewire"

# Installationsmodus und Paketauswahl-Variablen
INSTALLATION_MODE="automatic"
INSTALL_FILAMENT=true
INSTALL_LIVEWIRE=true
INSTALL_PEST=true
INSTALL_BOOST=true
FILAMENT_VERSION="^5.1"
LIVEWIRE_VERSION="^4.1"
PEST_VERSION="^2.0"
BOOST_VERSION=""
ENABLE_GIT=false
GIT_INITIAL_COMMIT_MESSAGE="Initial commit"
EXTRA_PACKAGES=()
EXTRA_DEV_PACKAGES=()
SELECTED_PACKAGE_IDS=()
SELECTED_PACKAGE_LABELS=()
SELECTED_FEATURE_IDS=()
SELECTED_FEATURE_LABELS=()

PACKAGE_KEYS=(
    filament
    livewire
    pest
    boost
    fortify
    sanctum
    passport
    socialite
    permission
    scout
    horizon
    telescope
    health
    backup
    activitylog
    settings
    medialibrary
    csp
    honeypot
    excel
    sentry
    debugbar
    pint
    larastan
    ide-helper
)

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

declare -A PACKAGE_DEV=(
    [pest]=true
    [telescope]=true
    [debugbar]=true
    [pint]=true
    [larastan]=true
    [ide-helper]=true
)

declare -A PACKAGE_DEFAULT=(
    [filament]=true
    [livewire]=true
    [pest]=true
    [boost]=true
    [debugbar]=true
)

FEATURE_KEYS=(
    breeze
    jetstream
    redis
    scout-meilisearch
    horizon
)

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

declare -A FEATURE_DEV=(
    [breeze]=true
    [jetstream]=true
)

declare -A FEATURE_DEFAULT=()

# Farbdefinitionen für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Hilfsfunktionen für formatierte Ausgabe
print_header() {
    echo -e "\n${BLUE}================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================================${NC}"
}

print_logo() {
    cat <<'EOF'
  ___           _        _
 |_ _|_ __  ___| |_ __ _| | __ _ _ __
  | || '_ \/ __| __/ _` | |/ _` | '__|
  | || | | \__ \ || (_| | | (_| | |
 |___|_| |_|___/\__\__,_|_|\__,_|_|

 [ Laravel + Filament Install Script ]
EOF
    echo
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_step() {
    echo -e "\n${PURPLE}► $1${NC}"
}

# Einzigartige Elemente zu Arrays hinzufügen
append_unique() {
    local -n array_ref=$1
    local value=$2
    local existing
    for existing in "${array_ref[@]}"; do
        if [ "$existing" = "$value" ]; then
            return
        fi
    done
    array_ref+=("$value")
}

# Fortschrittsbalken Funktion
progress_bar() {
    local duration=$1
    local steps=20
    local interval=$((duration / steps))
    
    echo -ne "${BLUE}["
    for i in $(seq 1 $steps); do
        echo -ne "="
        sleep $interval
    done
    echo -e "]${NC}"
}

# Fehlerbehandlungs-Funktion
handle_error() {
    print_error "Installation fehlgeschlagen bei Schritt: $1"
    print_info "Debug-Informationen werden gespeichert..."
    echo "$(date): Fehler bei $1" >> installation_errors.log
    exit 1
}

# Projektnamen abfragen
ask_project_name() {
    print_step "Projektnamen festlegen"

    # Default-Projektnamen anzeigen und abfragen
    echo -e "${CYAN}Bitte geben Sie den Namen für Ihr Laravel-Projekt ein:${NC}"
    read -p "Projektname (Standard: $PROJECT_NAME): " -r INPUT_PROJECT_NAME
    
    # Eingabe validieren und verwenden
    if [ -n "$INPUT_PROJECT_NAME" ]; then
        # Überprüfen ob der Name gültig ist (keine Sonderzeichen, keine Leerzeichen)
        if [[ "$INPUT_PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            PROJECT_NAME="$INPUT_PROJECT_NAME"
            print_success "Projektname wurde festgelegt auf: $PROJECT_NAME"
        else
            print_error "Ungültiger Projektname! Nur Buchstaben, Zahlen, Unterstrich und Bindestrich sind erlaubt."
            print_info "Verwende Standard-Projektnamen: $PROJECT_NAME"
            sleep 2
        fi
    else
        print_success "Verwende Standard-Projektnamen: $PROJECT_NAME"
    fi
    
    echo
}

# Installationsmodus abfragen
ask_installation_mode() {
    print_step "Installationsmodus auswählen"
    
    echo -e "${CYAN}Möchten Sie die Installation automatisch oder manuell durchführen?${NC}"
    echo "1) Automatisch (empfohlen) - Installiert alle empfohlenen Pakete mit Standard-Versionen"
    echo "2) Manuell - Wählen Sie einzelne Pakete und Versionen"
    
    while true; do
        read -p "Wählen Sie eine Option (1-2, Standard: 1): " -r MODE_CHOICE
        case $MODE_CHOICE in
            1|"" )
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
                print_error "Ungültige Auswahl! Bitte wählen Sie 1 oder 2."
                ;;
        esac
    done
    echo
}

# Git Setup abfragen (nur manueller Modus)
ask_git_setup() {
    print_step "Git Setup"

    echo -e "${CYAN}Möchten Sie ein Git-Repository initialisieren?${NC}"
    read -p "Git initialisieren? (J/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_GIT=false
        print_info "Git Setup wird übersprungen"
    else
        ENABLE_GIT=true
        print_success "Git Setup aktiviert"
    fi
    echo
}

# Mehrfachauswahl für Pakete
ask_package_selection() {
    print_step "Pakete auswählen"

    echo -e "${CYAN}Navigation: Pfeil hoch/runter, Leertaste zum Auswählen, Enter zum Bestätigen.${NC}"
    echo "a = alle | 0 = keine"
    echo

    local -a keys=("${PACKAGE_KEYS[@]}")
    local -a selected=()
    local index=0
    local i

    for i in "${!keys[@]}"; do
        local key="${keys[$i]}"
        if [ "${PACKAGE_DEFAULT[$key]}" = true ]; then
            selected[$i]=1
        else
            selected[$i]=0
        fi
    done

    local list_lines=${#keys[@]}
    local use_tput=false
    if command -v tput >/dev/null 2>&1; then
        use_tput=true
        tput civis 2>/dev/null || true
        trap 'tput cnorm 2>/dev/null' EXIT
    fi

    local input
    while true; do
        for i in "${!keys[@]}"; do
            local key="${keys[$i]}"
            local label="${PACKAGE_LABEL[$key]}"
            local dev_tag=""
            local default_tag=""
            local mark="[ ]"
            local prefix="  "
            if [ "${selected[$i]}" -eq 1 ]; then
                mark="[x]"
            fi
            if [ "$i" -eq "$index" ]; then
                prefix="> "
            fi
            if [ "${PACKAGE_DEV[$key]}" = true ]; then
                dev_tag=" [dev]"
            fi
            if [ "${PACKAGE_DEFAULT[$key]}" = true ]; then
                default_tag=" *"
            fi
            printf "\033[2K\r%s%s %s%s%s\n" "$prefix" "$mark" "$label" "$dev_tag" "$default_tag"
        done

        IFS= read -rsn1 input || true
        case "$input" in
            $'\x1b')
                IFS= read -rsn2 -t 0.1 input || true
                case "$input" in
                    '[A')
                        if [ "$index" -gt 0 ]; then
                            index=$((index - 1))
                        else
                            index=$((list_lines - 1))
                        fi
                        ;;
                    '[B')
                        if [ "$index" -lt $((list_lines - 1)) ]; then
                            index=$((index + 1))
                        else
                            index=0
                        fi
                        ;;
                esac
                ;;
            ' ')
                if [ "${selected[$index]}" -eq 1 ]; then
                    selected[$index]=0
                else
                    selected[$index]=1
                fi
                ;;
            'a'|'A')
                for i in "${!selected[@]}"; do
                    selected[$i]=1
                done
                ;;
            '0')
                for i in "${!selected[@]}"; do
                    selected[$i]=0
                done
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

    INSTALL_FILAMENT=false
    INSTALL_LIVEWIRE=false
    INSTALL_PEST=false
    INSTALL_BOOST=false
    EXTRA_PACKAGES=()
    EXTRA_DEV_PACKAGES=()
    SELECTED_PACKAGE_IDS=()
    SELECTED_PACKAGE_LABELS=()

    for i in "${!keys[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            local key="${keys[$i]}"
            SELECTED_PACKAGE_IDS+=("$key")
            SELECTED_PACKAGE_LABELS+=("${PACKAGE_LABEL[$key]}")
            case "$key" in
                filament)
                    INSTALL_FILAMENT=true
                    ;;
                livewire)
                    INSTALL_LIVEWIRE=true
                    ;;
                pest)
                    INSTALL_PEST=true
                    ;;
                boost)
                    INSTALL_BOOST=true
                    ;;
                *)
                    local pkg="${PACKAGE_COMPOSER[$key]}"
                    if [ "${PACKAGE_DEV[$key]}" = true ]; then
                        EXTRA_DEV_PACKAGES+=("$pkg")
                    else
                        EXTRA_PACKAGES+=("$pkg")
                    fi
                    ;;
            esac
        fi
    done

    print_success "Paketauswahl gespeichert"
    echo
}

# Mehrfachauswahl für Features
ask_feature_selection() {
    print_step "Features auswählen"

    echo -e "${CYAN}Navigation: Pfeil hoch/runter, Leertaste zum Auswählen, Enter zum Bestätigen.${NC}"
    echo "a = alle | 0 = keine"
    echo

    local -a keys=("${FEATURE_KEYS[@]}")
    local -a selected=()
    local index=0
    local i

    for i in "${!keys[@]}"; do
        local key="${keys[$i]}"
        if [ "${FEATURE_DEFAULT[$key]}" = true ]; then
            selected[$i]=1
        else
            selected[$i]=0
        fi
    done

    local list_lines=${#keys[@]}
    local use_tput=false
    if command -v tput >/dev/null 2>&1; then
        use_tput=true
        tput civis 2>/dev/null || true
        trap 'tput cnorm 2>/dev/null' EXIT
    fi

    local input
    while true; do
        for i in "${!keys[@]}"; do
            local key="${keys[$i]}"
            local label="${FEATURE_LABEL[$key]}"
            local dev_tag=""
            local default_tag=""
            local mark="[ ]"
            local prefix="  "
            if [ "${selected[$i]}" -eq 1 ]; then
                mark="[x]"
            fi
            if [ "$i" -eq "$index" ]; then
                prefix="> "
            fi
            if [ "${FEATURE_DEV[$key]}" = true ]; then
                dev_tag=" [dev]"
            fi
            if [ "${FEATURE_DEFAULT[$key]}" = true ]; then
                default_tag=" *"
            fi
            printf "\033[2K\r%s%s %s%s%s\n" "$prefix" "$mark" "$label" "$dev_tag" "$default_tag"
        done

        IFS= read -rsn1 input || true
        case "$input" in
            $'\x1b')
                IFS= read -rsn2 -t 0.1 input || true
                case "$input" in
                    '[A')
                        if [ "$index" -gt 0 ]; then
                            index=$((index - 1))
                        else
                            index=$((list_lines - 1))
                        fi
                        ;;
                    '[B')
                        if [ "$index" -lt $((list_lines - 1)) ]; then
                            index=$((index + 1))
                        else
                            index=0
                        fi
                        ;;
                esac
                ;;
            ' ')
                if [ "${selected[$index]}" -eq 1 ]; then
                    selected[$index]=0
                else
                    selected[$index]=1
                fi
                ;;
            'a'|'A')
                for i in "${!selected[@]}"; do
                    selected[$i]=1
                done
                ;;
            '0')
                for i in "${!selected[@]}"; do
                    selected[$i]=0
                done
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

    local breeze_index=-1
    local jetstream_index=-1
    for i in "${!keys[@]}"; do
        if [ "${keys[$i]}" = "breeze" ]; then
            breeze_index=$i
        elif [ "${keys[$i]}" = "jetstream" ]; then
            jetstream_index=$i
        fi
    done
    if [ "$breeze_index" -ge 0 ] && [ "$jetstream_index" -ge 0 ]; then
        if [ "${selected[$breeze_index]}" -eq 1 ] && [ "${selected[$jetstream_index]}" -eq 1 ]; then
            print_warning "Breeze und Jetstream wurden ausgewählt. Jetstream hat Vorrang."
            selected[$breeze_index]=0
        fi
    fi

    JETSTREAM_STACK="livewire"
    if [ "$jetstream_index" -ge 0 ] && [ "${selected[$jetstream_index]}" -eq 1 ]; then
        if [ "$INSTALL_FILAMENT" = true ] || [ "$INSTALL_LIVEWIRE" = true ]; then
            JETSTREAM_STACK="inertia"
            print_warning "Jetstream Livewire-Stack ist mit Filament/Livewire 4 inkompatibel. Verwende Inertia."
        fi
    fi

    SELECTED_FEATURE_IDS=()
    SELECTED_FEATURE_LABELS=()

    for i in "${!keys[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            local key="${keys[$i]}"
            SELECTED_FEATURE_IDS+=("$key")
            SELECTED_FEATURE_LABELS+=("${FEATURE_LABEL[$key]}")
            local pkgs="${FEATURE_COMPOSER[$key]}"
            local pkg
            for pkg in $pkgs; do
                if [ "${FEATURE_DEV[$key]}" = true ]; then
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

# Manuelle Paketauswahl
manual_installation() {
    print_step "Manuelle Paketauswahl und Konfiguration"

    print_step "Laravel Version auswählen"
    echo -e "${CYAN}Möchten Sie die Development-Version (master) nutzen?${NC}"
    read -p "Dev-Version nutzen? (j/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        USE_DEV_VERSION=true
        print_warning "Master-Version ist NICHT SAFE"
    else
        USE_DEV_VERSION=false
        print_success "Stable Version (latest) ausgewählt"
    fi
    echo
    
    ask_package_selection
    ask_feature_selection
    ask_git_setup

    # Zusammenfassung der Auswahl
    print_step "Zusammenfassung Ihrer Auswahl:"
    echo -e "${CYAN}Installationsmodus:${NC} Manuell"
    if [ "$USE_DEV_VERSION" = true ]; then
        echo -e "${CYAN}Laravel Version:${NC} master (NICHT SAFE)"
    else
        echo -e "${CYAN}Laravel Version:${NC} latest"
    fi
    if [ "${#SELECTED_PACKAGE_LABELS[@]}" -eq 0 ]; then
        echo -e "${CYAN}Pakete:${NC} Keine"
    else
        local IFS=', '
        echo -e "${CYAN}Pakete:${NC} ${SELECTED_PACKAGE_LABELS[*]}"
    fi
    if [ "${#SELECTED_FEATURE_LABELS[@]}" -eq 0 ]; then
        echo -e "${CYAN}Features:${NC} Keine"
    else
        local IFS=', '
        echo -e "${CYAN}Features:${NC} ${SELECTED_FEATURE_LABELS[*]}"
    fi
    echo -e "${CYAN}Git:${NC} $([ "$ENABLE_GIT" = true ] && echo "Ja" || echo "Nein")"
    echo
    
    read -p "Möchten Sie mit dieser Konfiguration fortfahren? (J/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Installation wird abgebrochen."
        exit 0
    fi
    
    print_success "Konfiguration bestätigt"
    echo
}

# PHP-Version auswählen
ask_php_version() {
    print_step "PHP-Version auswählen"
    
    echo -e "${CYAN}Welche PHP-Version möchten Sie installieren?${NC}"
    echo "1) PHP 8.3 (stabile Version)"
    echo "2) PHP 8.4 (stabile Version)"
    echo "3) PHP 8.5 (neueste stabile Version) *empfohlen"
    
    while true; do
        read -p "Wählen Sie eine Option (1-3, Standard: 2): " -r PHP_CHOICE
        case $PHP_CHOICE in
            1)
                PHP_VERSION="8.3"
                PHP_INSTALL_URL="https://php.new/install/linux/8.3"
                print_success "PHP 8.3 ausgewählt"
                break
                ;;
            2|"" )
                PHP_VERSION="8.4"
                PHP_INSTALL_URL="https://php.new/install/linux/8.4"
                print_success "PHP 8.4 ausgewählt"
                break
                ;;
            3)
                PHP_VERSION="8.5"
                PHP_INSTALL_URL="https://php.new/install/linux/8.5"
                print_success "PHP 8.5 ausgewählt"
                break
                ;;
            *)
                print_error "Ungültige Auswahl! Bitte wählen Sie 1, 2 oder 3."
                ;;
        esac
    done
    echo
}

# Systemvoraussetzungen prüfen
check_prerequisites() {
    print_step "Systemvoraussetzungen werden überprüft..."

    if [ ! -w "." ]; then
        print_error "Kein Schreibzugriff im aktuellen Verzeichnis: $(pwd)"
        exit 1
    fi
    print_success "Schreibzugriff im Projektverzeichnis vorhanden"
    
    # PHP-Version prüfen (>= 8.1 erforderlich)
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -r "echo PHP_VERSION;")
        PHP_MAJOR=$(echo $PHP_VERSION | cut -d. -f1)
        PHP_MINOR=$(echo $PHP_VERSION | cut -d. -f2)
        
        if [ "$PHP_MAJOR" -ge 8 ] && [ "$PHP_MINOR" -ge 1 ]; then
            print_success "PHP Version $PHP_VERSION gefunden (Minimum: 8.1)"
        else
            print_error "PHP Version $PHP_VERSION ist zu alt. Minimum PHP 8.1 erforderlich."
            exit 1
        fi
    else
        print_error "PHP wurde nicht gefunden."
        ask_php_version
        print_info "Installiere PHP $PHP_VERSION..."
        /bin/bash -c "$(curl -fsSL $PHP_INSTALL_URL)"
        
        # Nach der Installation prüfen ob PHP verfügbar ist
        if command -v php &> /dev/null; then
            PHP_VERSION=$(php -r "echo PHP_VERSION;")
            print_success "PHP Version $PHP_VERSION wurde installiert"
        else
            print_error "PHP Installation fehlgeschlagen. Bitte installieren Sie manuell PHP 8.1 oder höher."
            exit 1
        fi
    fi
    
    # Composer prüfen
    if command -v composer &> /dev/null; then
        COMPOSER_VERSION=$(composer --version | cut -d' ' -f3)
        print_success "Composer Version $COMPOSER_VERSION gefunden"
        COMPOSER_MAJOR=${COMPOSER_VERSION%%.*}
        if [ "$COMPOSER_MAJOR" -lt 2 ]; then
            print_warning "Composer 2.x wird empfohlen"
        fi
    else
        print_error "Composer wurde nicht gefunden. Bitte installieren Sie Composer."
        exit 1
    fi
    
    # Node.js prüfen
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js Version $NODE_VERSION gefunden"
        NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/^v//' | cut -d. -f1)
        if [ "$NODE_MAJOR" -lt 18 ]; then
            print_warning "Node.js 18+ wird empfohlen"
        fi
    else
        print_error "Node.js wurde nicht gefunden. Bitte installieren Sie Node.js."
        exit 1
    fi
    
    # NPM prüfen
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "NPM Version $NPM_VERSION gefunden"
        NPM_MAJOR=${NPM_VERSION%%.*}
        if [ "$NPM_MAJOR" -lt 9 ]; then
            print_warning "NPM 9+ wird empfohlen"
        fi
    else
        print_error "NPM wurde nicht gefunden. Bitte installieren Sie NPM."
        exit 1
    fi

    if command -v curl &> /dev/null; then
        CURL_VERSION=$(curl --version | head -n 1 | awk '{print $2}')
        print_success "curl $CURL_VERSION gefunden"
    else
        print_error "curl wurde nicht gefunden. Bitte installieren Sie curl."
        exit 1
    fi

    if command -v unzip &> /dev/null; then
        print_success "unzip gefunden"
    else
        print_warning "unzip wurde nicht gefunden (kann Composer beeinträchtigen)"
    fi

    if [ "$ENABLE_GIT" = true ]; then
        if command -v git &> /dev/null; then
            GIT_VERSION=$(git --version | awk '{print $3}')
            print_success "Git Version $GIT_VERSION gefunden"
        else
            print_error "Git wurde nicht gefunden, ist aber aktiviert."
            exit 1
        fi
    fi
    
    # PHP-Erweiterungen prüfen
    print_info "Überprüfe PHP-Erweiterungen..."
    REQUIRED_EXTENSIONS=("mbstring" "xml" "ctype" "iconv" "intl" "pdo" "tokenizer" "bcmath" "json" "fileinfo" "pdo_sqlite" "openssl" "zip")
    
    for ext in "${REQUIRED_EXTENSIONS[@]}"; do
        if php -m | grep -q "$ext"; then
            print_success "PHP-Erweiterung '$ext' ist verfügbar"
        else
            print_warning "PHP-Erweiterung '$ext' fehlt - könnte Probleme verursachen"
        fi
    done
}

# Laravel Installer installieren/aktualisieren
install_laravel_installer() {
    print_step "Laravel Installer wird installiert/aktualisiert..."
    
    # Prüfen ob Laravel Installer bereits existiert
    if command -v laravel &> /dev/null; then
        print_info "Laravel Installer gefunden, wird aktualisiert..."
        composer global update laravel/installer || handle_error "Laravel Installer Update"
        print_success "Laravel Installer aktualisiert"
    else
        print_info "Laravel Installer wird installiert..."
        composer global require laravel/installer || handle_error "Laravel Installer Installation"
        print_success "Laravel Installer installiert"
        
        # Sicherstellen dass ~/.composer/vendor/bin im PATH ist
        if ! echo $PATH | grep -q "$HOME/.composer/vendor/bin"; then
            print_warning "Füge ~/.composer/vendor/bin zum PATH hinzu..."
            echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
            export PATH="$HOME/.composer/vendor/bin:$PATH"
        fi
    fi
}

# Neues Laravel-Projekt erstellen
create_laravel_project() {
    print_step "Laravel-Projekt '$PROJECT_NAME' wird erstellt..."

    local project_dir="$PROJECT_NAME"
    local project_dir_lower
    local project_dir_slug
    project_dir_lower=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
    project_dir_slug=$(printf '%s' "$project_dir_lower" | tr '_' '-')
    
    # Prüfen ob Projekt bereits existiert
    if [ -d "$project_dir" ] || [ -d "$project_dir_lower" ] || [ -d "$project_dir_slug" ]; then
        local existing_dir="$project_dir"
        if [ -d "$project_dir_lower" ]; then
            existing_dir="$project_dir_lower"
        elif [ -d "$project_dir_slug" ]; then
            existing_dir="$project_dir_slug"
        fi
        print_error "Verzeichnis '$existing_dir' existiert bereits!"
        read -p "Möchten Sie es löschen und neu erstellen? (j/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Jj]$ ]]; then
            rm -rf "$existing_dir"
            print_success "Existierendes Projekt gelöscht"
        else
            print_error "Installation abgebrochen"
            exit 1
        fi
    fi
    
    # Laravel-Projekt erstellen mit bedingten Parametern
    print_info "Erstelle Laravel-Projekt mit Installer..."
    local laravel_log
    laravel_log=$(mktemp /tmp/laravel_new.XXXXXX.log)
    
    # Flags für laravel new Befehl basierend auf Auswahl zusammenbauen
    LARAVEL_FLAGS="--npm --no-interaction"
    
    if [ "$INSTALL_PEST" = true ] || [ "$INSTALLATION_MODE" = "automatic" ]; then
        LARAVEL_FLAGS="$LARAVEL_FLAGS --pest"
    fi
    
    if [ "$INSTALL_BOOST" = true ] || [ "$INSTALLATION_MODE" = "automatic" ]; then
        LARAVEL_FLAGS="$LARAVEL_FLAGS --boost"
    fi

    if [ "$USE_DEV_VERSION" = true ]; then
        print_warning "Master-Version ist NICHT SAFE"
        LARAVEL_FLAGS="$LARAVEL_FLAGS --dev"
    fi
    
    echo -e "${CYAN}Laravel wird erstellt mit folgenden Flags: $LARAVEL_FLAGS${NC}"
    laravel new "$PROJECT_NAME" $LARAVEL_FLAGS 2>&1 | tee "$laravel_log"
    local laravel_status=${PIPESTATUS[0]}
    if [ "$laravel_status" -ne 0 ]; then
        tail -n 50 "$laravel_log" >> installation_errors.log
        handle_error "Laravel Projekt Erstellung"
    fi
    
    if [ -d "$project_dir" ]; then
        :
    elif [ -d "$project_dir_lower" ]; then
        print_warning "Projektverzeichnis wurde als '$project_dir_lower' erstellt"
        project_dir="$project_dir_lower"
    elif [ -d "$project_dir_slug" ]; then
        print_warning "Projektverzeichnis wurde als '$project_dir_slug' erstellt"
        project_dir="$project_dir_slug"
    else
        tail -n 50 "$laravel_log" >> installation_errors.log
        handle_error "Laravel Projekt Erstellung (Verzeichnis nicht gefunden)"
    fi
    rm -f "$laravel_log"
    
    print_success "Laravel-Projekt '$project_dir' erstellt"
    
    # In Projektverzeichnis wechseln
    cd "$project_dir"
    print_success "Wechsle in Projektverzeichnis: $(pwd)"
}

# Composer Dependencies installieren und aktualisieren
install_dependencies() {
    print_step "Composer Dependencies werden installiert..."

    if [ "$INSTALL_FILAMENT" = true ] && [ "$INSTALL_LIVEWIRE" != true ]; then
        INSTALL_LIVEWIRE=true
        print_info "Livewire wird für Filament benötigt und automatisch aktiviert"
    fi

    # Livewire installieren (falls ausgewählt)
    if [ "$INSTALL_LIVEWIRE" = true ]; then
        print_info "Installiere Livewire $LIVEWIRE_VERSION..."
        composer require livewire/livewire:"$LIVEWIRE_VERSION" --no-interaction || handle_error "Livewire Installation"
        print_success "Livewire installiert"
    else
        print_info "Livewire wird übersprungen (nicht ausgewählt)"
    fi

    # Filament installieren (falls ausgewählt)
    if [ "$INSTALL_FILAMENT" = true ]; then
        print_info "Installiere Filament $FILAMENT_VERSION..."
        composer require filament/filament:"$FILAMENT_VERSION" --no-interaction || handle_error "Filament Installation"
        print_success "Filament installiert"
    else
        print_info "Filament wird übersprungen (nicht ausgewählt)"
    fi
    
    # Zusätzliche Laravel Packages installieren
    if [ "${#EXTRA_PACKAGES[@]}" -gt 0 ]; then
        print_info "Installiere zusätzliche Laravel-Packages..."
        composer require "${EXTRA_PACKAGES[@]}" --no-interaction || handle_error "Additional Packages Installation"
        print_success "Zusätzliche Packages installiert"
    else
        print_info "Keine zusätzlichen Laravel-Packages ausgewählt"
    fi
    
    # Development Packages installieren
    if [ "${#EXTRA_DEV_PACKAGES[@]}" -gt 0 ]; then
        print_info "Installiere Development Packages..."
        composer require --dev "${EXTRA_DEV_PACKAGES[@]}" --no-interaction || handle_error "Development Packages Installation"
        print_success "Development Packages installiert"
    else
        print_info "Keine Development Packages ausgewählt"
    fi
    
    print_success "Alle Dependencies installiert"
}

# Features installieren und konfigurieren
install_features() {
    if [ "${#SELECTED_FEATURE_IDS[@]}" -eq 0 ]; then
        print_info "Keine Features ausgewählt"
        return
    fi

    print_step "Features werden eingerichtet..."

    local key
    for key in "${SELECTED_FEATURE_IDS[@]}"; do
        case "$key" in
            breeze)
                print_info "Installiere Laravel Breeze..."
                php artisan breeze:install --stack=blade --no-interaction || handle_error "Breeze Installation"
                print_success "Laravel Breeze installiert"
                ;;
            jetstream)
                print_info "Installiere Laravel Jetstream..."
                php artisan jetstream:install "$JETSTREAM_STACK" --no-interaction || handle_error "Jetstream Installation"
                print_success "Laravel Jetstream installiert"
                ;;
            redis)
                print_info "Redis Support hinzugefügt (predis)"
                ;;
            scout-meilisearch)
                print_info "Scout Konfiguration wird veröffentlicht..."
                if php artisan vendor:publish --provider="Laravel\\Scout\\ScoutServiceProvider" --force >/dev/null 2>&1; then
                    print_success "Scout Konfiguration veröffentlicht"
                else
                    print_warning "Scout Konfiguration konnte nicht veröffentlicht werden"
                fi
                ;;
            horizon)
                print_info "Installiere Horizon Setup..."
                php artisan horizon:install || handle_error "Horizon Installation"
                print_success "Horizon konfiguriert"
                ;;
            *)
                print_warning "Unbekanntes Feature: $key"
                ;;
        esac
    done
}

# Filament installieren und konfigurieren
install_filament() {
    if [ "$INSTALL_FILAMENT" = true ]; then
        print_step "Filament wird installiert und konfiguriert..."
        
        # Filament Panel installieren
        php artisan filament:install --panels --no-interaction || handle_error "Filament Panel Installation"
        print_success "Filament Panel installiert"
        
        # Filament Konfiguration veröffentlichen
        php artisan vendor:publish --tag=filament-config --force || handle_error "Filament Konfiguration"
        print_success "Filament Konfiguration veröffentlicht"
    else
        print_info "Filament Installation übersprungen (nicht ausgewählt)"
    fi
}

# Livewire installieren und konfigurieren
install_livewire() {
    if [ "$INSTALL_LIVEWIRE" = true ]; then
        print_step "Livewire wird installiert und konfiguriert..."
        
        # Livewire publish
        php artisan livewire:publish --config || handle_error "Livewire Konfiguration"
        print_success "Livewire konfiguriert"
    else
        print_info "Livewire Installation übersprungen (nicht ausgewählt)"
    fi
}

# Frontend-Abhängigkeiten prüfen und anpassen
fix_frontend_dependencies() {
    print_step "Frontend-Abhängigkeiten prüfen"

    if [ ! -f "package.json" ]; then
        print_info "package.json nicht gefunden"
        return
    fi
    if ! command -v node &> /dev/null; then
        print_warning "Node.js nicht gefunden, überspringe Frontend-Check"
        return
    fi

    local result
    result=$(node - <<'NODE'
const fs = require('fs');
const path = 'package.json';

const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
const deps = pkg.dependencies || {};
const dev = pkg.devDependencies || {};

const viteKey = dev.vite ? 'dev' : (deps.vite ? 'prod' : null);
const pluginVue = dev['@vitejs/plugin-vue'] || deps['@vitejs/plugin-vue'];

if (!viteKey || !pluginVue) {
  console.log('skip');
  process.exit(0);
}

const viteVersion = viteKey === 'dev' ? dev.vite : deps.vite;
const viteMajor = parseInt((String(viteVersion).match(/(\d+)/) || [])[1], 10);
const pluginMajor = parseInt((String(pluginVue).match(/(\d+)/) || [])[1], 10);

let changed = false;
if (!Number.isNaN(viteMajor) && !Number.isNaN(pluginMajor)) {
  if (viteMajor >= 7 && pluginMajor <= 5) {
    if (dev['@vitejs/plugin-vue']) {
      dev['@vitejs/plugin-vue'] = '^6.0.0';
    } else {
      deps['@vitejs/plugin-vue'] = '^6.0.0';
    }
    changed = true;
  }
}

if (changed) {
  pkg.dependencies = deps;
  pkg.devDependencies = dev;
  fs.writeFileSync(path, JSON.stringify(pkg, null, 4) + '\n');
  console.log('changed');
} else {
  console.log('ok');
}
NODE
)

    if [ "$result" = "changed" ]; then
        print_warning "@vitejs/plugin-vue auf ^6.0.0 angepasst (kompatibel mit Vite 7)"
    elif [ "$result" = "skip" ]; then
        print_info "Kein Vite/Vue Plugin gefunden, keine Anpassung nötig"
    else
        print_info "Frontend-Abhängigkeiten sind kompatibel"
    fi
}

# SQLite-Datenbank einrichten
setup_database() {
    print_step "SQLite-Datenbank wird eingerichtet..."
    
    # Datenbankverzeichnis erstellen falls nicht vorhanden
    if [ ! -d "database" ]; then
        mkdir -p database
    fi
    
    # SQLite-Datenbankdatei erstellen
    touch database/database.sqlite
    print_success "SQLite-Datenbankdatei erstellt"
    
    # .env Datei für SQLite konfigurieren
    if [ -f ".env" ]; then
        # Backup der originalen .env
        cp .env .env.backup
        
        # Datenbank-Konfiguration anpassen
        sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
        sed -i 's|# DB_DATABASE=.*|DB_DATABASE=database/database.sqlite|' .env
        sed -i 's/DB_HOST=.*/# DB_HOST=127.0.0.1/' .env
        sed -i 's/DB_PORT=.*/# DB_PORT=3306/' .env
        sed -i 's/DB_USERNAME=.*/# DB_USERNAME=root/' .env
        sed -i 's/DB_PASSWORD=.*/# DB_PASSWORD=/' .env
        
        print_success ".env Datei für SQLite konfiguriert"
    else
        print_error ".env Datei nicht gefunden!"
        handle_error "Datenbank Konfiguration"
    fi
    
    # Application Key generieren
    php artisan key:generate || handle_error "Application Key Generation"
    print_success "Application Key generiert"
}

# Migrationen durchführen
run_migrations() {
    print_step "Datenbank-Migrationen werden durchgeführt..."
    
    print_info "Führe initiale Migrationen durch..."
    php artisan migrate --force || handle_error "Migrationen"
    print_success "Migrationen erfolgreich durchgeführt"
}

# Filament Admin-User erstellen
create_admin_user() {
    if [ "$INSTALL_FILAMENT" = true ]; then
        print_step "Filament Admin-User wird erstellt..."
        local default_name="Admin User"
        local default_email="admin@example.com"
        local default_password="password"

        if [ "$INSTALLATION_MODE" = "manual" ]; then
            print_info "Bitte geben Sie die Admin-User-Daten ein:"
            read -p "Name (Standard: $default_name): " -r ADMIN_NAME
            if [ -z "$ADMIN_NAME" ]; then
                ADMIN_NAME="$default_name"
            fi

            read -p "Email (Standard: $default_email): " -r ADMIN_EMAIL
            if [ -z "$ADMIN_EMAIL" ]; then
                ADMIN_EMAIL="$default_email"
            fi

            read -p "Passwort (Standard: $default_password): " -s ADMIN_PASSWORD
            if [ -z "$ADMIN_PASSWORD" ]; then
                ADMIN_PASSWORD="$default_password"
            fi
            echo
        else
            ADMIN_NAME=${ADMIN_NAME:-"$default_name"}
            ADMIN_EMAIL=${ADMIN_EMAIL:-"$default_email"}
            ADMIN_PASSWORD=${ADMIN_PASSWORD:-"$default_password"}
        fi
        
        # User erstellen mit Filament
        php artisan make:filament-user \
            --name="$ADMIN_NAME" \
            --email="$ADMIN_EMAIL" \
            --password="$ADMIN_PASSWORD" || handle_error "Admin User Erstellung"
        
        print_success "Filament Admin-User erstellt"
        print_info "Login-Daten:"
        print_info "  Email: $ADMIN_EMAIL"
        print_info "  Passwort: $ADMIN_PASSWORD"
        print_info "  URL: http://localhost:8000/admin"
    else
        print_info "Admin-User Erstellung übersprungen (Filament nicht installiert)"
    fi
}

# Zusätzliche Laravel-Packages konfigurieren
configure_additional_packages() {
    print_step "Zusätzliche Laravel-Packages werden konfiguriert..."
    
    # Laravel Sanctum konfigurieren
    #php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force 2>/dev/null || true
    #print_success "Laravel Sanctum konfiguriert"
    
    # Laravel Fortify konfigurieren
    #php artisan vendor:publish --provider="Laravel\Fortify\FortifyServiceProvider" --force 2>/dev/null || true
    #print_success "Laravel Fortify konfiguriert"
    
    # Laravel Telescope (nur in development)
    #if [ "$APP_ENV" = "local" ] || [ -z "$APP_ENV" ]; then
    #    php artisan vendor:publish --provider="Laravel\Telescope\TelescopeServiceProvider" --force 2>/dev/null || true
    #    php artisan migrate 2>/dev/null || true
    #    print_success "Laravel Telescope konfiguriert"
    #fi

    # Laravel Boost konfigurieren (falls ausgewählt)
    if [ "$INSTALL_BOOST" = true ]; then
        print_info "Laravel Boost wird konfiguriert..."
        if php artisan boost:install 2>/dev/null; then
            print_success "Laravel Boost wurde konfiguriert"
        else
            print_warning "Laravel Boost Konfiguration fehlgeschlagen, möglicherweise bereits konfiguriert"
        fi
    else
        print_info "Laravel Boost wird übersprungen (nicht ausgewählt)"
    fi
    
    fix_frontend_dependencies

    # Frontend Assets bauen
    print_info "Frontend Assets werden gebaut..."
    npm install || handle_error "NPM Installation"
    npm run build || handle_error "Frontend Assets Build"
    print_success "Frontend Assets gebaut"
}

# Sanity Report ausgeben
sanity_report() {
    print_step "Sanity Report"

    local laravel_version="unbekannt"
    local php_version="unbekannt"
    local composer_version="unbekannt"
    local node_version="unbekannt"
    local npm_version="unbekannt"

    if command -v php &> /dev/null; then
        php_version=$(php -r "echo PHP_VERSION;" 2>/dev/null || echo "unbekannt")
    fi
    if command -v composer &> /dev/null; then
        composer_version=$(composer --version 2>/dev/null | awk '{print $3}')
    fi
    if command -v node &> /dev/null; then
        node_version=$(node --version 2>/dev/null)
    fi
    if command -v npm &> /dev/null; then
        npm_version=$(npm --version 2>/dev/null)
    fi
    if command -v php &> /dev/null && [ -f artisan ]; then
        laravel_version=$(php artisan --version 2>/dev/null || echo "unbekannt")
    fi

    print_info "Projekt: $PROJECT_NAME"
    print_info "Pfad: $(pwd)"
    print_info "Laravel: $laravel_version"
    print_info "PHP: $php_version | Composer: $composer_version"
    print_info "Node: $node_version | NPM: $npm_version"
    print_info "Installationsmodus: $INSTALLATION_MODE"

    if [ "$DATABASE_TYPE" = "sqlite" ]; then
        if [ -f "database/database.sqlite" ]; then
            print_success "SQLite Datenbank vorhanden"
        else
            print_warning "SQLite Datenbank fehlt"
        fi
    else
        print_info "Datenbank: $DATABASE_TYPE"
    fi

    if [ -w "storage" ]; then
        print_success "storage/ beschreibbar"
    else
        print_warning "storage/ nicht beschreibbar"
    fi

    if [ -w "bootstrap/cache" ]; then
        print_success "bootstrap/cache beschreibbar"
    else
        print_warning "bootstrap/cache nicht beschreibbar"
    fi

    local -a package_labels=()
    if [ "${#SELECTED_PACKAGE_LABELS[@]}" -gt 0 ]; then
        package_labels=("${SELECTED_PACKAGE_LABELS[@]}")
    else
        if [ "$INSTALL_FILAMENT" = true ]; then
            package_labels+=("${PACKAGE_LABEL[filament]}")
        fi
        if [ "$INSTALL_LIVEWIRE" = true ]; then
            package_labels+=("${PACKAGE_LABEL[livewire]}")
        fi
        if [ "$INSTALL_PEST" = true ]; then
            package_labels+=("${PACKAGE_LABEL[pest]}")
        fi
        if [ "$INSTALL_BOOST" = true ]; then
            package_labels+=("${PACKAGE_LABEL[boost]}")
        fi
    fi

    if [ "${#package_labels[@]}" -eq 0 ]; then
        print_info "Pakete: Keine"
    else
        local IFS=', '
        print_info "Pakete: ${package_labels[*]}"
    fi

    if [ "${#SELECTED_FEATURE_LABELS[@]}" -eq 0 ]; then
        print_info "Features: Keine"
    else
        local IFS=', '
        print_info "Features: ${SELECTED_FEATURE_LABELS[*]}"
    fi

    if [ -d ".git" ]; then
        local git_head
        git_head=$(git rev-parse --short HEAD 2>/dev/null || true)
        if [ -n "$git_head" ]; then
            print_info "Git: initialisiert ($git_head)"
        else
            print_info "Git: initialisiert"
        fi
    else
        print_info "Git: nicht initialisiert"
    fi
}

# Git Repository initialisieren
setup_git_repository() {
    if [ "$ENABLE_GIT" != true ]; then
        print_info "Git Setup übersprungen"
        return
    fi

    print_step "Git Repository wird initialisiert..."

    if [ -d ".git" ]; then
        print_warning "Git-Repository existiert bereits, überspringe Initialisierung"
        return
    fi

    git init >/dev/null 2>&1 || handle_error "Git Init"

    if ! git config user.name >/dev/null 2>&1; then
        local git_name="${GIT_USER_NAME:-${USER:-user}}"
        git config user.name "$git_name"
        print_info "Lokaler Git user.name gesetzt: $git_name"
    fi
    if ! git config user.email >/dev/null 2>&1; then
        local git_email="${GIT_USER_EMAIL:-${USER:-user}}@localhost"
        git config user.email "$git_email"
        print_info "Lokaler Git user.email gesetzt: $git_email"
    fi

    git add -A || handle_error "Git Add"
    if git diff --cached --quiet; then
        print_info "Keine Änderungen zum Commit vorhanden"
        return
    fi
    git commit -m "$GIT_INITIAL_COMMIT_MESSAGE" >/dev/null 2>&1 || handle_error "Git Commit"
    print_success "Git Repository initialisiert und Commit erstellt"
}

# Dateiberechtigungen setzen
set_permissions() {
    print_step "Dateiberechtigungen werden gesetzt..."
    
    # Standard-Laravel-Berechtigungen
    chmod -R 775 storage
    chmod -R 775 bootstrap/cache
    
    # Ownership setzen ( falls sudo verfügbar)
    if command -v sudo &> /dev/null; then
        sudo chown -R $USER:$USER storage bootstrap/cache 2>/dev/null || true
    fi
    
    print_success "Dateiberechtigungen gesetzt"
}

# Optimierung durchführen
optimize_application() {
    print_step "Anwendung wird optimiert..."
    
    # Cache leeren und neu aufbauen
    php artisan cache:clear || true
    php artisan config:clear || true
    php artisan route:clear || true
    php artisan view:clear || true
    
    # Cache für Produktion aufbauen
    php artisan config:cache || handle_error "Config Cache"
    php artisan route:cache || handle_error "Route Cache"
    php artisan view:cache || handle_error "View Cache"
    
    print_success "Anwendung optimiert"
}

# Entwicklungsserver starten
start_development_server() {
    print_step "Entwicklungsserver wird gestartet..."
    
    print_success "Installation abgeschlossen! 🎉"
    echo
    print_info "Projekt-Informationen:"
    print_info "  Projektname: $PROJECT_NAME"
    print_info "  Datenbank: SQLite"
    print_info "  Laravel: $(php artisan --version)"
    print_info "  Installationsmodus: $INSTALLATION_MODE"
    
    # Installierte Pakete anzeigen
    if [ "$INSTALL_FILAMENT" = true ]; then
        print_info "  Filament: installiert"
    fi
    if [ "$INSTALL_LIVEWIRE" = true ]; then
        print_info "  Livewire: installiert"
    fi
    if [ "$INSTALL_PEST" = true ]; then
        print_info "  Pest PHP: installiert"
    fi
    if [ "$INSTALL_BOOST" = true ]; then
        print_info "  Laravel Boost: installiert"
    fi
    echo
    
    print_info "Nächste Schritte:"
    print_info "  1. Entwicklungsserver starten: php artisan serve"
    if [ "$INSTALL_FILAMENT" = true ]; then
        print_info "  2. Admin-Panel öffnen: http://localhost:8000/admin"
        if [ "$INSTALL_PEST" = true ]; then
            print_info "  3. Tests ausführen: ./vendor/bin/pest"
            print_info "  4. Projekt optimieren: composer run dev"
        else
            print_info "  3. Projekt optimieren: composer run dev"
        fi
    elif [ "$INSTALL_PEST" = true ]; then
        print_info "  2. Tests ausführen: ./vendor/bin/pest"
        print_info "  3. Projekt optimieren: composer run dev"
    else
        print_info "  2. Projekt optimieren: composer run dev"
    fi
    echo
    
    print_info "Nützliche Befehle:"
    print_info "  • Neue Migration: php artisan make:migration create_table"
    print_info "  • Model erstellen: php artisan make:model ModelName"
    print_info "  • Controller erstellen: php artisan make:controller ControllerName"
    if [ "$INSTALL_FILAMENT" = true ]; then
        print_info "  • Filament Resource: php artisan make:filament-resource ResourceName"
    fi
    if [ "$INSTALL_PEST" = true ]; then
        print_info "  • Tests ausführen: ./vendor/bin/pest"
    fi
    echo
    
    # Frage ob Entwicklungsserver gestartet werden soll
    read -p "Möchten Sie den Entwicklungsserver jetzt starten? (J/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]] || [ -z "$REPLY" ]; then
        print_info "Starte Laravel Entwicklungsserver..."
        print_info "Server wird unter http://localhost:8000 laufen"
        print_info "Mit STRG+C stoppen"
        echo
        composer run dev
    else
        print_info "Starten Sie den Server manuell mit: composer run dev"
    fi
}

# Hauptfunktion
main() {
    clear
    print_logo
    print_header "Laravel + Filament 5.1 Installationsskript"
    print_info "Dieses Skript erstellt ein vollständiges Laravel-Projekt mit modernem Stack"
    
    # Projektnamen abfragen
    ask_project_name
    
    # Installationsmodus abfragen
    ask_installation_mode
    
    # Bei manueller Installation Paketauswahl durchführen
    if [ "$INSTALLATION_MODE" = "manual" ]; then
        manual_installation
    else
        print_success "Automatische Installation mit Standard-Paketen"
        ENABLE_GIT=true
        print_info "Git wird automatisch initialisiert"
    fi
    
    print_info "Projektname: $PROJECT_NAME | Datenbank: $DATABASE_TYPE | Modus: $INSTALLATION_MODE"
    
    # Installationsschritte durchführen
    check_prerequisites
    progress_bar 2
    
    install_laravel_installer
    progress_bar 1
    
    create_laravel_project
    progress_bar 3
    
    install_dependencies
    progress_bar 5

    install_features
    progress_bar 2
    
    install_filament
    install_livewire
    progress_bar 2
    
    setup_database
    progress_bar 2
    
    run_migrations
    progress_bar 1
    
    create_admin_user
    progress_bar 1
    
    configure_additional_packages
    progress_bar 4

    setup_git_repository
    
    set_permissions
    optimize_application
    progress_bar 2

    sanity_report
    
    start_development_server
}

# Skript starten
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
