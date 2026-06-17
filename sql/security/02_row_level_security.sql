-- Bezpieczeństwo na poziomie wiersza (Row Level Security - RLS)

-- Krok 1: Włączenie RLS dla kluczowych tabel zawierających household_id
ALTER TABLE budget.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.incomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.savings_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.recurring_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.budget_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget.household_members ENABLE ROW LEVEL SECURITY;

-- Krok 2: Ominięcie RLS dla administratorów (Bypass RLS)
-- Dzięki temu budget_admin z automatu widzi i modyfikuje wszystko
ALTER ROLE budget_admin BYPASSRLS;

-- Krok 3: Utworzenie polityk bezpieczeństwa.
-- Zakładamy, że aplikacja łącząca się z bazą ustawi zmienną środowiskową np:
-- SET app.current_household_id = '1';
-- Zabezpieczamy się na wypadek, gdyby zmienna była pusta przy pomocy wbudowanego wyjątku (coalesce/cast).

-- Wydatki
CREATE POLICY expense_isolation_policy ON budget.expenses
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Przychody
CREATE POLICY income_isolation_policy ON budget.incomes
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Budżety
CREATE POLICY budget_isolation_policy ON budget.budgets
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Kategorie (kategorie globalne gdzie household_id IS NULL są widoczne dla wszystkich)
CREATE POLICY category_isolation_policy ON budget.categories
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id IS NULL OR household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Cele oszczędnościowe
CREATE POLICY savings_isolation_policy ON budget.savings_goals
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Transakcje cykliczne
CREATE POLICY recurring_isolation_policy ON budget.recurring_transactions
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Członkowie gospodarstw (tylko swoi członkowie)
CREATE POLICY members_isolation_policy ON budget.household_members
    FOR ALL
    TO budget_member, budget_viewer
    USING (household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer);

-- Alerty (są połączone z budget_id, z którym łączy się RLS budżetu, 
-- jednak dla precyzji RLS ustalamy politykę względem JOINa, albo odpuszczamy RLS jeśli sprawdzanie jest na poziomie aplikacji).
-- Ze względów wydajnościowych zostawiamy budget_alerts powiązane polityką JOIN:
CREATE POLICY alerts_isolation_policy ON budget.budget_alerts
    FOR ALL
    TO budget_member, budget_viewer
    USING (
        budget_id IN (
            SELECT id FROM budget.budgets 
            WHERE household_id = NULLIF(current_setting('app.current_household_id', true), '')::integer
        )
    );
