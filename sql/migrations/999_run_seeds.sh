#!/bin/bash
set -e

echo "=== Uruchamianie skryptów seed (dane testowe) ==="

for f in /app/sql/seed/*.sql; do
    if [ -f "$f" ]; then
        echo "Wykonuję: $f"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
    fi
done

echo "=== Zakończono generowanie danych testowych ==="