-- PostgreSQL Schema für Translation System
-- Diese Datei wird beim Backend-Start automatisch ausgeführt

-- Erstelle translations Tabelle
CREATE TABLE IF NOT EXISTS translations (
    id BIGSERIAL PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    locale VARCHAR(10) NOT NULL,
    key_name VARCHAR(200) NOT NULL,
    translation TEXT,
    initial_translation TEXT,
    max_length INTEGER DEFAULT 1024,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Erstelle Indexes für bessere Performance
CREATE INDEX IF NOT EXISTS idx_category
    ON translations (category);

CREATE INDEX IF NOT EXISTS idx_locale
    ON translations (locale);

CREATE INDEX IF NOT EXISTS idx_key
    ON translations (key_name);

-- Unique kombinatorischer Index für category, locale, key_name
-- Verhindert Duplikate und optimiert Queries
CREATE UNIQUE INDEX IF NOT EXISTS idx_category_locale_key
    ON translations (category, locale, key_name);

-- Optionale zusätzliche Indexes für häufige Query-Patterns
CREATE INDEX IF NOT EXISTS idx_category_locale
    ON translations (category, locale);

CREATE INDEX IF NOT EXISTS idx_updated_at
    ON translations (updated_at);

-- Kommentare für bessere Dokumentation
COMMENT ON TABLE translations IS 'Speichert custom Translations für verschiedene Apps und Locales';
COMMENT ON COLUMN translations.category IS 'Kategorie/App-Name der Translation (z.B. "mobile_app", "web_app")';
COMMENT ON COLUMN translations.locale IS 'Sprach-/Ländercode (z.B. "de", "en", "en_US")';
COMMENT ON COLUMN translations.key_name IS 'Translation-Key (z.B. "welcome.title", "button.save")';
COMMENT ON COLUMN translations.max_length IS 'Maximale Länge des übersetzten Textes)';
COMMENT ON COLUMN translations.translation IS 'Aktueller übersetzter Text';
COMMENT ON COLUMN translations.initial_translation IS 'Ursprünglicher übersetzter Text bei Erstellung';