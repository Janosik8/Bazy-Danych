#!/bin/bash
set -e

echo "=== Ładowanie wyzwalaczy, funkcji i procedur (Phase 4) ==="

# Ładowanie funkcji
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/functions/01_utility_functions.sql"

# Ładowanie wyzwalaczy
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/triggers/01_updated_at_triggers.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/triggers/02_budget_alert_trigger.sql"

# Ładowanie procedur
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/procedures/01_process_recurring_transactions.sql"

echo "=== Zakończono ładowanie logiki proceduralnej ==="