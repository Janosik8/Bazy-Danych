# Dokument Inżynierii Wymagań: Aplikacja do Zarządzania Budżetem Domowym

**Wersja:** 1.1 (Zaktualizowana o cele rodzinne)
**Data:** Maj 2026
**Autorzy:** Zespół Projektowy (3 osoby)
**Technologia docelowa:** PostgreSQL

---

## 1. Wstęp
### 1.1. Cel dokumentu
Niniejszy dokument definiuje architekturę, założenia projektowe oraz szczegółowe wymagania (biznesowe, funkcjonalne i niefunkcjonalne) dla systemu bazodanowego wspierającego zarządzanie budżetem domowym. Dokument stanowi podstawę do dalszego projektowania (diagramy ERD), implementacji struktury bazy danych oraz testowania systemu.

### 1.2. Zakres systemu
System bazy danych umożliwi użytkownikom ewidencjonowanie przychodów i wydatków, zarządzanie kategoriami finansowymi, monitorowanie celów oszczędnościowych (indywidualnych oraz grupowych/rodzinnych) oraz generowanie zaawansowanych raportów i prognoz finansowych.

---

## 2. Architektura Systemu
Ze względu na charakter projektu, skupiamy się na **warstwie danych (Data Tier)** w architekturze klient-serwer.
*   **System Zarządzania Bazą Danych (SGBD):** PostgreSQL.
*   **Logika biznesowa bazy:** Zaimplementowana po stronie serwera bazy danych z wykorzystaniem języka `PL/pgSQL` (wyzwalacze, procedury składowane, funkcje).
*   **Warstwa dostępu:** Interfejs realizowany poprzez dedykowane widoki (Views) ułatwiające odpytywanie bazy, z ukryciem złożoności struktury tabel.
*   **Bezpieczeństwo:** Zastosowanie kontroli dostępu opartej na rolach (RBAC - Role-Based Access Control) bezpośrednio w SGBD.

---

## 3. Wymagania Biznesowe (BR - Business Requirements)
*   **BR-01:** System musi pozwalać użytkownikowi na pełną kontrolę nad własnymi finansami poprzez rejestrację każdej operacji finansowej.
*   **BR-02:** System musi wspierać świadome planowanie wydatków poprzez mechanizm celów oszczędnościowych.
*   **BR-03:** Użytkownik musi mieć dostęp do przejrzystych podsumowań (raportów) miesięcznych i rocznych.
*   **BR-04:** Baza danych musi gwarantować spójność rachunkową (saldo konta nie może być modyfikowane w oderwaniu od historii transakcji).
*   **BR-05:** System musi umożliwiać wspólne oszczędzanie poprzez tworzenie "celów rodzinnych" (grupowych), wspieranych finansowo przez wielu domowników.

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

### Obszar 3: Cele Oszczędnościowe (Indywidualne i Rodzinne)
*   **FR-3.1:** Użytkownik może definiować prywatne cele oszczędnościowe, określając kwotę docelową i termin.
*   **FR-3.2:** Rejestracja transakcji przypisanej do prywatnego celu automatycznie powiększa jego zgromadzony kapitał (wymagane użycie **Wyzwalacza / Triggera**).
*   **FR-3.3:** Użytkownik może utworzyć cel oszczędnościowy typu "Rodzinny" i przypisać do niego innych użytkowników systemu (współtwórców).
*   **FR-3.4:** Transakcje przypisane do celu rodzinnego przez *dowolnego* z jego członków automatycznie sumują się we wspólnym saldzie tego celu. System przechowuje informację o tym, ile dany użytkownik wpłacił na wspólny cel.

### Obszar 4: Logika Proceduralna i Zaawansowane Zapytania
*   **FR-4.1:** System musi zawierać widoki (Views) generujące podsumowania, np. miesięczne zestawienie wydatków per kategoria, oraz postęp w realizacji celów rodzinnych ze statystyką wpłat poszczególnych członków.
*   **FR-4.2:** System posiada funkcję/procedurę (`PL/pgSQL`) do realizacji transferu środków między dwoma kontami z zastosowaniem bloku transakcyjnego.
*   **FR-4.3:** Baza danych musi zapobiegać usunięciu kategorii, do której przypisane są historyczne transakcje.

---

## 5. Wymagania Niefunkcjonalne (NFR - Non-Functional Requirements)

### 5.1. Bezpieczeństwo i Uprawnienia
*   **NFR-1.1:** W systemie muszą istnieć co najmniej 3 role: `db_admin`, `db_user`, `db_auditor`.
*   **NFR-1.2:** Zapytania nie mogą ujawniać prywatnych danych innych użytkowników (izolacja logiczna).
*   **NFR-1.3:** Użytkownicy przypisani do wspólnego "celu rodzinnego" mają dostęp do odczytu jego statusu i historii wpłat z nim związanych, ale nie zyskują przez to dostępu do prywatnych kont i pozostałych transakcji innych członków celu.

### 5.2. Spójność i Transakcyjność (ACID)
*   **NFR-2.1:** Przelewy wewnętrzne między kontami muszą być realizowane w jednej transakcji. Błąd aktualizacji jednego konta musi skutkować wycofaniem (ROLLBACK) całej operacji.
*   **NFR-2.2:** Procedury raportujące wykorzystują odpowiednie poziomy izolacji (np. `READ COMMITTED` lub `REPEATABLE READ`).

### 5.3. Normalizacja i Projekt
*   **NFR-3.1:** Schemat relacyjny bazy danych musi bezwzględnie spełniać reguły **Trzeciej Postaci Normalnej (3NF)**. Wymaga to stworzenia m.in. tabeli asocjacyjnej dla celów rodzinnych (relacja wiele-do-wielu między użytkownikami a celami).
*   **NFR-3.2:** Wszystkie relacje (klucze obce - FK) muszą posiadać odpowiednie reguły dla operacji usuwania i aktualizacji.

---

## 6. Planowanie i Organizacja Pracy Zespołu (3 osoby)

| Faza | Czas trwania | Osoba Odpowiedzialna | Główne Zadania do wykonania |
| :--- | :--- | :--- | :--- |
| **1. Analiza i Projektowanie** | Tydzień 1 | Osoba 1 (Architekt) | Przygotowanie diagramu ERD (uwzględniając cele rodzinne), weryfikacja 3NF, skrypty DDL. |
| **2. Logika i Transakcje** | Tydzień 2 | Osoba 2 (Programista) | Procedury, triggery (w tym agregacja wpłat rodzinnych), mock-data. |
| **3. Raportowanie i Testy** | Tydzień 3 | Osoba 3 (Analityk) | Widoki, zaawansowane SELECTy, wdrożenie poziomów izolacji w testach. |
| **4. Integracja i Bezpiecz.**| Tydzień 4 | Osoba 1 & 2 | Konfiguracja ról, testowanie widoczności danych dla celów wspólnych. |
| **5. Dokumentacja Końcowa**| Tydzień 5 | Osoba 3 (Analityk) | Skompletowanie diagramów, opisów, formatowanie raportu. |

---

## 7. Wytyczne do Projektowania Logicznego (Kolejny Krok)
Do przygotowania w następnej kolejności:
1.  **Słownik Danych:** Opis typów danych (np. `NUMERIC(10,2)` dla kwot).
2.  **Tabela asocjacyjna:** Projekt tabeli np. `Uczestnicy_Celu` łączącej `Uzytkownicy` i `Cele_Oszczednosciowe`.
3.  **Diagram ERD:** Wizualizacja zaktualizowanych encji.
4.  **Skrypty DDL:** Translacja ERD na fizyczne tabele w PostgreSQL.