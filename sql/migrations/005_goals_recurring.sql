-- 10. savings_goals
CREATE TABLE budget.savings_goals (
    id              SERIAL          PRIMARY KEY,
    household_id    INTEGER         NOT NULL
                        REFERENCES budget.households(id) ON DELETE CASCADE,
    name            VARCHAR(100)    NOT NULL,
    target_amount   NUMERIC(12,2)   NOT NULL
                        CHECK (target_amount > 0),
    current_amount  NUMERIC(12,2)   NOT NULL DEFAULT 0
                        CHECK (current_amount >= 0),
    deadline        DATE,
    status          VARCHAR(20)     NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.savings_goals IS 'Cele oszczędnościowe gospodarstwa domowego';
COMMENT ON COLUMN budget.savings_goals.target_amount IS 'Docelowa kwota oszczędności';
COMMENT ON COLUMN budget.savings_goals.current_amount IS 'Aktualnie zaoszczędzona kwota';
COMMENT ON COLUMN budget.savings_goals.status IS 'Status: active, completed, cancelled';

-- 11. recurring_transactions
CREATE TABLE budget.recurring_transactions (
    id                      SERIAL          PRIMARY KEY,
    household_id            INTEGER         NOT NULL
                                REFERENCES budget.households(id) ON DELETE CASCADE,
    user_id                 INTEGER         NOT NULL
                                REFERENCES budget.users(id) ON DELETE RESTRICT,
    category_id             INTEGER         NOT NULL
                                REFERENCES budget.categories(id) ON DELETE RESTRICT,
    type                    VARCHAR(10)     NOT NULL
                                CHECK (type IN ('income', 'expense')),
    amount                  NUMERIC(12,2)   NOT NULL
                                CHECK (amount > 0),
    description             TEXT,
    frequency               VARCHAR(20)     NOT NULL
                                CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
    next_execution_date     DATE            NOT NULL,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.recurring_transactions IS 'Wzorce transakcji cyklicznych';
COMMENT ON COLUMN budget.recurring_transactions.frequency IS 'Częstotliwość: daily, weekly, monthly, yearly';
COMMENT ON COLUMN budget.recurring_transactions.next_execution_date IS 'Data następnego automatycznego wykonania';
COMMENT ON COLUMN budget.recurring_transactions.is_active IS 'Czy transakcja cykliczna jest aktywna';
