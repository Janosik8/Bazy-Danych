# Raport Końcowy - Aplikacja do zarządzania budżetem domowym

Poniżej znajduje się podsumowanie naszego projektu zaliczeniowego z przedmiotu Bazy Danych. Projekt został pomyślany tak, żeby pokazać wszystkie etapy pracy z bazą: od analizy i wymyślenia struktury, przez pisanie zapytań i funkcji, po dodanie ról, uprawnień i transakcji.

Wszystkie kody źródłowe podzieliliśmy na wygodne foldery w repozytorium.

---

## 1. Struktura i Tabele (Normalizacja do 3NF)
Cała baza została zaprojektowana zgodnie z zasadami Trzeciej Postaci Normalnej (3NF). Pozbyliśmy się powtarzających się danych, a relacje (klucze obce) trzymają wszystko w ryzach – np. nie da się przypisać wydatku do nieistniejącego użytkownika.
* **Tutaj tworzymy tabele**: `sql/migrations/001_create_schema.sql` 
* **Diagram bazy (ERD)**: Można go zobaczyć w pliku `docs/erd.md`

## 2. Zapytania i Widoki (Views)
Zamiast pisać trudne i długie zapytania (z dużą liczbą JOINów) bezpośrednio w zewnętrznej aplikacji, zrobiliśmy sobie wygodne widoki bezpośrednio w bazie. Wykorzystaliśmy też widok zmaterializowany, który bardzo przyspiesza liczenie rocznych podsumowań na dużych zbiorach danych.
* **Zwykłe widoki**: `sql/views/01_core_views.sql` (np. wygodne podsumowanie wydatków w miesiącu)
* **Widoki zmaterializowane**: `sql/views/02_materialized_views.sql`

## 3. Procedury i Wyzwalacze (PL/pgSQL)
Napisaliśmy własne funkcje w PL/pgSQL, żeby zautomatyzować działanie bazy, żeby nie trzeba było wszystkiego robić i pilnować ręcznie:
* **Procedury**: Mamy procedurę, która na żądanie automatycznie nalicza stałe abonamenty i subskrypcje w danym miesiącu (`sql/procedures/01_process_recurring_transactions.sql`).
* **Wyzwalacze (Triggers)**: 
  * Wyzwalacz automatycznie aktualizujący datę edycji wiersza w kolumnie `updated_at` (`sql/triggers/01_updated_at_triggers.sql`).
  * Wyzwalacz, który od razu sprawdza podczas dodawania wydatku, czy nie wydaliśmy za dużo na daną kategorię i wstawia specjalny alert (`sql/triggers/02_budget_alert_trigger.sql`).

## 4. Transakcje i Izolacja
Zadbaliśmy też o bezpieczeństwo spójności operacji, zwłaszcza kiedy wykonuje się dużo zapytań jednocześnie. Przygotowaliśmy plik, w którym pokazujemy jak można używać `READ COMMITTED` oraz `SERIALIZABLE`, żeby zapobiec błędom (np. gdy dwie osoby z rodziny na raz próbują założyć budżet na to samo).
* **Plik z przykładami transakcji**: `sql/transactions/01_isolation_levels_demo.sql` 

## 5. Bezpieczeństwo - Role i Uprawnienia (RBAC i RLS)
Skonfigurowaliśmy precyzyjnie, kto ma dostęp do jakich danych w systemie:
* Zrobiliśmy 3 różne role z różnymi prawami zapisu i odczytu (Admin, Member, Viewer) w pliku `sql/security/01_roles_permissions.sql`.
* Użyliśmy mechanizmu **Row Level Security (RLS)**. Dzięki temu zalogowany użytkownik widzi wyłącznie wydatki swojego własnego gospodarstwa domowego, a baza danych sama ucina i ukrywa przed nim resztę wyników z innych domów: `sql/security/02_row_level_security.sql`.

## 6. Przewodniki i Interfejs Użytkownika
Oprócz czystego kodu SQL, dla pokazania efektów stworzyliśmy:
* **Frontend**: Prosty interfejs graficzny w HTML/JS, który symuluje podpięcie do naszej bazy i odpytywanie widoków (`frontend/`).
* **Instrukcję testowania**: Opis krok po kroku, jak postawić bazę i przetestować wszystkie jej funkcjonalności (znajduje się w `docs/onboarding.md`).

---

### Jak uruchomić projekt do sprawdzenia?
1. Sklonuj repozytorium na swój dysk.
2. Otwórz terminal w głównym folderze i wpisz komendę `docker-compose up -d`.
3. Baza automatycznie się zbuduje, poukłada tabele i załaduje wszystkie powyższe skrypty oraz wstrzyknie dane testowe (można je podejrzeć w katalogu `sql/seed/`).
4. Gotowe, można wejść do kontenera i wpisywać własne kwerendy!
