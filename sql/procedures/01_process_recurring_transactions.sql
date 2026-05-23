-- Procedura przetwarzająca transakcje cykliczne
-- Należy ją wywoływać z zewnętrznego systemu (np. przez demona cron lub task scheduler) każdego dnia.

CREATE OR REPLACE PROCEDURE budget.proc_process_recurring_transactions()
LANGUAGE plpgsql
AS $$
DECLARE
    r_rec RECORD;
BEGIN
    -- Przeszukaj wszystkie aktywne transakcje cykliczne, których data wykonania minęła lub jest dzisiaj
    FOR r_rec IN 
        SELECT id, household_id, user_id, category_id, type, amount, frequency, next_execution_date, description
        FROM budget.recurring_transactions
        WHERE next_execution_date <= CURRENT_DATE
    LOOP
        -- W zależności od typu, dodaj wpis do tabeli przychodów lub wydatków
        IF r_rec.type = 'income' THEN
            INSERT INTO budget.incomes (household_id, user_id, category_id, amount, description, income_date)
            VALUES (r_rec.household_id, r_rec.user_id, r_rec.category_id, r_rec.amount, '[AUTO] ' || r_rec.description, r_rec.next_execution_date);
        ELSIF r_rec.type = 'expense' THEN
            INSERT INTO budget.expenses (household_id, user_id, category_id, amount, description, expense_date)
            VALUES (r_rec.household_id, r_rec.user_id, r_rec.category_id, r_rec.amount, '[AUTO] ' || r_rec.description, r_rec.next_execution_date);
        END IF;

        -- Zaktualizuj datę następnego wykonania na podstawie częstotliwości
        UPDATE budget.recurring_transactions
        SET next_execution_date = 
            CASE r_rec.frequency
                WHEN 'daily' THEN r_rec.next_execution_date + INTERVAL '1 day'
                WHEN 'weekly' THEN r_rec.next_execution_date + INTERVAL '1 week'
                WHEN 'monthly' THEN r_rec.next_execution_date + INTERVAL '1 month'
                WHEN 'yearly' THEN r_rec.next_execution_date + INTERVAL '1 year'
            END
        WHERE id = r_rec.id;
    END LOOP;

    -- Procedura nie zwraca danych (jest używana do wywoływania operacji DML)
END;
$$;

COMMENT ON PROCEDURE budget.proc_process_recurring_transactions() IS 'Procedura analizująca i wykonująca przeterminowane transakcje cykliczne';
