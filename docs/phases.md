# Harmonogram i Fazy Projektu (Phases)

Dokument opisuje podział całego projektu bazy danych na logiczne etapy (fazy). 
Podział ten pomaga w zarządzaniu zadaniami na platformie GitHub (poprzez etykiety i szablony) oraz umożliwia równoległą pracę całego zespołu.

## Faza 0: Setup (Konfiguracja początkowa)
**Status: Zakończona**
- Inicjalizacja repozytorium Git.
- Utworzenie struktury katalogów (podział na `docs/`, `sql/migrations/`, `sql/views/` itp.).
- Dodanie kontenera Docker (`docker-compose.yml`) z serwerem PostgreSQL 16.
- Skonfigurowanie szablonów GitHub Issues oraz kontekstu dla agenta AI (`GEMINI.md`, `conventions.md`).

## Faza 1: Analiza i projektowanie
**Status: Zakończona**
- Zbieranie i spisanie wymagań funkcjonalnych oraz niefunkcjonalnych.
- Przygotowanie słownika pojęć domenowych (mapowanie PL-EN).
- Narysowanie schematu ERD w formacie Mermaid.
- Udowodnienie III Postaci Normalnej (3NF) w modelu logicznym.
- Rozpisanie modelu fizycznego pod konkretne typy PostgreSQL.

## Faza 2: Implementacja schematu
**Status: W trakcie**
- Przełożenie modelu fizycznego na pierwsze skrypty migracyjne DDL (`CREATE TABLE`).
- Zbudowanie powiązań między tabelami (`FOREIGN KEY`, klucze samoreferujące).
- Skonfigurowanie bazowych restrykcji (`CHECK`, `UNIQUE`, `DEFAULT`).
- Optymalizacja struktury (zakładanie indeksów `B-tree`).
- Przygotowanie skryptów z danymi startowymi (tzw. _Seed Data_ - ułatwiającymi rozwój bazy w kolejnych etapach).

## Faza 3: Widoki i zapytania
**Status: Do zrobienia**
- Stworzenie standardowych widoków (`VIEW`), np. bilans miesięczny, podsumowanie wydatków wg kategorii.
- Skonfigurowanie widoków materializowanych (`MATERIALIZED VIEW`) dla cięższych analiz (np. roczne trendy).
- Opracowanie zaawansowanych zapytań SQL analitycznych z użyciem zapytań zagnieżdżonych i funkcji okna (`WINDOW FUNCTIONS`), m.in. na potrzeby zaliczenia.

## Faza 4: Funkcje, wyzwalacze, procedury (PL/pgSQL)
**Status: Do zrobienia**
- Wdrożenie procedur składowanych realizujących konkretną logikę biznesową (np. odpalanie cyklicznych płatności).
- Oprogramowanie wyzwalaczy (`TRIGGERS`) – np. automatyczne weryfikowanie i powiadamianie o przekroczeniu alertu budżetowego przy dodaniu wydatku (`INSERT` w `expenses`).
- Pisanie własnych funkcji matematycznych/agregujących.

## Faza 5: Bezpieczeństwo i transakcje
**Status: Do zrobienia**
- Ustawienie ról w PostgreSQL (`admin`, `household_member`, `viewer`) z prawami dostępu `GRANT`/`REVOKE`.
- Implementacja **Row Level Security (RLS)**, aby członkowie jednego gospodarstwa nie widzieli finansów drugiego gospodarstwa.
- Przygotowanie skryptów demonstrujących radzenie sobie z zakleszczeniami (deadlocks).
- Testowanie różnych poziomów izolacji transakcji (np. `READ COMMITTED`, `SERIALIZABLE`).

## Faza 6: Frontend
**Status: Do zrobienia**
- Napisanie prostego interfejsu w HTML/CSS/JS (opcjonalny punkt integrujący bazę z warstwą wizualną).
- Prezentacja wykresów, formularze dodawania wydatków.

## Faza 7: Dokumentacja końcowa
**Status: Do zrobienia**
- Sprawozdanie końcowe z projektu.
- Spisanie napotkanych problemów.
- Aktualizacja instrukcji wdrożeniowej w `README.md`.
