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
sql/queries/    - Zaawansowane zapytania SQL
sql/security/   - Role, uprawnienia (GRANT/REVOKE, RLS)
sql/transactions/ - Przykłady transakcji i poziomów izolacji
sql/seed/       - Dane testowe
frontend/       - Prosty frontend HTML+JS
```

## Konwencje nazewnictwa i wytyczne
Wszystkie konwencje dotyczące kodu SQL (nazewnictwo, schematy, itp.) oraz dokumentacji znajdują się w pliku `docs/conventions.md`. 
Zawsze stosuj się do tych zasad podczas tworzenia nowych elementów.

## Wymagania projektu
- Poprawnie działające podstawowe funkcjonalności bazy danych
- Rozbudowana funkcjonalność: zapytania zagnieżdżone, widoki (w tym materializowane)
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

## Kontekst dla AI
Gdy tworzysz SQL dla tego projektu:
- Zawsze używaj schematu `budget`
- Dodawaj komentarze wyjaśniające logikę
- Testuj na danych seed
- Sprawdź czy tabele są w 3NF
- Pamiętaj o indeksach na kolumnach WHERE i JOIN
- Używaj transakcji dla operacji modyfikujących wiele tabel
