# Translation Backend Tests

## Test Setup

Das Projekt enthält zwei verschiedene Test-Ansätze:

### 1. H2 In-Memory Tests (`TranslationControllerTest`)
- **Schnell und einfach** - keine externe Abhängigkeiten
- Verwendet H2 In-Memory Database
- Perfekt für schnelle Unit/Integration Tests
- Wird automatisch mit `application-test.properties` konfiguriert

### 2. Testcontainers PostgreSQL Tests (`TranslationControllerIntegrationTest`)
- **Realitätsnahe Tests** mit echter PostgreSQL Database
- Verwendet Docker Container für PostgreSQL
- Testet echte Database-Constraints und -Performance
- Benötigt Docker auf dem System

## Test-Struktur

```
src/
├── test/
│   ├── kotlin/cool/cfapps/translation_design_backend/translation/controller/
│   │   ├── TranslationControllerTest.kt                    # H2 Tests
│   │   └── TranslationControllerIntegrationTest.kt         # Testcontainers Tests
│   └── resources/
│       └── application-test.properties                     # Test-Konfiguration
```

## Getestete Funktionalitäten

**Alle Tests verwenden:**
- Category: `"test"`
- Locales: `"de"` und `"en"`
- Keys: `"welcome.title"` und `"button.save"`

**Abgedeckte Endpoints:**
- ✅ `POST /api/translations` - Erstellen neuer Translations
- ✅ `PUT /api/translations` - Aktualisieren bestehender Translations
- ✅ `DELETE /api/translations` - Löschen von Translations
- ✅ `GET /api/translations/single` - Einzelne Translation abrufen
- ✅ `GET /api/translations/category` - Alle Translations für Category + Locale
- ✅ `GET /api/translations/locale` - Alle Translations für Locale

**Getestete Szenarien:**
- ✅ Erfolgreiche CRUD-Operationen
- ✅ Fehlerbehandlung (404, 409, 400)
- ✅ Validation von Eingabedaten
- ✅ `initialValue=true/false` Funktionalität
- ✅ Database Constraints und Indexes
- ✅ Unique Constraint (category, locale, key)

## Tests ausführen

### Alle Tests ausführen
```bash
./gradlew test
```

### Nur H2 Tests ausführen
```bash
./gradlew test --tests "TranslationControllerTest"
```

### Nur Testcontainers Tests ausführen
```bash
# Erfordert Docker!
./gradlew test --tests "TranslationControllerIntegrationTest"
```

### Tests mit spezifischem Profil
```bash
./gradlew test -Dspring.profiles.active=test
```

## Voraussetzungen

### Für H2 Tests
- Keine besonderen Voraussetzungen
- Funktioniert out-of-the-box

### Für Testcontainers Tests
- **Docker muss installiert und gestartet sein**
- Docker Desktop (auf Windows/Mac) oder Docker Engine (auf Linux)
- Mindestens 1GB freier Speicherplatz für PostgreSQL Image

## Test-Konfiguration

### Dependencies in build.gradle.kts
```kotlin
dependencies {
    // Standard Test Dependencies
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testRuntimeOnly("com.h2database:h2")
    
    // Testcontainers (optional)
    testImplementation("org.springframework.boot:spring-boot-testcontainers")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
}
```

### application-test.properties
- Konfiguriert H2 In-Memory Database
- Deaktiviert Schema-Initialisierung (DDL auto-creation)
- Debug Logging für Tests

## Test Reports

Nach dem Ausführen der Tests findest du die Reports unter:
```
build/reports/tests/test/index.html
```

## Troubleshooting

### Docker Probleme (Testcontainers)
```bash
# Docker Status prüfen
docker ps

# Docker starten (falls nicht läuft)
# Windows/Mac: Docker Desktop starten
# Linux: sudo systemctl start docker
```

### H2 Console (für Debugging)
Wenn Tests mit H2 fehlschlagen, kannst du die H2 Console verwenden:
- URL: `http://localhost:8080/h2-console` (nur bei laufender App mit test profile)
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (leer)

### Test-Datenbank zurücksetzen
Tests verwenden `@Transactional` - Daten werden automatisch nach jedem Test zurückgesetzt.

## Performance

- **H2 Tests**: ~2-5 Sekunden
- **Testcontainers Tests**: ~10-20 Sekunden (wegen Docker Container Start)

Für schnelle Development-Zyklen: H2 Tests verwenden
Für finale Integration Tests: Testcontainers Tests verwenden