-- Widok łączący wydatki z kategoriami, z uwzględnieniem samołączącej relacji (Self-Join).
-- Pozwala sprawdzić pełną ścieżkę wydatku: "Kategoria Główna -> Podkategoria"

CREATE OR REPLACE VIEW budget.v_category_expenses AS
SELECT 
    e.id AS expense_id,
    e.household_id,
    e.amount,
    e.expense_date,
    COALESCE(parent_cat.name, c.name) AS main_category_name,
    CASE 
        WHEN parent_cat.id IS NOT NULL THEN c.name 
        ELSE NULL 
    END AS sub_category_name
FROM budget.expenses e
JOIN budget.categories c ON e.category_id = c.id
LEFT JOIN budget.categories parent_cat ON c.parent_category_id = parent_cat.id;

COMMENT ON VIEW budget.v_category_expenses IS 'Rozbicie wydatków z uwzględnieniem kategorii głównej i podkategorii';
