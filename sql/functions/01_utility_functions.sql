-- Funkcje narzędziowe wykorzystywane do upraszczania logiki biznesowej

-- Funkcja nr 1: Pobiera bieżące (lub z określonego miesiąca) saldo gospodarstwa domowego
CREATE OR REPLACE FUNCTION budget.fn_get_household_balance(
    p_household_id INTEGER, 
    p_month INTEGER DEFAULT EXTRACT(MONTH FROM CURRENT_DATE), 
    p_year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)
)
RETURNS NUMERIC AS $$
DECLARE
    v_balance NUMERIC;
BEGIN
    SELECT balance INTO v_balance
    FROM budget.v_monthly_balance
    WHERE household_id = p_household_id
      AND month = p_month
      AND year = p_year;
      
    RETURN COALESCE(v_balance, 0);
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION budget.fn_get_household_balance IS 'Zwraca szybkie saldo rodziny na dany miesiąc. Domślnie miesiąc bieżący.';


-- Funkcja nr 2: Wylicza procentowy postęp realizacji wybranego celu oszczędnościowego
CREATE OR REPLACE FUNCTION budget.fn_calculate_goal_progress(p_goal_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_target NUMERIC;
    v_current NUMERIC;
    v_progress NUMERIC;
BEGIN
    SELECT target_amount, current_amount 
    INTO v_target, v_current
    FROM budget.savings_goals
    WHERE id = p_goal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cel oszczędnościowy o ID % nie istnieje', p_goal_id;
    END IF;

    IF v_target = 0 THEN
        RETURN 100.00;
    END IF;

    -- Ubezpieczamy się przed wartościami > 100% używając LEAST
    v_progress := ROUND((v_current / v_target) * 100, 2);
    RETURN LEAST(v_progress, 100.00);
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION budget.fn_calculate_goal_progress IS 'Wylicza procentowy udział zgromadzonych środków w stosunku do celu. Max 100%.';
