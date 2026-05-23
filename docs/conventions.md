# Konwencje nazewnictwa i wytyczne projektowe

Dokument ten zawiera zasady nazewnictwa i konwencje stosowane w projekcie bazy danych do zarządzania budżetem domowym. 
Zasady te mają na celu zachowanie spójności w kodzie SQL oraz strukturze repozytorium.

## Konwencje SQL

- **Nazwy tabel**: angielskie, `snake_case`, liczba mnoga (np. `expenses`, `categories`)
- **Nazwy kolumn**: angielskie, `snake_case` (np. `created_at`, `user_id`)
- **Klucze główne**: `id` (typu `SERIAL`, `BIGSERIAL` lub `UUID`)
- **Klucze obce**: `nazwa_tabeli_id` w liczbie pojedynczej (np. `category_id`)
- **Pliki migracji**: numerowane `NNN_opis.sql` (np. `001_create_schema.sql`)
- **Komentarze w SQL**: w języku polskim
- **Schemat bazy**: wszystkie obiekty są tworzone w dedykowanym schemacie `budget` (nie używamy schematu `public`)
- **Znaczniki czasu**: wszystkie tabele muszą posiadać kolumnę `created_at TIMESTAMPTZ DEFAULT NOW()`
- **Normalizacja**: stosujemy zasady trzeciej postaci normalnej (3NF)

## Konwencje dokumentacji

- Dokumenty w folderze `docs/` są pisane w języku polskim
- Diagramy bazy danych (ERD) projektowane są w formacie Mermaid
- Każdy dokument Markdown posiada główny nagłówek (H1) oraz spis treści
- Nazwy plików Markdown są w języku angielskim i w konwencji `kebab-case` (np. `logical-model.md`)
