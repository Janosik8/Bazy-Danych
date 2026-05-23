-- 5. incomes
CREATE TABLE budget.incomes (
    id              SERIAL          PRIMARY KEY,
    household_id    INTEGER         NOT NULL
                        REFERENCES budget.households(id) ON DELETE CASCADE,
    user_id         INTEGER         NOT NULL
                        REFERENCES budget.users(id) ON DELETE RESTRICT,
    category_id     INTEGER         NOT NULL
                        REFERENCES budget.categories(id) ON DELETE RESTRICT,
    amount          NUMERIC(12,2)   NOT NULL
                        CHECK (amount > 0),
    income_date     DATE            NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.incomes IS 'Przychody gospodarstwa domowego';
COMMENT ON COLUMN budget.incomes.amount IS 'Kwota przychodu (musi być dodatnia)';
COMMENT ON COLUMN budget.incomes.income_date IS 'Data uzyskania przychodu';

-- 6. expenses
CREATE TABLE budget.expenses (
    id              SERIAL          PRIMARY KEY,
    household_id    INTEGER         NOT NULL
                        REFERENCES budget.households(id) ON DELETE CASCADE,
    user_id         INTEGER         NOT NULL
                        REFERENCES budget.users(id) ON DELETE RESTRICT,
    category_id     INTEGER         NOT NULL
                        REFERENCES budget.categories(id) ON DELETE RESTRICT,
    amount          NUMERIC(12,2)   NOT NULL
                        CHECK (amount > 0),
    expense_date    DATE            NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.expenses IS 'Wydatki gospodarstwa domowego';
COMMENT ON COLUMN budget.expenses.amount IS 'Kwota wydatku (musi być dodatnia)';
COMMENT ON COLUMN budget.expenses.expense_date IS 'Data poniesienia wydatku';
