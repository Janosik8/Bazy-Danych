-- 7. budgets
CREATE TABLE budget.budgets (
    id              SERIAL          PRIMARY KEY,
    household_id    INTEGER         NOT NULL
                        REFERENCES budget.households(id) ON DELETE CASCADE,
    category_id     INTEGER         NOT NULL
                        REFERENCES budget.categories(id) ON DELETE RESTRICT,
    month           INTEGER         NOT NULL
                        CHECK (month BETWEEN 1 AND 12),
    year            INTEGER         NOT NULL
                        CHECK (year BETWEEN 2000 AND 2100),
    planned_amount  NUMERIC(12,2)   NOT NULL
                        CHECK (planned_amount > 0),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Jeden budżet per (gospodarstwo, kategoria, miesiąc, rok)
    UNIQUE (household_id, category_id, month, year)
);

COMMENT ON TABLE budget.budgets IS 'Budżety miesięczne na poszczególne kategorie';
COMMENT ON COLUMN budget.budgets.month IS 'Miesiąc (1–12)';
COMMENT ON COLUMN budget.budgets.year IS 'Rok (2000–2100)';
COMMENT ON COLUMN budget.budgets.planned_amount IS 'Planowana kwota limitu wydatków';

-- 12. budget_alerts
CREATE TABLE budget.budget_alerts (
    id                  SERIAL          PRIMARY KEY,
    budget_id           INTEGER         NOT NULL
                            REFERENCES budget.budgets(id) ON DELETE CASCADE,
    threshold_percent   NUMERIC(5,2)    NOT NULL DEFAULT 80.00
                            CHECK (threshold_percent BETWEEN 0 AND 100),
    is_triggered        BOOLEAN         NOT NULL DEFAULT FALSE,
    triggered_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.budget_alerts IS 'Alerty budżetowe z konfigurowalnym progiem procentowym';
COMMENT ON COLUMN budget.budget_alerts.threshold_percent IS 'Próg procentowy wyzwolenia alertu (np. 80%)';
COMMENT ON COLUMN budget.budget_alerts.is_triggered IS 'Czy alert został już wyzwolony';
COMMENT ON COLUMN budget.budget_alerts.triggered_at IS 'Data i czas wyzwolenia alertu';
