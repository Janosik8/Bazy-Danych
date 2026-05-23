-- Widok zliczający sumy roczne z miesięcznego bilansu.

CREATE OR REPLACE VIEW budget.v_yearly_summary AS
SELECT 
    household_id,
    year,
    SUM(total_income) AS yearly_income,
    SUM(total_expense) AS yearly_expense,
    SUM(balance) AS yearly_balance
FROM budget.v_monthly_balance
GROUP BY household_id, year;

COMMENT ON VIEW budget.v_yearly_summary IS 'Roczne agregacje finansów';
