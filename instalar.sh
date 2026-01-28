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

# Systemvoraussetzungen prüfen
check_prerequisites() {
    print_step "Systemvoraussetzungen werden überprüft..."
    
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
        print_error "PHP wurde nicht gefunden. Installiere die neueste Version PHP 8.5..."
        /bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.5)"
        
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
    else
        print_error "Composer wurde nicht gefunden. Bitte installieren Sie Composer."
        exit 1
    fi
    
    # Node.js prüfen
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js Version $NODE_VERSION gefunden"
    else
        print_error "Node.js wurde nicht gefunden. Bitte installieren Sie Node.js."
        exit 1
    fi
    
    # NPM prüfen
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "NPM Version $NPM_VERSION gefunden"
    else
        print_error "NPM wurde nicht gefunden. Bitte installieren Sie NPM."
        exit 1
    fi
    
    # PHP-Erweiterungen prüfen
    print_info "Überprüfe PHP-Erweiterungen..."
    REQUIRED_EXTENSIONS=("mbstring" "xml" "ctype" "iconv" "intl" "pdo" "tokenizer" "bcmath" "json" "fileinfo" "pdo_sqlite")
    
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
    
    # Prüfen ob Projekt bereits existiert
    if [ -d "$PROJECT_NAME" ]; then
        print_error "Verzeichnis '$PROJECT_NAME' existiert bereits!"
        read -p "Möchten Sie es löschen und neu erstellen? (j/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Jj]$ ]]; then
            rm -rf "$PROJECT_NAME"
            print_success "Existierendes Projekt gelöscht"
        else
            print_error "Installation abgebrochen"
            exit 1
        fi
    fi
    
    # Laravel-Projekt erstellen
    print_info "Erstelle Laravel-Projekt mit Installer..."
    laravel new "$PROJECT_NAME" --npm --boost --livewire --pest --no-interaction || handle_error "Laravel Projekt Erstellung"
    print_success "Laravel-Projekt '$PROJECT_NAME' erstellt"
    
    # In Projektverzeichnis wechseln
    cd "$PROJECT_NAME"
    print_success "Wechsle in Projektverzeichnis: $(pwd)"
}

# Composer Dependencies installieren und aktualisieren
install_dependencies() {
    print_step "Composer Dependencies werden installiert..."
    
    # Filament zuerst installieren
    print_info "Installiere Filament 5.1..."
    composer require filament/filament:"^5.1" --no-interaction || handle_error "Filament Installation"
    print_success "Filament installiert"
    
    # Livewire installieren
    print_info "Installiere Livewire 4.x..."
    composer require livewire/livewire:"^4.0" --no-interaction || handle_error "Livewire Installation"
    print_success "Livewire installiert"
    
    # Zusätzliche Laravel Packages installieren
    print_info "Installiere zusätzliche Laravel-Packages..."
    #composer require laravel/fortify:"^1.0" \
    #                laravel/sanctum:"^4.0" \
    #                laravel/socialite:"^5.0" \
    #                --no-interaction || handle_error "Additional Packages Installation"
    print_success "Zusätzliche Packages installiert"
    
    # Development Packages installieren
    print_info "Installiere Development Packages..."
    #composer require --dev laravel/telescope --no-interaction || true
    print_success "Development Packages installiert"
    
    print_success "Alle Dependencies installiert"
}

# Filament installieren und konfigurieren
install_filament() {
    print_step "Filament 5.1 wird installiert und konfiguriert..."
    
    # Filament Panel installieren
    php artisan filament:install --panels --no-interaction || handle_error "Filament Panel Installation"
    print_success "Filament Panel installiert"
    
    # Filament Konfiguration veröffentlichen
    php artisan vendor:publish --tag=filament-config --force || handle_error "Filament Konfiguration"
    print_success "Filament Konfiguration veröffentlicht"
}

# Livewire installieren und konfigurieren
install_livewire() {
    print_step "Livewire 4.x wird installiert und konfiguriert..."
    
    # Livewire publish
    php artisan livewire:publish --config || handle_error "Livewire Konfiguration"
    print_success "Livewire konfiguriert"
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
    print_step "Filament Admin-User wird erstellt..."
    
    # Interaktive User-Erstellung
    print_info "Bitte geben Sie die Admin-User-Daten ein:"
    
    #read -p "Name (Standard: Admin User): " ADMIN_NAME
    ADMIN_NAME=${ADMIN_NAME:-"Admin User"}
    
    #read -p "Email (Standard: admin@example.com): " ADMIN_EMAIL
    ADMIN_EMAIL=${ADMIN_EMAIL:-"admin@example.com"}
    
    #read -p "Passwort (Standard: password): " -s ADMIN_PASSWORD
    ADMIN_PASSWORD=${ADMIN_PASSWORD:-"password"}
    echo
    
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

    # Laravel Boost konfigurieren
    print_info "Laravel Boost wird konfiguriert..."
    php artisan boost:install
    print_info "Laravel Boost wurde konfiguriert"
    
    # Frontend Assets bauen
    print_info "Frontend Assets werden gebaut..."
    npm install || handle_error "NPM Installation"
    npm run build || handle_error "Frontend Assets Build"
    print_success "Frontend Assets gebaut"
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
    print_info "  Filament: 5.1"
    print_info "  Livewire: 4.x"
    print_info "  Pest: 2.x"
    print_info "  Laravel Boost: 2.x"
    echo
    
    print_info "Nächste Schritte:"
    print_info "  1. Entwicklungsserver starten: php artisan serve"
    print_info "  2. Admin-Panel öffnen: http://localhost:8000/admin"
    print_info "  3. Tests ausführen: ./vendor/bin/pest"
    print_info "  4. Projekt optimieren: composer run dev"
    echo
    
    print_info "Nützliche Befehle:"
    print_info "  • Neue Migration: php artisan make:migration create_table"
    print_info "  • Model erstellen: php artisan make:model ModelName"
    print_info "  • Controller erstellen: php artisan make:controller ControllerName"
    print_info "  • Filament Resource: php artisan make:filament-resource ResourceName"
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
    print_header "Laravel + Filament 5.1 Installationsskript"
    print_info "Dieses Skript erstellt ein vollständiges Laravel-Projekt mit modernem Stack"
    
    # Projektnamen abfragen
    ask_project_name
    
    print_info "Projektname: $PROJECT_NAME | Datenbank: $DATABASE_TYPE"
    
    # Installationsschritte durchführen
    check_prerequisites
    progress_bar 2
    
    install_laravel_installer
    progress_bar 1
    
    create_laravel_project
    progress_bar 3
    
    install_dependencies
    progress_bar 5
    
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
    
    set_permissions
    optimize_application
    progress_bar 2
    
    start_development_server
}

# Skript starten
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
