-- =====================================================================
-- TEMAT: Wykorzystanie mechanizmów transakcyjnych i poziomów izolacji
-- PLIK Wymagany do weryfikacji kryterium na ocenę 4.5
-- =====================================================================

-- Wprowadzenie do transakcji w projekcie Budżetu Domowego
-- PostgreSQL domyślnie działa w trybie autocommit (każde zapytanie to oddzielna transakcja).
-- Poniżej prezentujemy świadome sterowanie transakcjami wielozadaniowymi oraz poziomy izolacji.

-- ---------------------------------------------------------------------
-- SCENARIUSZ 1: READ COMMITTED (Domyślny poziom izolacji)
-- Zastosowanie: Standardowe operacje modyfikacji bazy danych.
-- Chroni przed zjawiskiem Dirty Read (brudny odczyt).
-- ---------------------------------------------------------------------

BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Krok 1: Przelew z konta (dodanie wydatku)
INSERT INTO budget.expenses (household_id, user_id, category_id, amount, description)
VALUES (
    1, 
    1, 
    (SELECT id FROM budget.categories WHERE name = 'Wakacje' AND household_id IS NULL), 
    500.00, 
    'Zadatek na loty'
);

-- Krok 2: Powiązane zasilenie celu oszczędnościowego
-- (Załóżmy, że wydatek na koncie głównym idzie do wirtualnej "skarbonki" wakacyjnej)
UPDATE budget.savings_goals 
SET current_amount = current_amount + 500.00
WHERE household_id = 1 AND name = 'Wakacje - Rzym';

-- Zatwierdzenie obu zmian "wszystko albo nic" (Zasada ACID: Atomicity)
COMMIT;


-- ---------------------------------------------------------------------
-- SCENARIUSZ 2: SERIALIZABLE (Najwyższy poziom izolacji)
-- Zastosowanie: Zapobieganie zjawisku Phantom Reads (Odczyty widma).
-- Idealne np. przy tworzeniu jednorazowych, krytycznych raportów 
-- lub w sytuacjach tworzenia unikalnych kategorii przez różnych członków rodziny.
-- ---------------------------------------------------------------------

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Weryfikacja: Użytkownik sprawdza, czy rodzina ma już otwarty budżet na "Rozrywkę"
-- Jeśli w trakcie trwania naszej transakcji ktoś inny z rodziny założy ten sam budżet 
-- i zacommituje, transakcja SERIALIZABLE to wykryje i rzuci błąd przy próbie zapisu 
-- (could not serialize access due to read/write dependencies among transactions).
SELECT COUNT(*) FROM budget.budgets 
WHERE household_id = 2 
AND category_id = (SELECT id FROM budget.categories WHERE name = 'Rozrywka' AND household_id IS NULL);

-- Teoretyczny wynik: 0. Rodzina decyduje się dodać budżet.
INSERT INTO budget.budgets (household_id, category_id, amount, month, year)
VALUES (
    2, 
    (SELECT id FROM budget.categories WHERE name = 'Rozrywka' AND household_id IS NULL), 
    400.00, 
    6, 
    2026
);

COMMIT;


-- ---------------------------------------------------------------------
-- SCENARIUSZ 3: REPEATABLE READ z użyciem SAVEPOINT (Rollback częściowy)
-- Zastosowanie: Długie operacje z możliwością wycofania części działań.
-- ---------------------------------------------------------------------

BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Wstawienie pierwszego wydatku
INSERT INTO budget.expenses (household_id, user_id, category_id, amount, description)
VALUES (1, 1, 1, 100.00, 'Zakupy rano');

SAVEPOINT punkt_kontrolny_1;

-- Próba dodania drugiego wydatku
INSERT INTO budget.expenses (household_id, user_id, category_id, amount, description)
VALUES (1, 1, 2, 9000.00, 'Kupno telewizora');

-- Ups! Użytkownik się rozmyślił co do telewizora, wycofujemy TYLKO drugi wydatek
ROLLBACK TO SAVEPOINT punkt_kontrolny_1;

-- Pierwszy wydatek nadal jest w transakcji, możemy zacommitować
COMMIT;
