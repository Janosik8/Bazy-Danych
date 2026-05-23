# Model fizyczny bazy danych

## Spis treści

1. [Wprowadzenie](#wprowadzenie)
2. [Mapowanie typów logicznych na PostgreSQL](#mapowanie-typów-logicznych-na-postgresql)
3. [Definicje tabel](#definicje-tabel)
   - [users](#1-users)
   - [households](#2-households)
   - [household_members](#3-household_members)
   - [categories](#4-categories)
   - [incomes](#5-incomes)
   - [expenses](#6-expenses)
   - [budgets](#7-budgets)
   - [reports](#8-reports)
   - [forecasts](#9-forecasts)
   - [savings_goals](#10-savings_goals)
   - [recurring_transactions](#11-recurring_transactions)
   - [budget_alerts](#12-budget_alerts)
4. [Indeksy](#indeksy)
5. [Ograniczenia (constraints)](#ograniczenia-constraints)
   - [CHECK](#ograniczenia-check)
   - [UNIQUE](#ograniczenia-unique)
   - [FOREIGN KEY i strategia ON DELETE](#klucze-obce-i-strategia-on-delete)
6. [Sekwencje i wartości domyślne](#sekwencje-i-wartości-domyślne)
7. [Partycjonowanie (opcjonalne)](#partycjonowanie-opcjonalne)

---

## Wprowadzenie

Niniejszy dokument opisuje **model fizyczny** bazy danych systemu zarządzania budżetem domowym. Model jest zoptymalizowany pod **PostgreSQL 16+** i uwzględnia specyficzne cechy tego systemu zarządzania bazą danych.

Wszystkie obiekty bazodanowe (tabele, indeksy, sekwencje, ograniczenia) są tworzone w schemacie **`budget`**, a nie w domyślnym schemacie `public`. Nazwy tabel i kolumn stosują konwencję `snake_case` w języku angielskim.

> [!NOTE]
> Dokument jest kontynuacją modelu logicznego i stanowi podstawę do tworzenia plików migracji SQL w katalogu `sql/migrations/`.

---

## Mapowanie typów logicznych na PostgreSQL

Poniższa tabela przedstawia mapowanie abstrakcyjnych typów logicznych na konkretne typy danych PostgreSQL 16+:

| Typ logiczny | Typ PostgreSQL | Uwagi |
|---|---|---|
| Identyfikator | `SERIAL` / `BIGSERIAL` | Auto-increment, klucz główny |
| Tekst krótki | `VARCHAR(N)` | Z określoną maksymalną długością |
| Tekst długi | `TEXT` | Bez limitu długości |
| Kwota pieniężna | `NUMERIC(12,2)` | Dokładna arytmetyka dziesiętna, bez błędów zaokrąglania |
| Data | `DATE` | Tylko data, bez komponentu czasu |
| Data i czas | `TIMESTAMPTZ` | Ze strefą czasową (timestamp with time zone) |
| Tak/Nie | `BOOLEAN` | Wartości `TRUE` / `FALSE` |
| Wyliczenie | `VARCHAR(N)` + `CHECK` | Zamiast typu `ENUM` — łatwiejsze migracje |
| Procent | `NUMERIC(5,2)` | Zakres 0.00 – 100.00 |

> [!TIP]
> Używamy `NUMERIC(12,2)` zamiast `FLOAT` lub `MONEY` — gwarantuje to dokładną arytmetykę finansową bez błędów zmiennoprzecinkowych.

---

## Definicje tabel

### 1. users

Tabela przechowująca dane użytkowników systemu.

```sql
CREATE TABLE budget.users (
    id              SERIAL          PRIMARY KEY,
    email           VARCHAR(255)    NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    display_name    VARCHAR(100)    NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.users IS 'Użytkownicy systemu budżetowego';
COMMENT ON COLUMN budget.users.email IS 'Unikalny adres email użytkownika';
COMMENT ON COLUMN budget.users.password_hash IS 'Hash hasła (pgcrypto)';
COMMENT ON COLUMN budget.users.display_name IS 'Nazwa wyświetlana w interfejsie';
```

---

### 2. households

Tabela gospodarstw domowych — podstawowa jednostka organizacyjna systemu.

```sql
CREATE TABLE budget.households (
    id              SERIAL          PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.households IS 'Gospodarstwa domowe współdzielące budżet';
COMMENT ON COLUMN budget.households.name IS 'Nazwa gospodarstwa domowego';
COMMENT ON COLUMN budget.households.description IS 'Opcjonalny opis gospodarstwa';
```

---

### 3. household_members

Tabela asocjacyjna łącząca użytkowników z gospodarstwami (relacja wiele-do-wielu) z określoną rolą.

```sql
CREATE TABLE budget.household_members (
    id              SERIAL          PRIMARY KEY,
    household_id    INTEGER         NOT NULL
                        REFERENCES budget.households(id) ON DELETE CASCADE,
    user_id         INTEGER         NOT NULL
                        REFERENCES budget.users(id) ON DELETE CASCADE,
    role            VARCHAR(20)     NOT NULL DEFAULT 'member'
                        CHECK (role IN ('owner', 'member', 'viewer')),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Jeden użytkownik może mieć tylko jedną rolę w danym gospodarstwie
    UNIQUE (household_id, user_id)
);

COMMENT ON TABLE budget.household_members IS 'Powiązanie użytkowników z gospodarstwami domowymi';
COMMENT ON COLUMN budget.household_members.role IS 'Rola: owner (właściciel), member (członek), viewer (obserwator)';
```

---

### 4. categories

Tabela kategorii finansowych z hierarchią dwupoziomową (self-referencing FK).

```sql
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
```

---

### 5. incomes

Tabela przychodów (wpływów finansowych) do gospodarstwa domowego.

```sql
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
```

---

### 6. expenses

Tabela wydatków (wypływów finansowych) z gospodarstwa domowego.

```sql
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
```

---

### 7. budgets

Tabela budżetów miesięcznych — planowane limity wydatków per kategoria.

```sql
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
```

---

### 8. reports

Tabela raportów finansowych generowanych automatycznie przez procedury.

```sql
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
```

---

### 9. forecasts

Tabela prognoz finansowych opartych na danych historycznych.

```sql
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
```

---

### 10. savings_goals

Tabela celów oszczędnościowych z śledzeniem postępu.

```sql
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
```

---

### 11. recurring_transactions

Tabela wzorców transakcji cyklicznych (np. czynsz, pensja).

```sql
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
```

---

### 12. budget_alerts

Tabela alertów budżetowych wyzwalanych automatycznie przy przekroczeniu progu.

```sql
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
```

---

## Indeksy

Poniższa tabela zawiera listę wszystkich planowanych indeksów z uzasadnieniem ich utworzenia. Wszystkie indeksy korzystają z domyślnej struktury **B-tree**, optymalnej dla operacji `=`, `<`, `>`, `BETWEEN` i `ORDER BY`.

| Indeks | Tabela | Kolumny | Typ | Uzasadnienie |
|---|---|---|---|---|
| `idx_household_members_household` | `household_members` | `household_id` | B-tree | JOIN i filtrowanie członków per gospodarstwo |
| `idx_household_members_user` | `household_members` | `user_id` | B-tree | JOIN i filtrowanie gospodarstw per użytkownik |
| `idx_categories_household` | `categories` | `household_id` | B-tree | Filtrowanie kategorii per gospodarstwo |
| `idx_categories_parent` | `categories` | `parent_category_id` | B-tree | Nawigacja po hierarchii kategorii |
| `idx_incomes_household` | `incomes` | `household_id` | B-tree | Filtrowanie przychodów per gospodarstwo |
| `idx_incomes_date` | `incomes` | `income_date` | B-tree | Filtrowanie i sortowanie po dacie przychodu |
| `idx_incomes_category` | `incomes` | `category_id` | B-tree | Grupowanie i filtrowanie po kategorii |
| `idx_expenses_household` | `expenses` | `household_id` | B-tree | Filtrowanie wydatków per gospodarstwo |
| `idx_expenses_date` | `expenses` | `expense_date` | B-tree | Filtrowanie i sortowanie po dacie wydatku |
| `idx_expenses_category` | `expenses` | `category_id` | B-tree | Grupowanie i filtrowanie po kategorii |
| `idx_budgets_household_period` | `budgets` | `household_id`, `month`, `year` | B-tree (composite) | Szybkie wyszukiwanie budżetu na dany miesiąc |
| `idx_reports_household` | `reports` | `household_id` | B-tree | Filtrowanie raportów per gospodarstwo |
| `idx_forecasts_household` | `forecasts` | `household_id` | B-tree | Filtrowanie prognoz per gospodarstwo |
| `idx_savings_goals_household` | `savings_goals` | `household_id` | B-tree | Filtrowanie celów oszczędnościowych |
| `idx_recurring_household` | `recurring_transactions` | `household_id` | B-tree | Filtrowanie transakcji cyklicznych |
| `idx_recurring_next_date` | `recurring_transactions` | `next_execution_date` | B-tree | Znajdowanie zaległych transakcji do wykonania |
| `idx_budget_alerts_budget` | `budget_alerts` | `budget_id` | B-tree | JOIN z tabelą `budgets` |

**SQL tworzący indeksy:**

```sql
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
```

> [!IMPORTANT]
> PostgreSQL automatycznie tworzy indeks B-tree dla każdego ograniczenia `PRIMARY KEY` i `UNIQUE`. Powyższe indeksy obejmują **tylko** kolumny kluczy obcych i kolumny często używane w klauzulach `WHERE`, `JOIN` i `ORDER BY`, które nie mają automatycznego indeksu.

---

## Ograniczenia (constraints)

### Ograniczenia CHECK

Ograniczenia `CHECK` zapewniają integralność danych na poziomie wiersza:

| Tabela | Kolumna | Ograniczenie | Opis |
|---|---|---|---|
| `household_members` | `role` | `CHECK (role IN ('owner', 'member', 'viewer'))` | Dozwolone role w gospodarstwie |
| `categories` | `type` | `CHECK (type IN ('income', 'expense'))` | Typ kategorii: przychód lub wydatek |
| `incomes` | `amount` | `CHECK (amount > 0)` | Kwota przychodu musi być dodatnia |
| `expenses` | `amount` | `CHECK (amount > 0)` | Kwota wydatku musi być dodatnia |
| `budgets` | `month` | `CHECK (month BETWEEN 1 AND 12)` | Poprawny numer miesiąca |
| `budgets` | `year` | `CHECK (year BETWEEN 2000 AND 2100)` | Poprawny zakres lat |
| `budgets` | `planned_amount` | `CHECK (planned_amount > 0)` | Planowana kwota musi być dodatnia |
| `reports` | `report_type` | `CHECK (report_type IN ('monthly', 'quarterly', 'yearly'))` | Dozwolone typy raportów |
| `reports` | `period_start`, `period_end` | `CHECK (period_end >= period_start)` | Data końca nie wcześniej niż data początku |
| `forecasts` | `month` | `CHECK (month BETWEEN 1 AND 12)` | Poprawny numer miesiąca |
| `forecasts` | `year` | `CHECK (year BETWEEN 2000 AND 2100)` | Poprawny zakres lat |
| `forecasts` | `predicted_amount` | `CHECK (predicted_amount >= 0)` | Przewidywana kwota nie może być ujemna |
| `savings_goals` | `target_amount` | `CHECK (target_amount > 0)` | Kwota docelowa musi być dodatnia |
| `savings_goals` | `current_amount` | `CHECK (current_amount >= 0)` | Aktualna kwota nie może być ujemna |
| `savings_goals` | `status` | `CHECK (status IN ('active', 'completed', 'cancelled'))` | Dozwolone statusy celu |
| `recurring_transactions` | `type` | `CHECK (type IN ('income', 'expense'))` | Typ transakcji: przychód lub wydatek |
| `recurring_transactions` | `amount` | `CHECK (amount > 0)` | Kwota musi być dodatnia |
| `recurring_transactions` | `frequency` | `CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly'))` | Dozwolone częstotliwości |
| `budget_alerts` | `threshold_percent` | `CHECK (threshold_percent BETWEEN 0 AND 100)` | Procent w zakresie 0–100 |

### Ograniczenia UNIQUE

| Tabela | Kolumny | Opis |
|---|---|---|
| `users` | `email` | Każdy adres email musi być unikalny w systemie |
| `household_members` | `(household_id, user_id)` | Użytkownik może mieć tylko jedną rolę w danym gospodarstwie |
| `budgets` | `(household_id, category_id, month, year)` | Jeden budżet per kombincja gospodarstwo-kategoria-miesiąc-rok |

### Klucze obce i strategia ON DELETE

Strategia `ON DELETE` została dobrana indywidualnie dla każdej relacji:

- **`CASCADE`** — usunięcie rekordu nadrzędnego kasuje powiązane rekordy podrzędne (dane tracą sens bez rodzica)
- **`RESTRICT`** — blokuje usunięcie rekordu nadrzędnego, jeśli istnieją powiązane rekordy (ochrona referencji)
- **`SET NULL`** — ustawia klucz obcy na `NULL` (zachowuje rekord podrzędny, zrywając powiązanie)

| Tabela podrzędna | Kolumna FK | Tabela nadrzędna | ON DELETE | Uzasadnienie |
|---|---|---|---|---|
| `household_members` | `user_id` | `users` | `CASCADE` | Usunięcie użytkownika kasuje jego członkostwa |
| `household_members` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje wszystkie członkostwa |
| `categories` | `parent_category_id` | `categories` | `SET NULL` | Usunięcie kategorii nadrzędnej — podkategoria staje się główną |
| `categories` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje jego kategorie |
| `incomes` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje jego przychody |
| `incomes` | `user_id` | `users` | `RESTRICT` | Nie można usunąć użytkownika z zarejestrowanymi przychodami |
| `incomes` | `category_id` | `categories` | `RESTRICT` | Nie można usunąć kategorii używanej w przychodach |
| `expenses` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje jego wydatki |
| `expenses` | `user_id` | `users` | `RESTRICT` | Nie można usunąć użytkownika z zarejestrowanymi wydatkami |
| `expenses` | `category_id` | `categories` | `RESTRICT` | Nie można usunąć kategorii używanej w wydatkach |
| `budgets` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje jego budżety |
| `budgets` | `category_id` | `categories` | `RESTRICT` | Nie można usunąć kategorii z przypisanym budżetem |
| `reports` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje jego raporty |
| `forecasts` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje jego prognozy |
| `forecasts` | `category_id` | `categories` | `RESTRICT` | Nie można usunąć kategorii z prognozami |
| `savings_goals` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje cele oszczędnościowe |
| `recurring_transactions` | `household_id` | `households` | `CASCADE` | Usunięcie gospodarstwa kasuje transakcje cykliczne |
| `recurring_transactions` | `user_id` | `users` | `RESTRICT` | Nie można usunąć użytkownika z transakcjami cyklicznymi |
| `recurring_transactions` | `category_id` | `categories` | `RESTRICT` | Nie można usunąć kategorii z transakcjami cyklicznymi |
| `budget_alerts` | `budget_id` | `budgets` | `CASCADE` | Usunięcie budżetu kasuje powiązane alerty |

> [!WARNING]
> Strategia `CASCADE` na relacji `households` → tabele zależne oznacza, że usunięcie gospodarstwa domowego spowoduje kaskadowe usunięcie **wszystkich** powiązanych danych (kategorie, przychody, wydatki, budżety, raporty, prognozy, cele, transakcje cykliczne). Ta operacja jest nieodwracalna — warto rozważyć soft-delete w warstwie aplikacyjnej.

---

## Sekwencje i wartości domyślne

### Sekwencje (SERIAL)

Każda tabela korzysta z typu `SERIAL` dla klucza głównego `id`. PostgreSQL automatycznie tworzy sekwencję dla każdej kolumny `SERIAL`:

| Tabela | Sekwencja (auto-generowana) | Typ |
|---|---|---|
| `users` | `budget.users_id_seq` | `SERIAL` (INTEGER) |
| `households` | `budget.households_id_seq` | `SERIAL` (INTEGER) |
| `household_members` | `budget.household_members_id_seq` | `SERIAL` (INTEGER) |
| `categories` | `budget.categories_id_seq` | `SERIAL` (INTEGER) |
| `incomes` | `budget.incomes_id_seq` | `SERIAL` (INTEGER) |
| `expenses` | `budget.expenses_id_seq` | `SERIAL` (INTEGER) |
| `budgets` | `budget.budgets_id_seq` | `SERIAL` (INTEGER) |
| `reports` | `budget.reports_id_seq` | `SERIAL` (INTEGER) |
| `forecasts` | `budget.forecasts_id_seq` | `SERIAL` (INTEGER) |
| `savings_goals` | `budget.savings_goals_id_seq` | `SERIAL` (INTEGER) |
| `recurring_transactions` | `budget.recurring_transactions_id_seq` | `SERIAL` (INTEGER) |
| `budget_alerts` | `budget.budget_alerts_id_seq` | `SERIAL` (INTEGER) |

> [!NOTE]
> Typ `SERIAL` jest skrótem PostgreSQL dla `INTEGER NOT NULL DEFAULT nextval('sekwencja')`. Dla tabel z przewidywanym dużym wolumenem danych (np. `expenses`, `incomes`) warto rozważyć zmianę na `BIGSERIAL` w przyszłości.

### Wartości domyślne

| Tabela | Kolumna | Wartość domyślna | Opis |
|---|---|---|---|
| *wszystkie tabele* | `created_at` | `NOW()` | Automatyczny timestamp utworzenia rekordu |
| `household_members` | `role` | `'member'` | Domyślna rola nowego członka |
| `reports` | `total_income` | `0` | Zerowy przychód przy tworzeniu raportu |
| `reports` | `total_expense` | `0` | Zerowy wydatek przy tworzeniu raportu |
| `reports` | `balance` | `0` | Zerowy bilans przy tworzeniu raportu |
| `savings_goals` | `current_amount` | `0` | Nowy cel zaczyna od zera |
| `savings_goals` | `status` | `'active'` | Nowy cel jest aktywny |
| `recurring_transactions` | `is_active` | `TRUE` | Nowa transakcja cykliczna jest aktywna |
| `budget_alerts` | `threshold_percent` | `80.00` | Domyślny próg alertu: 80% |
| `budget_alerts` | `is_triggered` | `FALSE` | Alert nie został jeszcze wyzwolony |

---

## Partycjonowanie (opcjonalne)

> [!NOTE]
> Poniższa sekcja opisuje **opcjonalne** partycjonowanie tabel, które może zostać wdrożone w przyszłości, gdy wolumen danych wzrośnie. Dla zakresu tego projektu partycjonowanie nie jest wymagane.

### Kandydaci do partycjonowania

Tabele `expenses` i `incomes` są głównymi kandydatami do partycjonowania, ponieważ:

- Rosną najszybciej (każda transakcja to nowy wiersz)
- Zapytania niemal zawsze filtrują po zakresie dat
- Archiwalne dane rzadko wymagają modyfikacji

### Strategia: PARTITION BY RANGE

Partycjonowanie według zakresu dat (`expense_date` / `income_date`), z jedną partycją na rok:

```sql
-- Przykład: partycjonowanie tabeli expenses po roku
CREATE TABLE budget.expenses (
    id              SERIAL,
    household_id    INTEGER         NOT NULL,
    user_id         INTEGER         NOT NULL,
    category_id     INTEGER         NOT NULL,
    amount          NUMERIC(12,2)   NOT NULL CHECK (amount > 0),
    expense_date    DATE            NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, expense_date)
) PARTITION BY RANGE (expense_date);

-- Partycje per rok
CREATE TABLE budget.expenses_2024 PARTITION OF budget.expenses
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE budget.expenses_2025 PARTITION OF budget.expenses
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE budget.expenses_2026 PARTITION OF budget.expenses
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
```

**Korzyści:**
- Szybsze zapytania z filtrem po dacie (pruning partycji)
- Łatwiejsze archiwizowanie starych danych (odłączenie partycji)
- Niezależny `VACUUM` i `ANALYZE` per partycja

**Wady:**
- Klucz główny musi zawierać kolumnę partycjonowania
- Klucze obce do tabeli partycjonowanej wymagają dodatkowej obsługi
- Złożoność administracyjna (tworzenie nowych partycji)

> [!CAUTION]
> W przypadku wdrożenia partycjonowania, klucze obce z innych tabel (np. `budget_alerts` → `budgets`) wymagają szczególnej uwagi, ponieważ PostgreSQL nie wspiera bezpośrednio kluczy obcych **do** tabel partycjonowanych w wersjach < 17.

---

> **Powiązane dokumenty:**
> - [Wymagania funkcjonalne](requirements.md) — opis wymagań biznesowych
> - [Słownik pojęć](glossary.md) — mapowanie terminów PL ↔ EN
> - [Wymagania niefunkcjonalne](non-functional-requirements.md) — wydajność, bezpieczeństwo, skalowalność
