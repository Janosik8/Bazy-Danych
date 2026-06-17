# Raport Końcowy - Aplikacja do zarządzania budżetem domowym

Niniejszy raport stanowi podsumowanie i dokumentację końcową projektu zaliczeniowego z przedmiotu Bazy Danych. Projekt odzwierciedla pełny cykl życia systemu: od analizy, przez normalizację i implementację, po zabezpieczenia i interfejs GUI.

Projekt został skrupulatnie przygotowany z myślą o spełnieniu wymagań na **ocenę 4.5**.

---

## 1. Architektura i Normalizacja (3NF)
Cała struktura naszej bazy danych została zaprojektowana w Trzeciej Postaci Normalnej (3NF). 
Wyeliminowano redundancje oraz częściowe czy przechodnie zależności. Klucze obce (FK) rygorystycznie pilnują spójności powiązań pomiędzy użytkownikami, wydatkami, kategoriami czy budżetami.

* **Lokalizacja w repozytorium**: `sql/migrations/001_create_schema.sql` (definicja tabel i kluczy obcych)
* **Dokumentacja schematu**: `docs/erd.md` (diagram ERD i opis encji)

## 2. Zaawansowane zapytania SQL i Widoki (Views)
Wykorzystano zaawansowane mechanizmy łączenia tabel, w tym agregacje i zapytania zagnieżdżone. Aplikacja opiera swój przepływ danych na dedykowanych widokach, w tym na **widoku zmaterializowanym**.

* **Lokalizacja widoków standardowych**: `sql/views/01_core_views.sql` (m.in. `v_monthly_balance`, `v_category_expenses`)
* **Widoki Zmaterializowane**: `sql/views/02_materialized_views.sql` (np. `mv_yearly_summary` wymagający periodycznego odświeżania)

## 3. Logika Proceduralna PL/pgSQL (Procedury i Wyzwalacze)
Logika biznesowa przeniesiona do warstwy bazy danych poprzez język proceduralny PL/pgSQL:
* **Procedury Składowane**: Obsługa automatyzacji zadań wieloetapowych. 
  * `sql/procedures/01_process_recurring_transactions.sql` - automatyzacja naliczania wydatków abonamentowych (cyklicznych).
* **Wyzwalacze (Triggers)**: Monitorowanie zmian na żywo.
  * `sql/triggers/01_updated_at_triggers.sql` - wyzwalacz automatycznie uaktualniający kolumnę `updated_at`.
  * `sql/triggers/02_budget_alert_trigger.sql` - wyzwalacz pilnujący, czy w wyniku `INSERT/UPDATE` nie przekroczono zadanego progu ostrzegawczego budżetu.

## 4. Transakcje i Poziomy Izolacji (Wymaganie na 4.5)
Projekt świadomie operuje na wieloetapowych zapytaniach zamkniętych w transakcjach. Przygotowano pełną demonstrację pokazującą różnice między transakcjami zapobiegającymi odczytom brudnym (Dirty Reads) i widmom (Phantom Reads), w tym wykorzystanie `SAVEPOINT`.

* **Plik demonstracyjny z transakcjami**: `sql/transactions/01_isolation_levels_demo.sql` 

## 5. Bezpieczeństwo - RBAC i Row Level Security (Wymaganie na 4.5)
Odeszliśmy od archaicznego schematu `public`. Stworzyliśmy autorski schemat `budget` oraz precyzyjną macierz uprawnień klasy enterprise.

* **RBAC (Role Based Access Control)**: Zdefiniowane 3 role (`budget_admin`, `budget_member`, `budget_viewer`) posiadające restrykcyjne uprawnienia na poziomie GRANT / REVOKE.
* **RLS (Row Level Security)**: Najpotężniejszy element obronny systemu. Użytkownik nie zobaczy danych innej rodziny nawet wykonując polecenie `SELECT * FROM expenses`. Wymagane jest poświadczenie tożsamości poprzez identyfikator sesyjny.
* **Lokalizacja w repozytorium**: `sql/security/01_roles_permissions.sql` oraz `sql/security/02_row_level_security.sql`

## 6. Przewodniki i Interfejs Użytkownika
Oprócz twardej logiki SQL stworzono dla systemu ułatwienia prezentacyjne:
* **Interfejs GUI**: Prosty (Vanilla HTML/CSS/JS), ale estetyczny interfejs symulujący obsługę logiki bazodanowej. Umieszczony w katalogu `frontend/`. 
* **Dokumentacja Onboardingowa**: Przewodnik krok po kroku po środowisku: `docs/onboarding.md`
* **Słownik Pojęć**: `docs/glossary.md`

---

### Instrukcja Uruchomienia dla Prowadzącego
1. Sklonuj repozytorium.
2. Wejdź do głównego katalogu z plikiem `docker-compose.yml`.
3. Wykonaj `docker-compose up -d`.
4. Gotowe! Baza danych ładuje w pełni poprawną architekturę, wszystkie funkcje, RLS, widoki zmaterializowane oraz wstrzykuje dane testowe (z katalogu `sql/seed`).
5. (Opcjonalnie) Otwórz w przeglądarce `frontend/index.html` aby zobaczyć symulację interfejsu.
