# Wymagania niefunkcjonalne

## Spis treści

1. [Wprowadzenie](#wprowadzenie)
2. [NF-01: Bezpieczeństwo](#nf-01-bezpieczeństwo)
3. [NF-02: Integralność danych](#nf-02-integralność-danych)
4. [NF-03: Normalizacja](#nf-03-normalizacja)
5. [NF-04: Audytowalność](#nf-04-audytowalność)
6. [NF-05: Dostępność](#nf-05-dostępność)
7. [NF-06: Przenoszalność](#nf-06-przenoszalność)
8. [Podsumowanie](#podsumowanie)

---

## Wprowadzenie

Niniejszy dokument opisuje wymagania niefunkcjonalne systemu zarządzania budżetem domowym. Wymagania te definiują oczekiwane cechy jakościowe bazy danych — w zakresie bezpieczeństwa, integralności, normalizacji, audytowalności, dostępności oraz przenoszalności. Każde wymaganie posiada unikalny identyfikator, opis oraz mierzalne kryteria akceptacji.

---

## NF-01: Bezpieczeństwo

**Identyfikator:** NF-01
**Nazwa:** Bezpieczeństwo dostępu do danych
**Priorytet:** Wysoki

### Opis

System musi implementować wielopoziomowy model bezpieczeństwa oparty na rolach PostgreSQL, mechanizmie Row Level Security (RLS) oraz granularnych uprawnieniach. Użytkownicy mogą widzieć i modyfikować wyłącznie dane przypisane do ich gospodarstwa domowego.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Role PostgreSQL | 3 role: `admin`, `household_member`, `viewer` | Przegląd ról w klastrze PostgreSQL |
| Row Level Security (RLS) | Włączone na wszystkich tabelach z danymi użytkowników | `SELECT relname, relrowsecurity FROM pg_class` |
| Uprawnienia `GRANT`/`REVOKE` | Skonfigurowane na poziomie tabel i widoków | `\dp` w `psql` dla schematu `budget` |
| Bezpieczne przechowywanie | Hashowanie haseł (opcjonalnie) | Mechanizm pgcrypto lub poleganie na warstwie logiki aplikacji |

### Wymagane działania

- Utworzenie ról: `budget_admin`, `budget_member`, `budget_viewer`
- Włączenie RLS (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`) na tabelach zawierających dane gospodarstw
- Definiowanie polityk RLS filtrujących po `household_id`
- Konfiguracja uprawnień `GRANT SELECT` dla roli `viewer`, `GRANT SELECT, INSERT, UPDATE, DELETE` dla roli `household_member`

---

## NF-02: Integralność danych

**Identyfikator:** NF-02
**Nazwa:** Integralność i spójność danych
**Priorytet:** Wysoki

### Opis

Baza danych musi gwarantować integralność danych na poziomie schematu poprzez odpowiednie ograniczenia (`CHECK`, `FOREIGN KEY`, `UNIQUE`) oraz mechanizmy transakcyjne. Żadna operacja nie może pozostawić bazy w niespójnym stanie.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Ograniczenia `CHECK` | Zdefiniowane dla kolumn kwotowych i procentowych | Przegląd ograniczeń w `information_schema` |
| Klucze obce (`FOREIGN KEY`) | Odpowiednie akcje `ON DELETE` (CASCADE/RESTRICT) | Przegląd definicji kluczy obcych |
| Transakcje | Wszystkie operacje wielotabelowe w blokach `BEGIN...COMMIT` | Przegląd procedur i funkcji PL/pgSQL |
| Ograniczenia `UNIQUE` | Zdefiniowane tam, gdzie wymagana unikalność | Przegląd ograniczeń w schemacie |

### Wymagane działania

- Dodanie `CHECK (amount > 0)` do tabel `expenses` i `incomes`
- Ustawienie `ON DELETE CASCADE` dla relacji podrzędnych (np. transakcje użytkownika)
- Ustawienie `ON DELETE RESTRICT` dla relacji, gdzie usunięcie rekordu nadrzędnego powinno być zablokowane (np. kategorie z przypisanymi wydatkami)
- Dodanie `UNIQUE` na kolumnach wymagających unikalności (np. adres e-mail użytkownika)

---

## NF-03: Normalizacja

**Identyfikator:** NF-03
**Nazwa:** Normalizacja struktury bazy danych
**Priorytet:** Wysoki

### Opis

Wszystkie tabele w schemacie `budget` muszą być znormalizowane do trzeciej postaci normalnej (3NF). Eliminuje to redundancję danych, zapobiega anomaliom aktualizacji, wstawiania i usuwania oraz zapewnia logiczną spójność modelu danych.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Pierwsza postać normalna (1NF) | Wszystkie tabele spełniają 1NF | Przegląd schematu — brak kolumn wielowartościowych |
| Druga postać normalna (2NF) | Wszystkie tabele spełniają 2NF | Przegląd zależności od klucza głównego |
| Trzecia postać normalna (3NF) | Wszystkie tabele spełniają 3NF | Brak zależności przechodnich |
| Redundancja danych | Brak | Analiza powtarzalności danych w tabelach |

### Wymagane działania

- Wydzielenie kategorii do osobnej tabeli `categories` (zamiast przechowywania nazw kategorii w tabelach transakcji)
- Wydzielenie gospodarstw domowych do tabeli `households`
- Wydzielenie walut, typów transakcji i innych słowników do osobnych tabel (jeśli dotyczy)
- Weryfikacja braku zależności przechodnich we wszystkich tabelach

---

## NF-04: Audytowalność

**Identyfikator:** NF-04
**Nazwa:** Audytowalność zmian w danych
**Priorytet:** Średni

### Opis

System musi umożliwiać śledzenie, kiedy dane zostały utworzone i ostatnio zmodyfikowane. Każda tabela powinna zawierać znaczniki czasowe tworzenia i aktualizacji rekordów, aktualizowane automatycznie przez wyzwalacze bazodanowe.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Kolumna `created_at` | Obecna w każdej tabeli | Przegląd schematu `budget` |
| Kolumna `updated_at` | Obecna w tabelach modyfikowalnych | Przegląd schematu `budget` |
| Automatyczna aktualizacja `updated_at` | Wyzwalacz `BEFORE UPDATE` na każdej tabeli z `updated_at` | Przegląd wyzwalaczy w schemacie |
| Typ danych znaczników czasowych | `TIMESTAMPTZ` z wartością domyślną `NOW()` | Przegląd definicji kolumn |

### Wymagane działania

- Dodanie kolumny `created_at TIMESTAMPTZ DEFAULT NOW()` do każdej tabeli
- Dodanie kolumny `updated_at TIMESTAMPTZ DEFAULT NOW()` do tabel, w których rekordy mogą być modyfikowane
- Utworzenie funkcji PL/pgSQL ustawiającej `NEW.updated_at = NOW()`
- Utworzenie wyzwalaczy `BEFORE UPDATE` wywołujących tę funkcję na odpowiednich tabelach

---

## NF-05: Dostępność

**Identyfikator:** NF-05
**Nazwa:** Dostępność i niezawodność systemu
**Priorytet:** Średni

### Opis

System musi zapewniać niezawodny dostęp do danych oraz spójność operacji współbieżnych. Mechanizmy transakcyjne PostgreSQL gwarantują właściwości ACID, a odpowiedni dobór poziomów izolacji minimalizuje ryzyko anomalii współbieżności.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Właściwości ACID | Pełne wsparcie | Testy transakcji z `ROLLBACK` |
| Poziomy izolacji | Obsługa `READ COMMITTED` i `SERIALIZABLE` | Testy z `SET TRANSACTION ISOLATION LEVEL` |
| Obsługa deadlocków | Automatyczne wykrywanie i rollback | Symulacja deadlocka w testach |

### Wymagane działania

- Użycie `READ COMMITTED` jako domyślnego poziomu izolacji
- Użycie `SERIALIZABLE` dla operacji wymagających eliminacji anomalii (Phantom Reads)
- Przygotowanie przykładów transakcji demonstrujących różne poziomy izolacji w katalogu `sql/transactions/`

---

## NF-06: Przenoszalność

**Identyfikator:** NF-06
**Nazwa:** Przenoszalność i utrzymywalność kodu SQL
**Priorytet:** Niski

### Opis

Kod SQL powinien być w miarę możliwości zgodny ze standardem SQL, aby ułatwić ewentualną migrację lub zrozumienie przez osoby niezaznajomione z PostgreSQL. Logika specyficzna dla PostgreSQL (np. PL/pgSQL, RLS, rozszerzenia) powinna być wyraźnie wyodrębniona i udokumentowana.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Standardowy SQL | Używany wszędzie, gdzie to możliwe | Przegląd kodu SQL |
| PL/pgSQL | Ograniczony do logiki wymagającej rozszerzeń PostgreSQL | Przegląd funkcji i procedur |
| Migracje SQL | Numerowane pliki w katalogu `sql/migrations/` | Przegląd struktury katalogów |

### Wymagane działania

- Stosowanie standardowego SQL (`ANSI SQL`) dla zapytań i definicji tabel
- Wyodrębnienie logiki PL/pgSQL do dedykowanych plików w katalogu `sql/functions/` i `sql/procedures/`
- Numerowanie plików migracji w formacie `NNN_opis.sql` (np. `001_initial_schema.sql`)

---

## Podsumowanie

Poniższa tabela zawiera zestawienie wszystkich wymagań niefunkcjonalnych dla projektu zarządzania budżetem:

| ID | Nazwa | Priorytet | Kategoria |
|---|---|---|---|
| NF-01 | Bezpieczeństwo | Wysoki | Bezpieczeństwo |
| NF-02 | Integralność danych | Wysoki | Integralność |
| NF-03 | Normalizacja | Wysoki | Struktura danych |
| NF-04 | Audytowalność | Średni | Audyt |
| NF-05 | Dostępność | Średni | Niezawodność |
| NF-06 | Przenoszalność | Niski | Utrzymywalność |
