-- 4. categories
CREATE TABLE budget.categories (
    id                  SERIAL          PRIMARY KEY,
    household_id        INTEGER         NOT NULL
                            REFERENCES budget.households(id) ON DELETE CASCADE,
    name                VARCHAR(100)    NOT NULL,
    type                VARCHAR(10)     NOT NULL
                            CHECK (type IN ('income', 'expense')),
    parent_category_id  INTEGER
                            REFERENCES budget.categories(id) ON DELETE SET NULL,
    icon                VARCHAR(10),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.categories IS 'Kategorie przychodów i wydatków (hierarchia 2-poziomowa)';
COMMENT ON COLUMN budget.categories.type IS 'Typ kategorii: income (przychód) lub expense (wydatek)';
COMMENT ON COLUMN budget.categories.parent_category_id IS 'FK do kategorii nadrzędnej (NULL = kategoria główna)';
COMMENT ON COLUMN budget.categories.icon IS 'Opcjonalna ikona/emoji kategorii';
