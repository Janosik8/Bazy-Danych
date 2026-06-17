#!/bin/bash
set -e

echo "=== Ładowanie ustawień bezpieczeństwa (RBAC & RLS) ==="

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/security/01_roles_permissions.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/security/02_row_level_security.sql"

echo "=== Zakończono ładowanie ustawień bezpieczeństwa ==="