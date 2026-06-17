# Instrukcja użytkowa (Onboarding i Testowanie Bazy)

Niniejszy dokument służy jako praktyczny przewodnik pozwalający na ręczne przetestowanie podstawowych oraz zaawansowanych funkcjonalności bazy danych zarządzania budżetem domowym.

## 1. Nawiązanie połączenia z bazą
Po uruchomieniu środowiska kontenerowego (Docker), należy wejść do konsoli PostgreSQL:
```bash
docker exec -it budget_postgres psql -U budget_user -d budget_db
```
Zaleca się ustawienie domyślnego schematu w konsoli, aby nie musieć za każdym razem poprzedzać tabel prefiksem `budget.`:
```sql
SET search_path TO budget;
```

## 2. Podstawowe operacje na danych (Testowanie 3NF i Triggerów)
Możesz przetestować wstawianie nowych wpisów (np. dodanie wydatku). Zauważysz, że niemożliwe jest wstawienie wydatku bez poprawnego `user_id` czy `category_id` ze względu na relacje kluczy obcych.
```sql
INSERT INTO expenses (household_id, user_id, category_id, amount, description)
VALUES (1, 1, 2, 150.00, 'Testowe zakupy codzienne');
```
Zauważysz również, że wstawiony przed chwilą rekord ma z automatu wypełnioną kolumnę `updated_at` dzięki zaimplementowanym wyzwalaczom PL/pgSQL.

## 3. Testowanie Widoków i Raportów
Zamiast budować wielolinijkowe zapytania, skorzystaj z przygotowanych widoków. Aby zobaczyć ogólny bilans w danym miesiącu dla konkretnego domu, wpisz:
```sql
SELECT * FROM v_monthly_balance WHERE household_id = 1;
```

Możesz też łatwo zobaczyć podsumowanie wydatków z podziałem na szczegółowe kategorie:
```sql
SELECT * FROM v_category_expenses WHERE household_id = 1;
```

## 4. Testowanie zabezpieczeń RLS (Row Level Security)
System uniemożliwia zwykłym użytkownikom "podglądanie" kont sąsiadów. Aby to udowodnić, włącz na moment uprawnienia "zwykłego użytkownika":
```sql
SET ROLE budget_member;

-- Próba odczytu wydatków. Baza zwróci 0 wyników (zablokowano dostęp):
SELECT * FROM expenses;

-- Uwierzytelnienie gospodarstwa domowego nr 1 (Zalogowano jako Rodzina Kowalskich):
SET app.current_household_id = '1';

-- Teraz to samo zapytanie z sukcesem zwróci wyłącznie wydatki gospodarstwa 1:
SELECT * FROM expenses;

-- Powrót do uprawnień Super-Administratora:
RESET ROLE;
```

## 5. Wywoływanie procedur (Automatyzacja)
Jeśli w bazie znajdują się transakcje zadeklarowane jako stałe/cykliczne (w tabeli `recurring_transactions`), nie trzeba dodawać ich ręcznie. Wystarczy uruchomić zdefiniowaną procedurę składowaną:
```sql
CALL proc_process_recurring();
```
Baza sama przeliczy daty i utworzy wpisy wpłat/wypłat, wyznaczając jednocześnie nową datę kolejnego cyklu.
