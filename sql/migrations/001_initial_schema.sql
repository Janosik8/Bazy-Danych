-- Tworzenie schematu
CREATE SCHEMA IF NOT EXISTS budget;

-- 1. users
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

-- 2. households
CREATE TABLE budget.households (
    id              SERIAL          PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE budget.households IS 'Gospodarstwa domowe współdzielące budżet';
COMMENT ON COLUMN budget.households.name IS 'Nazwa gospodarstwa domowego';
COMMENT ON COLUMN budget.households.description IS 'Opcjonalny opis gospodarstwa';

-- 3. household_members
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
