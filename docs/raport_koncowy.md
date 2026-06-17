# Raport Końcowy - Aplikacja do zarządzania budżetem domowym

Poniżej znajduje się podsumowanie projektu zaliczeniowego z przedmiotu Bazy Danych. Projekt odzwierciedla wszystkie etapy pracy z systemem bazodanowym i spełnia postawione przed nim kryteria. Poniżej rozpisano, gdzie w repozytorium znajdują się konkretne elementy realizacji.

---

## 1. Podstawowe funkcjonalności i schemat bazy (Normalizacja 2NF i 3NF)
Cała struktura bazy danych została zaprojektowana od podstaw, tak aby w pełni funkcjonowała i przechowywała powiązane dane dotyczące budżetów, wydatków i celów oszczędnościowych. Schemat bazy spełnia zasady normalizacji – doprowadzono go do Trzeciej Postaci Normalnej (3NF), eliminując powtarzające się dane i zapewniając poprawność relacji (kluczy obcych).
* **Definicja tabel i struktury**: `sql/migrations/001_create_schema.sql`
* **Dane testowe potwierdzające działanie**: Wszystkie pliki w katalogu `sql/seed/`

## 2. Dokumentacja techniczna i użytkowa (w tym ERD)
Przygotowano odpowiednią dokumentację opisującą działanie bazy, definicje, założenia oraz zaprojektowane struktury:
* **Diagram ERD i opis implementacji encji**: `docs/erd.md`
* **Dokumentacja użytkowa (Instrukcja testowania)**: `docs/onboarding.md`
* **Słownik pojęć**: `docs/glossary.md`
* **Wymagania niefunkcjonalne**: `docs/non-functional-requirements.md`

## 3. Rozbudowana funkcjonalność (zaawansowane zapytania i widoki)
Aby ułatwić i usprawnić odpytywanie bazy z zewnątrz, utworzono zaawansowane zapytania z zagnieżdżeniami pod postacią widoków. 
* **Zwykłe widoki (agregacje, sumowanie)**: `sql/views/01_core_views.sql`
* **Widoki zmaterializowane (raporty roczne)**: `sql/views/02_materialized_views.sql`

## 4. Wyzwalacze, procedury i funkcje (PL/pgSQL)
Napisano dedykowane skrypty w języku proceduralnym PL/pgSQL, które automatyzują pracę wewnątrz systemu PostgreSQL:
* **Procedura do transakcji cyklicznych**: `sql/procedures/01_process_recurring_transactions.sql`
* **Wyzwalacz (Trigger) do alertów budżetowych**: `sql/triggers/02_budget_alert_trigger.sql` (dynamicznie reaguje na instrukcje INSERT)
* **Funkcje narzędziowe**: `sql/functions/01_utility_functions.sql`

## 5. Mechanizmy transakcyjne i poziomy izolacji
Wdrożono i udokumentowano demonstrację działania bazy w rygorystycznym środowisku transakcyjnym z wykorzystaniem różnych poziomów izolacji (`READ COMMITTED` oraz `SERIALIZABLE`), z uwzględnieniem `SAVEPOINT` i `ROLLBACK`.
* **Plik demonstrujący mechanizmy transakcyjne**: `sql/transactions/01_isolation_levels_demo.sql`

## 6. Bezpieczeństwo danych (Role i uprawnienia)
Precyzyjnie skonfigurowano reguły bezpieczeństwa i odseparowano dostęp do tabel. Utworzono 3 oddzielne role w bazie (Admin, Member, Viewer) i użyto mechanizmów odizolowywania rekordów:
* **Definicja ról i nadawanie praw (GRANT/REVOKE)**: `sql/security/01_roles_permissions.sql`
* **Konfiguracja bezpieczeństwa na poziomie wiersza (RLS)**: `sql/security/02_row_level_security.sql`

---

### Jak uruchomić projekt do sprawdzenia?
1. Należy sklonować repozytorium na własny dysk.
2. Otworzyć terminal w głównym folderze i wpisać komendę `docker-compose up -d`.
3. Baza automatycznie się zbuduje, stworzy odpowiednie tabele, załaduje wszystkie widoki/procedury oraz wstrzyknie do środka dane testowe z sekwencji seedów. W ten sposób projekt jest od razu gotowy do przeglądu.
