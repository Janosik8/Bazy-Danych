# Wymagania niefunkcjonalne

## Spis treści

1. [Wprowadzenie](#wprowadzenie)
2. [NF-01: Wydajność](#nf-01-wydajność)
3. [NF-02: Bezpieczeństwo](#nf-02-bezpieczeństwo)
4. [NF-03: Integralność danych](#nf-03-integralność-danych)
5. [NF-04: Normalizacja](#nf-04-normalizacja)
6. [NF-05: Skalowalność](#nf-05-skalowalność)
7. [NF-06: Audytowalność](#nf-06-audytowalność)
8. [NF-07: Dostępność](#nf-07-dostępność)
9. [NF-08: Przenoszalność](#nf-08-przenoszalność)
10. [Podsumowanie](#podsumowanie)

---

## Wprowadzenie

Niniejszy dokument opisuje wymagania niefunkcjonalne systemu zarządzania budżetem domowym. Wymagania te definiują oczekiwane cechy jakościowe bazy danych — w zakresie wydajności, bezpieczeństwa, integralności, normalizacji, skalowalności, audytowalności, dostępności oraz przenoszalności. Każde wymaganie posiada unikalny identyfikator, opis oraz mierzalne kryteria akceptacji.

---

## NF-01: Wydajność

**Identyfikator:** NF-01
**Nazwa:** Wydajność zapytań i operacji bazodanowych
**Priorytet:** Wysoki

### Opis

System musi zapewniać odpowiednio krótkie czasy odpowiedzi dla różnych typów zapytań SQL. Wydajność jest kluczowa dla komfortu użytkowania aplikacji — zarówno przy codziennym przeglądaniu transakcji, jak i przy generowaniu raportów agregacyjnych.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Zapytanie `SELECT` na pojedynczej tabeli | < 100 ms | `EXPLAIN ANALYZE` na tabeli z danymi testowymi |
| Zapytanie z `JOIN` (do 3 tabel) | < 500 ms | `EXPLAIN ANALYZE` na zapytaniu wielotabelowym |
| Raporty agregacyjne (`GROUP BY`, funkcje okna) | < 2 s | `EXPLAIN ANALYZE` na zapytaniach raportowych |
| Indeksowanie kolumn kluczowych | 100% pokrycie | Przegląd indeksów w schemacie `budget` |

### Wymagane działania

- Utworzenie indeksów na kolumnach kluczy obcych (`category_id`, `user_id`, `household_id`)
- Utworzenie indeksów na kolumnach dat (`created_at`, `expense_date`, `income_date`)
- Utworzenie indeksów na kolumnie `household_id` we wszystkich tabelach, w których występuje
- Wykorzystanie widoków materializowanych dla często używanych raportów agregacyjnych

---

## NF-02: Bezpieczeństwo

**Identyfikator:** NF-02
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
| Hashowanie haseł | Realizowane przez rozszerzenie `pgcrypto` | Test funkcji `crypt()` i `gen_salt()` |

### Wymagane działania

- Utworzenie ról: `budget_admin`, `budget_household_member`, `budget_viewer`
- Włączenie RLS (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`) na tabelach zawierających dane gospodarstw
- Definiowanie polityk RLS filtrujących po `household_id`
- Konfiguracja uprawnień `GRANT SELECT` dla roli `viewer`, `GRANT SELECT, INSERT, UPDATE, DELETE` dla roli `household_member`
- Instalacja rozszerzenia `pgcrypto` i użycie funkcji `crypt()` do hashowania haseł

---

## NF-03: Integralność danych

**Identyfikator:** NF-03
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
- Dodanie `CHECK (threshold BETWEEN 0 AND 100)` do tabel z progami alertów
- Ustawienie `ON DELETE CASCADE` dla relacji podrzędnych (np. transakcje użytkownika)
- Ustawienie `ON DELETE RESTRICT` dla relacji, gdzie usunięcie rekordu nadrzędnego powinno być zablokowane (np. kategorie z przypisanymi wydatkami)
- Dodanie `UNIQUE` na kolumnach wymagających unikalności (np. adres e-mail użytkownika)

---

## NF-04: Normalizacja

**Identyfikator:** NF-04
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

## NF-05: Skalowalność

**Identyfikator:** NF-05
**Nazwa:** Skalowalność bazy danych
**Priorytet:** Średni

### Opis

System powinien być przygotowany na wzrost ilości danych w czasie. Tabele transakcyjne (`expenses`, `incomes`) mogą rosnąć znacząco — szczególnie w gospodarstwach domowych z wieloma członkami. Mechanizmy takie jak partycjonowanie, widoki materializowane i indeksy powinny zapewniać stabilną wydajność niezależnie od rozmiaru danych.

### Kryteria akceptacji

| Metryka | Wartość docelowa | Sposób weryfikacji |
|---|---|---|
| Partycjonowanie tabel transakcyjnych | Opcjonalnie — wg roku (`PARTITION BY RANGE`) | Przegląd definicji tabel |
| Widoki materializowane | Utworzone dla raportów agregacyjnych | `\dm` w `psql` |
| Indeksy na kolumnach filtrowanych | Pokrycie wszystkich kolumn używanych w `WHERE` i `JOIN` | `\di` w `psql` |

### Wymagane działania

- Rozważenie partycjonowania tabel `expenses` i `incomes` według roku (`expense_date`, `income_date`)
- Utworzenie widoków materializowanych dla raportów miesięcznych i rocznych
- Okresowe odświeżanie widoków materializowanych (`REFRESH MATERIALIZED VIEW`)
- Dodanie indeksów na wszystkich kolumnach występujących w klauzulach `WHERE` i `JOIN`

---

## NF-06: Audytowalność

**Identyfikator:** NF-06
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
- Utworzenie funkcji PL/pgSQL `budget.update_updated_at()` ustawiającej `NEW.updated_at = NOW()`
- Utworzenie wyzwalaczy `BEFORE UPDATE` wywołujących tę funkcję na odpowiednich tabelach

---

## NF-07: Dostępność

**Identyfikator:** NF-07
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
| Obsługa błędów | Bloki `EXCEPTION` w procedurach PL/pgSQL | Przegląd kodu procedur |

### Wymagane działania

- Implementacja bloków `BEGIN...EXCEPTION...END` w procedurach i funkcjach PL/pgSQL
- Użycie `READ COMMITTED` jako domyślnego poziomu izolacji
- Użycie `SERIALIZABLE` dla krytycznych operacji (np. przeliczanie sald, cele oszczędnościowe)
- Przygotowanie przykładów transakcji demonstrujących różne poziomy izolacji w katalogu `sql/transactions/`
- Dokumentacja scenariuszy obsługi deadlocków i automatycznego rollbacku

---

## NF-08: Przenoszalność

**Identyfikator:** NF-08
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
| Komentarze | W języku polskim, wyjaśniające logikę biznesową | Przegląd kodu SQL |

### Wymagane działania

- Stosowanie standardowego SQL (`ANSI SQL`) dla zapytań i definicji tabel
- Wyodrębnienie logiki PL/pgSQL do dedykowanych plików w katalogu `sql/functions/` i `sql/procedures/`
- Numerowanie plików migracji w formacie `NNN_opis.sql` (np. `001_create_schema.sql`)
- Dodawanie komentarzy w języku polskim do każdego pliku SQL, wyjaśniających cel i logikę biznesową

---

## Podsumowanie

Poniższa tabela zawiera zestawienie wszystkich wymagań niefunkcjonalnych:

| ID | Nazwa | Priorytet | Kategoria |
|---|---|---|---|
| NF-01 | Wydajność | Wysoki | Wydajność |
| NF-02 | Bezpieczeństwo | Wysoki | Bezpieczeństwo |
| NF-03 | Integralność danych | Wysoki | Integralność |
| NF-04 | Normalizacja | Wysoki | Struktura danych |
| NF-05 | Skalowalność | Średni | Skalowalność |
| NF-06 | Audytowalność | Średni | Audyt |
| NF-07 | Dostępność | Średni | Niezawodność |
| NF-08 | Przenoszalność | Niski | Utrzymywalność |

> [!NOTE]
> Wymagania o priorytecie **Wysoki** muszą zostać spełnione przed oddaniem projektu. Wymagania o priorytecie **Średni** i **Niski** są realizowane w miarę dostępnego czasu i zasobów.
