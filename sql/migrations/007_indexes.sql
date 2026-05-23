-- Indeksy dla household_members
CREATE INDEX idx_household_members_household ON budget.household_members(household_id);
CREATE INDEX idx_household_members_user ON budget.household_members(user_id);

-- Indeksy dla categories
CREATE INDEX idx_categories_household ON budget.categories(household_id);
CREATE INDEX idx_categories_parent ON budget.categories(parent_category_id);

-- Indeksy dla incomes
CREATE INDEX idx_incomes_household ON budget.incomes(household_id);
CREATE INDEX idx_incomes_date ON budget.incomes(income_date);
CREATE INDEX idx_incomes_category ON budget.incomes(category_id);

-- Indeksy dla expenses
CREATE INDEX idx_expenses_household ON budget.expenses(household_id);
CREATE INDEX idx_expenses_date ON budget.expenses(expense_date);
CREATE INDEX idx_expenses_category ON budget.expenses(category_id);

-- Indeks złożony dla budgets
CREATE INDEX idx_budgets_household_period ON budget.budgets(household_id, month, year);

-- Indeksy dla reports
CREATE INDEX idx_reports_household ON budget.reports(household_id);

-- Indeksy dla forecasts
CREATE INDEX idx_forecasts_household ON budget.forecasts(household_id);

-- Indeksy dla savings_goals
CREATE INDEX idx_savings_goals_household ON budget.savings_goals(household_id);

-- Indeksy dla recurring_transactions
CREATE INDEX idx_recurring_household ON budget.recurring_transactions(household_id);
CREATE INDEX idx_recurring_next_date ON budget.recurring_transactions(next_execution_date);

-- Indeksy dla budget_alerts
CREATE INDEX idx_budget_alerts_budget ON budget.budget_alerts(budget_id);
