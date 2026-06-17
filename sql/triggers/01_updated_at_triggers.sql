-- Funkcja współdzielona (trigger function), aktualizująca kolumnę updated_at
CREATE OR REPLACE FUNCTION budget.fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Uzupełnienie kolumny updated_at w istniejących tabelach
ALTER TABLE budget.budgets ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE budget.budget_alerts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE budget.savings_goals ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE budget.recurring_transactions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Podpięcie triggerów BEFORE UPDATE
CREATE TRIGGER trg_budgets_updated_at
BEFORE UPDATE ON budget.budgets
FOR EACH ROW
EXECUTE FUNCTION budget.fn_update_timestamp();

CREATE TRIGGER trg_budget_alerts_updated_at
BEFORE UPDATE ON budget.budget_alerts
FOR EACH ROW
EXECUTE FUNCTION budget.fn_update_timestamp();

CREATE TRIGGER trg_savings_goals_updated_at
BEFORE UPDATE ON budget.savings_goals
FOR EACH ROW
EXECUTE FUNCTION budget.fn_update_timestamp();

CREATE TRIGGER trg_recurring_transactions_updated_at
BEFORE UPDATE ON budget.recurring_transactions
FOR EACH ROW
EXECUTE FUNCTION budget.fn_update_timestamp();

COMMENT ON FUNCTION budget.fn_update_timestamp() IS 'Uniwersalna funkcja aktualizująca kolumnę updated_at przy modyfikacji rekordu';
