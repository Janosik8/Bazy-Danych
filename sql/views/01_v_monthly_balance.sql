-- Widok agregujący przychody i wydatki dla poszczególnych gospodarstw domowych per miesiąc
-- Ułatwia generowanie raportów miesięcznych.

CREATE OR REPLACE VIEW budget.v_monthly_balance AS
WITH monthly_incomes AS (
    SELECT 
        household_id,
        EXTRACT(YEAR FROM income_date) AS year,
        EXTRACT(MONTH FROM income_date) AS month,
        SUM(amount) AS total_income
    FROM budget.incomes
    GROUP BY household_id, EXTRACT(YEAR FROM income_date), EXTRACT(MONTH FROM income_date)
),
monthly_expenses AS (
    SELECT 
        household_id,
        EXTRACT(YEAR FROM expense_date) AS year,
        EXTRACT(MONTH FROM expense_date) AS month,
        SUM(amount) AS total_expense
    FROM budget.expenses
    GROUP BY household_id, EXTRACT(YEAR FROM expense_date), EXTRACT(MONTH FROM expense_date)
)
SELECT 
    COALESCE(i.household_id, e.household_id) AS household_id,
    COALESCE(i.year, e.year) AS year,
    COALESCE(i.month, e.month) AS month,
    COALESCE(i.total_income, 0) AS total_income,
    COALESCE(e.total_expense, 0) AS total_expense,
    (COALESCE(i.total_income, 0) - COALESCE(e.total_expense, 0)) AS balance
FROM monthly_incomes i
FULL OUTER JOIN monthly_expenses e 
    ON i.household_id = e.household_id 
    AND i.year = e.year 
    AND i.month = e.month;

COMMENT ON VIEW budget.v_monthly_balance IS 'Miesięczny bilans przychodów i wydatków per gospodarstwo';
