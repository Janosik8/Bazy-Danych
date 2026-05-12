# Dokument Inżynierii Wymagań: Aplikacja do Zarządzania Budżetem Domowym

**Wersja:** 1.0
**Data:** Maj 2026
**Autorzy:** Zespół Projektowy (3 osoby)
**Technologia docelowa:** PostgreSQL

---

## 1. Wstęp
### 1.1. Cel dokumentu
Niniejszy dokument definiuje architekturę, założenia projektowe oraz szczegółowe wymagania (biznesowe, funkcjonalne i niefunkcjonalne) dla systemu bazodanowego wspierającego zarządzanie budżetem domowym. Dokument stanowi podstawę do dalszego projektowania (diagramy ERD), implementacji struktury bazy danych oraz testowania systemu.

### 1.2. Zakres systemu
System bazy danych umożliwi użytkownikom ewidencjonowanie przychodów i wydatków, zarządzanie kategoriami finansowymi, monitorowanie celów oszczędnościowych oraz generowanie zaawansowanych raportów i prognoz finansowych.

---

## 2. Architektura Systemu
Ze względu na charakter projektu, skupiamy się na **warstwie danych (Data Tier)** w architekturze klient-serwer.
*   **System Zarządzania Bazą Danych (SGBD):** PostgreSQL.
*   **Logika biznesowa bazy:** Zaimplementowana po stronie serwera bazy danych z wykorzystaniem języka `PL/pgSQL` (wyzwalacze, procedury składowane, funkcje).
*   **Warstwa dostępu:** Interfejs realizowany poprzez dedykowane widoki (Views) ułatwiające odpytywanie bazy, z ukryciem złożoności struktury tabel (abstrakcja danych).
*   **Bezpieczeństwo:** Zastosowanie kontroli dostępu opartej na rolach (RBAC - Role-Based Access Control) bezpośrednio w SGBD.

---

## 3. Wymagania Biznesowe (BR - Business Requirements)
*   **BR-01:** System musi pozwalać użytkownikowi na pełną kontrolę nad własnymi finansami poprzez rejestrację każdej operacji finansowej.
*   **BR-02:** System musi wspierać świadome planowanie wydatków poprzez mechanizm celów oszczędnościowych.
*   **BR-03:** Użytkownik musi mieć dostęp do przejrzystych podsumowań (raportów) miesięcznych i rocznych.
*   **BR-04:** Baza danych musi gwarantować spójność rachunkową (saldo konta nie może być modyfikowane w oderwaniu od historii transakcji).

---

## 4. Wymagania Funkcjonalne (FR - Functional Requirements)

### Obszar 1: Zarządzanie Użytkownikami i Kontami
*   **FR-1.1:** System przechowuje dane użytkowników (imię, nazwisko, unikalny adres e-mail).
*   **FR-1.2:** Użytkownik może posiadać wiele kont bankowych/portfeli (np. gotówka, konto oszczędnościowe, karta kredytowa).
*   **FR-1.3:** Każde konto ma zdefiniowane saldo początkowe oraz aktualizowane na bieżąco saldo bieżące.

### Obszar 2: Kategoryzacja i Transakcje
*   **FR-2.1:** System przechowuje słownik kategorii finansowych podzielonych na przychody i wydatki.
*   **FR-2.2:** System umożliwia dodawanie transakcji (przychód/wydatek) powiązanych z konkretnym kontem, datą i kategorią.
*   **FR-2.3:** Dodanie nowej transakcji musi automatycznie aktualizować saldo przypisanego konta (wymagane użycie **Wyzwalacza / Triggera**).

### Obszar 3: Cele Oszczędnościowe (Funkcjonalność dodatkowa)
*   **FR-3.1:** Użytkownik może definiować cele oszczędnościowe, określając kwotę docelową i termin.
*   **FR-3.2:** Rejestracja transakcji w specjalnej kategorii "Oszczędności" przypisanej do celu, automatycznie powiększa zgromadzony kapitał w tabeli Celów (wymagane użycie **Wyzwalacza / Triggera**).

### Obszar 4: Logika Proceduralna i Zaawansowane Zapytania
*   **FR-4.1:** System musi zawierać widoki (Views) generujące podsumowania, np. miesięczne zestawienie wydatków per kategoria dla każdego użytkownika.
*   **FR-4.2:** System posiada funkcję/procedurę (`PL/pgSQL`) do realizacji transferu środków między dwoma kontami tego samego użytkownika z zastosowaniem bloku transakcyjnego.
*   **FR-4.3:** Baza danych musi zapobiegać (poprzez Constraint lub Trigger) usunięciu kategorii, do której przypisane są historyczne transakcje.

---

## 5. Wymagania Niefunkcjonalne (NFR - Non-Functional Requirements)

### 5.1. Bezpieczeństwo i Uprawnienia
*   **NFR-1.1:** W systemie muszą istnieć co najmniej 3 role: `db_admin` (pełny dostęp, DDL), `db_user` (dostęp do operacji DML - INSERT, UPDATE, SELECT na własnych danych), `db_auditor` (tylko odczyt, SELECT na widokach raportowych).
*   **NFR-1.2:** Zapytania nie mogą ujawniać danych innych użytkowników (izolacja logiczna na poziomie zapytań/widoków).

### 5.2. Spójność i Transakcyjność (ACID)
*   **NFR-2.1:** Przelewy wewnętrzne między kontami muszą być realizowane w jednej transakcji. Błąd aktualizacji jednego konta musi skutkować wycofaniem (ROLLBACK) całej operacji.
*   **NFR-2.2:** Wybrane, krytyczne procedury (np. zamknięcie miesiąca, generowanie prognozy) muszą wykorzystywać określone poziomy izolacji (np. `REPEATABLE READ` lub `SERIALIZABLE`), aby uniknąć anomalii współbieżności.

### 5.3. Normalizacja i Projekt
*   **NFR-3.1:** Schemat relacyjny bazy danych musi bezwzględnie spełniać reguły **Trzeciej Postaci Normalnej (3NF)**.
*   **NFR-3.2:** Wszystkie relacje (klucze obce - FK) muszą posiadać odpowiednie reguły dla operacji usuwania i aktualizacji (np. `ON DELETE CASCADE` lub `ON DELETE RESTRICT`).

---

## 6. Planowanie i Organizacja Pracy Zespołu (3 osoby)

| Faza | Czas trwania | Osoba Odpowiedzialna | Główne Zadania do wykonania |
| :--- | :--- | :--- | :--- |
| **1. Analiza i Projektowanie** | Tydzień 1 | Osoba 1 (Architekt) | Przygotowanie diagramu ERD, weryfikacja 3NF, skrypty DDL. |
| **2. Logika i Transakcje** | Tydzień 2 | Osoba 2 (Programista) | Procedury, triggery, pisanie skryptów transakcyjnych i mock-data. |
| **3. Raportowanie i Testy** | Tydzień 3 | Osoba 3 (Analityk) | Widoki, zaawansowane SELECTy, wdrożenie poziomów izolacji w testach. |
| **4. Integracja i Bezpiecz.**| Tydzień 4 | Osoba 1 & 2 | Konfiguracja ról użytkowników, testy całościowe logiki. |
| **5. Dokumentacja Końcowa**| Tydzień 5 | Osoba 3 (Analityk) | Skompletowanie diagramów, opisów, formatowanie raportu. |

---

## 7. Wytyczne do Projektowania Logicznego (Kolejny Krok)
Do przygotowania w następnej kolejności:
1.  **Słownik Danych:** Opis typów danych dla każdej kolumny (np. kwoty jako `NUMERIC(10,2)` zamiast `FLOAT` dla dokładności finansowej).
2.  **Diagram ERD:** Wizualizacja encji opisanych w FR-1 do FR-3.
3.  **Skrypty DDL:** Translacja ERD na fizyczne tabele w PostgreSQL.