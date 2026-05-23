-- Widok wykorzystania budżetu. 
-- Pobiera tabelę zaplanowanych budżetów (budgets) i za pomocą LEFT JOIN 
-- złącza ją z rzeczywistymi wydatkami w danej kategorii i miesiącu.

CREATE OR REPLACE VIEW budget.v_budget_utilization AS
WITH monthly_category_expenses AS (
    SELECT 
        household_id,
        category_id,
        EXTRACT(YEAR FROM expense_date) AS year,
        EXTRACT(MONTH FROM expense_date) AS month,
        SUM(amount) AS spent_amount
    FROM budget.expenses
    GROUP BY household_id, category_id, EXTRACT(YEAR FROM expense_date), EXTRACT(MONTH FROM expense_date)
)
SELECT 
    b.id AS budget_id,
    b.household_id,
    c.name AS category_name,
    b.month,
    b.year,
    b.planned_amount,
    COALESCE(e.spent_amount, 0) AS spent_amount,
    (b.planned_amount - COALESCE(e.spent_amount, 0)) AS remaining_amount,
    ROUND((COALESCE(e.spent_amount, 0) / b.planned_amount) * 100, 2) AS utilization_percent
FROM budget.budgets b
JOIN budget.categories c ON b.category_id = c.id
LEFT JOIN monthly_category_expenses e 
    ON b.household_id = e.household_id 
    AND b.category_id = e.category_id 
    AND b.month = e.month 
    AND b.year = e.year;

COMMENT ON VIEW budget.v_budget_utilization IS 'Zestawienie zaplanowanego budżetu z faktycznie poniesionymi wydatkami';
