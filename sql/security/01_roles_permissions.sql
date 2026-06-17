-- Bezpieczeństwo podstawowe (RBAC)
-- Zabronienie publicznego dostępu
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA budget FROM PUBLIC;

-- Usunięcie ról w razie przeładowywania skryptu
DROP ROLE IF EXISTS budget_admin;
DROP ROLE IF EXISTS budget_member;
DROP ROLE IF EXISTS budget_viewer;

-- Utworzenie ról aplikacyjnych
CREATE ROLE budget_admin NOLOGIN;
CREATE ROLE budget_member NOLOGIN;
CREATE ROLE budget_viewer NOLOGIN;

-- Udostępnienie schematu 'budget'
GRANT USAGE ON SCHEMA budget TO budget_admin, budget_member, budget_viewer;

-- Prawa dla Administratora: Pełen dostęp
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA budget TO budget_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA budget TO budget_admin;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA budget TO budget_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA budget TO budget_admin;

-- Prawa dla Membera: Zapis, Modyfikacja i Odczyt, Wykonywanie procedur
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA budget TO budget_member;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA budget TO budget_member;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA budget TO budget_member;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA budget TO budget_member;

-- Prawa dla Viewera: Wyłącznie Odczyt (analityka)
GRANT SELECT ON ALL TABLES IN SCHEMA budget TO budget_viewer;

-- Konfiguracja domyślnych uprawnień dla nowo tworzonych tabel
ALTER DEFAULT PRIVILEGES IN SCHEMA budget GRANT ALL PRIVILEGES ON TABLES TO budget_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA budget GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO budget_member;
ALTER DEFAULT PRIVILEGES IN SCHEMA budget GRANT SELECT ON TABLES TO budget_viewer;
