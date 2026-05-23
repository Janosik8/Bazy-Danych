#!/bin/bash
set -e

echo "=== Ładowanie widoków (Views) ==="

# Tworzenie standardowych widoków
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/views/01_v_monthly_balance.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/views/02_v_category_expenses.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/views/03_v_budget_utilization.sql"

# Tworzenie widoków rocznych
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/app/sql/views/04_v_yearly_summary.sql"

echo "=== Zakończono ładowanie widoków ==="