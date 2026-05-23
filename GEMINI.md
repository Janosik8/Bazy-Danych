# Projekt: Aplikacja do zarządzania budżetem domowym

## Opis
Projekt bazodanowy realizowany w zespole 3-osobowym. System do zarządzania budżetem domowym z bazą przychodów, wydatków, kategorii finansowych, raportów, prognoz, celów oszczędnościowych, transakcji cyklicznych i alertów budżetowych.

## Stos technologiczny
- **SGBD**: PostgreSQL 16+
- **Język proceduralny**: PL/pgSQL
- **Dokumentacja**: Markdown
- **Frontend**: HTML + CSS + JavaScript (prosty)

## Struktura repozytorium
```
docs/           - Dokumentacja techniczna (wymagania, ERD, modele)
sql/migrations/ - Migracje SQL (numerowane: 001_, 002_, ...)
sql/views/      - Widoki (w tym materializowane)
sql/functions/  - Funkcje PL/pgSQL
sql/triggers/   - Wyzwalacze
sql/procedures/ - Procedury składowane
sql/security/   - Role, uprawnienia (GRANT/REVOKE, RLS)
sql/transactions/ - Przykłady transakcji i poziomów izolacji
sql/seed/       - Dane testowe
frontend/       - Prosty frontend HTML+JS
```
> **Ważne info o Dockerze:** Kontener z bazą ładuje i uruchamia automatycznie *tylko* pliki znajdujące się bezpośrednio w folderze `sql/migrations/` (i to alfabetycznie). Kod z innych katalogów (jak `views`, `functions`, `seed`) musi być albo wywoływany ręcznie, albo załączany poprzez dodatkowe skrypty odpalające wewnątrz `migrations/` (np. przez pętlę w bashu).

## Konwencje nazewnictwa i wytyczne
Wszystkie konwencje dotyczące kodu SQL (nazewnictwo, schematy, itp.) oraz dokumentacji znajdują się w pliku `docs/conventions.md`. 
Zawsze stosuj się do tych zasad podczas tworzenia nowych elementów.

## Wymagania projektu
- Poprawnie działające podstawowe funkcjonalności bazy danych
- Wyzwalacze i procedury/funkcje w PL/pgSQL
- Dokumentacja techniczna z diagramami ERD
- Struktura zgodna z 3NF
- Mechanizmy transakcyjne i różne poziomy izolacji
- Bezpieczeństwo: role, uprawnienia, RLS
- Dodatkowe: cele oszczędnościowe, transakcje cykliczne, alerty budżetowe

## Workflow
1. Bierz issue z GitHub (przypisz się)
2. Utwórz branch: `feature/numer-issue-krotki-opis`
3. Implementuj zadanie
4. Utwórz PR z opisem co zrobiono
5. Po review - merge do master

## Kontekst dla AI (Antigravity CLI)
Gdy pracujesz przy tym projekcie, rygorystycznie przestrzegaj poniższych zasad:
1. **Schemat bazy**: Zawsze używaj prefiksu `budget.` przed nazwami tabel (np. `budget.users`).
2. **PostgreSQL w Dockerze**:
   - Kod wykonujący się automatycznie (DDL, początkowa struktura) ląduje w `sql/migrations/`.
   - Widoki (`sql/views/`), procedury (`sql/functions/`) i skrypty ładujące dane (`sql/seed/`) muszą być explicite wywołane (np. poprzez specjalne skrypty powłoki wewnątrz `/migrations/` lub uruchomienie ręczne).
3. **Dokumentacja wbudowana**: Pisz jasne komentarze `COMMENT ON TABLE` i `COMMENT ON COLUMN` dla każdego nowego elementu schematu.
4. **Jakość kodu**: Stosuj 3NF, używaj precyzyjnych typów numerycznych (np. `NUMERIC(12,2)` zamiast `FLOAT`), oraz pamiętaj o nakładaniu indeksów na klucze obce.
5. **Cykl pracy z zadaniami**: Zawsze pracuj na nowym odgałęzieniu (`feature/...`). Zanim utworzysz dziesiątki linii kodu, opracuj `implementation_plan.md` i zapytaj użytkownika o zgodę. Po akceptacji twórz `task.md`, a na koniec podsumuj pracę w `walkthrough.md`. Nigdy nie commituj bez zapytania o zgodę!
6. **Polski język**: Opisy do bazy, dokumentacja i komunikacja z zespołem musi odbywać się w języku polskim. Kod SQL (nazwy, aliasy) zawsze po angielsku.
