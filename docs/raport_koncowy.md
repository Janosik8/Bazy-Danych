# Raport Końcowy - Aplikacja do zarządzania budżetem domowym

Poniżej znajduje się podsumowanie projektu zaliczeniowego z przedmiotu Bazy Danych. Projekt odzwierciedla wszystkie etapy pracy z systemem bazodanowym: od analizy i przygotowania struktury, przez pisanie zapytań i funkcji, po dodanie ról, uprawnień i transakcji.

Wszystkie kody źródłowe podzielono na odpowiednie foldery w repozytorium.

---

## 1. Struktura i Tabele (Normalizacja do 3NF)
Cała baza została zaprojektowana zgodnie z zasadami Trzeciej Postaci Normalnej (3NF). Wyeliminowano powtarzające się dane, a relacje (klucze obce) pilnują spójności – np. nie da się przypisać wydatku do nieistniejącego użytkownika.
* **Plik z tabelami**: `sql/migrations/001_create_schema.sql` 
* **Diagram bazy (ERD)**: Zaprezentowano w pliku `docs/erd.md`

## 2. Zapytania i Widoki (Views)
Zamiast korzystać z trudnych i długich zapytań bezpośrednio w zewnętrznej aplikacji, utworzono wygodne widoki bezpośrednio w bazie. Wykorzystano również widok zmaterializowany, który bardzo przyspiesza liczenie rocznych podsumowań na dużych zbiorach danych.
* **Zwykłe widoki**: `sql/views/01_core_views.sql` (np. ułatwiające podsumowanie wydatków w miesiącu)
* **Widoki zmaterializowane**: `sql/views/02_materialized_views.sql`

## 3. Procedury i Wyzwalacze (PL/pgSQL)
Napisano odpowiednie funkcje w PL/pgSQL, aby zautomatyzować działanie bazy i zmniejszyć ilość ręcznych modyfikacji danych:
* **Procedury**: Utworzono procedurę, która na żądanie automatycznie nalicza stałe abonamenty i subskrypcje w danym miesiącu (`sql/procedures/01_process_recurring_transactions.sql`).
* **Wyzwalacze (Triggers)**: 
  * Wyzwalacz automatycznie aktualizujący datę edycji wiersza w kolumnie `updated_at` (`sql/triggers/01_updated_at_triggers.sql`).
  * Wyzwalacz, który od razu sprawdza podczas dodawania wydatku, czy nie wydano za dużo na daną kategorię i dodaje specjalny wpis ostrzegawczy (`sql/triggers/02_budget_alert_trigger.sql`).

## 4. Transakcje i Izolacja
Zadbano o bezpieczeństwo spójności operacji, zwłaszcza w przypadkach wykonywania wielu zapytań jednocześnie. Przygotowano plik demonstrujący zastosowanie `READ COMMITTED` oraz `SERIALIZABLE` w celu zapobiegania błędom (np. gdy dwoje użytkowników na raz próbuje założyć budżet na tę samą kategorię).
* **Plik z przykładami transakcji**: `sql/transactions/01_isolation_levels_demo.sql` 

## 5. Bezpieczeństwo - Role i Uprawnienia (RBAC i RLS)
Precyzyjnie skonfigurowano reguły dostępu do danych w systemie:
* Utworzono 3 różne role z przypisanymi prawami zapisu i odczytu (Admin, Member, Viewer) w pliku `sql/security/01_roles_permissions.sql`.
* Wykorzystano mechanizm **Row Level Security (RLS)**. Dzięki niemu zalogowany użytkownik widzi wyłącznie wydatki swojego własnego gospodarstwa domowego, a baza danych automatycznie filtruje i ukrywa przed nim wyniki pochodzące z innych kont: `sql/security/02_row_level_security.sql`.

## 6. Przewodniki i Interfejs Użytkownika
Oprócz skryptów SQL, w celu wizualizacji działania przygotowano:
* **Frontend**: Prosty interfejs graficzny w technologiach HTML/JS, który symuluje podpięcie pod bazę i odpytywanie widoków (`frontend/`).
* **Instrukcję testowania**: Opis krok po kroku, jak poprawnie zainicjować bazę i przetestować jej pełną funkcjonalność (`docs/onboarding.md`).

---

### Jak uruchomić projekt do sprawdzenia?
1. Należy sklonować repozytorium na własny dysk.
2. Otworzyć terminal w głównym folderze i wpisać komendę `docker-compose up -d`.
3. Baza automatycznie się zbuduje, stworzy odpowiednie tabele, załaduje wszystkie powyższe skrypty oraz wstrzyknie wstępne dane testowe (zawartość w katalogu `sql/seed/`).
4. Baza jest gotowa do przyjmowania kwerend testowych.
