-- Funkcja wyzwalacza sprawdzająca, czy dodanie wydatku nie przekracza progu alertu
CREATE OR REPLACE FUNCTION budget.fn_check_budget_alert()
RETURNS TRIGGER AS $$
DECLARE
    v_budget_id INTEGER;
    v_utilization NUMERIC;
    v_threshold NUMERIC;
    v_is_triggered BOOLEAN;
BEGIN
    -- 1. Znajdź ID budżetu dla tej kategorii, w tym miesiącu i roku
    SELECT id INTO v_budget_id
    FROM budget.budgets
    WHERE household_id = NEW.household_id
      AND category_id = NEW.category_id
      AND month = EXTRACT(MONTH FROM NEW.expense_date)
      AND year = EXTRACT(YEAR FROM NEW.expense_date);

    -- Jeśli budżet istnieje, sprawdź alerty
    IF v_budget_id IS NOT NULL THEN
        
        -- Pobierz próg alertu i status z budget_alerts dla tego budżetu
        SELECT threshold_percent, is_triggered 
        INTO v_threshold, v_is_triggered
        FROM budget.budget_alerts
        WHERE budget_id = v_budget_id;

        -- Jeśli jest ustawiony alert i jeszcze nie został wyzwolony
        IF FOUND AND NOT v_is_triggered THEN
            -- Pobierz bieżące procentowe wykorzystanie z widoku (widok już zsumował wydatki łącznie z NEW,
            -- ponieważ wyzwalacz jest AFTER INSERT)
            SELECT utilization_percent INTO v_utilization
            FROM budget.v_budget_utilization
            WHERE budget_id = v_budget_id;

            -- Jeśli próg przekroczony -> aktualizuj tabelę alertów
            IF v_utilization >= v_threshold THEN
                UPDATE budget.budget_alerts
                SET is_triggered = TRUE,
                    triggered_at = NOW()
                WHERE budget_id = v_budget_id;
            END IF;
        END IF;

    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Wyzwalacz działa PO wstawieniu danych, aby widok utilization mógł uwzględnić najnowszy wydatek
CREATE TRIGGER trg_check_budget_alert
AFTER INSERT ON budget.expenses
FOR EACH ROW
EXECUTE FUNCTION budget.fn_check_budget_alert();

COMMENT ON FUNCTION budget.fn_check_budget_alert() IS 'Sprawdza wykorzystanie budżetu i wyzwala powiadomienie (is_triggered=TRUE) w razie przekroczenia limitu';
