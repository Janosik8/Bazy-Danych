SET client_min_messages TO WARNING;

-- 1. Budżety dla Gospodarstwa 1 (Miesiąc bieżący, zakłada się np 5 miesiąc 2024 dla testów)
INSERT INTO budget.budgets (household_id, category_id, month, year, planned_amount) VALUES
(1, 1, 5, 2024, 1500.00), -- Budżet na Jedzenie (ogólnie)
(1, 6, 5, 2024, 1200.00), -- Budżet szczegółowy na zakupy spożywcze
(1, 2, 5, 2024, 2000.00), -- Budżet na mieszkanie
(1, 3, 5, 2024, 500.00);  -- Budżet na transport

-- Alerty dla tych budżetów
INSERT INTO budget.budget_alerts (budget_id, threshold_percent) VALUES
(1, 90.00), -- Alert przy 90% wydatków na jedzenie
(3, 100.00);

-- 2. Przychody (Gospodarstwo 1 i 2)
INSERT INTO budget.incomes (household_id, user_id, category_id, amount, income_date, description) VALUES
(1, 1, 4, 8500.00, '2024-05-01', 'Wypłata Jan'),
(1, 2, 4, 7200.00, '2024-05-10', 'Wypłata Anna'),
(2, 3, 12, 1500.00, '2024-05-05', 'Stypendium za dobre wyniki');

-- 3. Wydatki
INSERT INTO budget.expenses (household_id, user_id, category_id, amount, expense_date, description) VALUES
(1, 1, 7, 1800.00, '2024-05-02', 'Czynsz za maj'),
(1, 2, 8, 150.00, '2024-05-04', 'Rachunek za prąd'),
(1, 1, 6, 230.50, '2024-05-05', 'Biedronka - duże zakupy'),
(1, 2, 6, 120.00, '2024-05-08', 'Lidl - uzupełnienie lodówki'),
(1, 1, 5, 180.00, '2024-05-12', 'Wyjście do restauracji'),
(1, 2, 9, 250.00, '2024-05-15', 'Tankowanie do pełna'),
(2, 3, 10, 80.00, '2024-05-10', 'Kino'),
(2, 3, 11, 45.00, '2024-05-11', 'Książka do Bazy Danych');

-- 4. Cele oszczędnościowe
INSERT INTO budget.savings_goals (household_id, name, target_amount, current_amount, deadline) VALUES
(1, 'Wakacje w Grecji', 8000.00, 2500.00, '2024-08-01'),
(2, 'Nowy Laptop', 4500.00, 1000.00, '2024-12-01');

-- 5. Transakcje cykliczne
INSERT INTO budget.recurring_transactions (household_id, user_id, category_id, type, amount, description, frequency, next_execution_date) VALUES
(1, 1, 7, 'expense', 1800.00, 'Czynsz za mieszkanie', 'monthly', '2024-06-02'),
(1, 2, 4, 'income', 7200.00, 'Pensja Anna', 'monthly', '2024-06-10');
