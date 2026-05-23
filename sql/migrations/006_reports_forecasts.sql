-- 8. reports
CREATE TABLE budget.reports (
    id              SERIAL          PRIMARY KEY,
    household_id    INTEGER         NOT NULL
                        REFERENCES budget.households(id) ON DELETE CASCADE,
    report_type     VARCHAR(20)     NOT NULL
                        CHECK (report_type IN ('monthly', 'quarterly', 'yearly')),
    period_start    DATE            NOT NULL,
    period_end      DATE            NOT NULL,
    total_income    NUMERIC(12,2)   NOT NULL DEFAULT 0,
    total_expense   NUMERIC(12,2)   NOT NULL DEFAULT 0,
    balance         NUMERIC(12,2)   NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Data końca musi być po dacie początku
    CHECK (period_end >= period_start)
);

COMMENT ON TABLE budget.reports IS 'Automatycznie generowane raporty finansowe';
COMMENT ON COLUMN budget.reports.report_type IS 'Typ raportu: monthly, quarterly, yearly';
COMMENT ON COLUMN budget.reports.balance IS 'Bilans = total_income - total_expense';

-- 9. forecasts
CREATE TABLE budget.forecasts (
    id                  SERIAL          PRIMARY KEY,
    household_id        INTEGER         NOT NULL
                            REFERENCES budget.households(id) ON DELETE CASCADE,
    category_id         INTEGER         NOT NULL
                            REFERENCES budget.categories(id) ON DELETE RESTRICT,
    month               INTEGER         NOT NULL
                            CHECK (month BETWEEN 1 AND 12),
    year                INTEGER         NOT NULL
                            CHECK (year BETWEEN 2000 AND 2100),
    predicted_amount    NUMERIC(12,2)   NOT NULL
                            CHECK (predicted_amount >= 0),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.forecasts IS 'Prognozy wydatków oparte na średniej kroczącej';
COMMENT ON COLUMN budget.forecasts.predicted_amount IS 'Przewidywana kwota wydatków na dany miesiąc';
