# Słownik pojęć domenowych

## Spis treści

- [Wprowadzenie](#wprowadzenie)
- [Słownik](#słownik)
- [Uwagi](#uwagi)

---

## Wprowadzenie

Niniejszy dokument zawiera słownik pojęć domenowych używanych w projekcie aplikacji do zarządzania budżetem domowym. Każdy termin w języku polskim jest powiązany z odpowiadającą mu nazwą w bazie danych (język angielski, konwencja `snake_case`), co ułatwia komunikację między dokumentacją a kodem SQL.

Wszystkie nazwy tabel, kolumn i obiektów bazodanowych znajdują się w schemacie `budget`.

---

## Słownik

| Termin PL | Termin EN (nazwa w DB) | Definicja |
|---|---|---|
| Gospodarstwo domowe | `household` | Grupa osób współdzielących budżet domowy. Stanowi podstawową jednostkę organizacyjną w systemie. |
| Użytkownik | `user` | Osoba korzystająca z systemu, członek co najmniej jednego gospodarstwa domowego. Posiada własne konto i dane uwierzytelniające. |
| Członek gospodarstwa | `household_member` | Powiązanie użytkownika z gospodarstwem domowym, z określoną rolą (np. właściciel, członek). Relacja wiele-do-wielu między użytkownikami a gospodarstwami. |
| Kategoria | `category` | Klasyfikacja przychodu lub wydatku w strukturze hierarchicznej. Może być kategorią nadrzędną lub podrzędną. |
| Podkategoria | `category` (`parent_category_id`) | Kategoria podrzędna w hierarchii kategorii. Realizowana przez klucz obcy wskazujący na tę samą tabelę (*self-referencing FK*). |
| Przychód | `income` | Wpływ środków finansowych do gospodarstwa domowego (np. wynagrodzenie, premia, zwrot). |
| Wydatek | `expense` | Wypływ środków finansowych z gospodarstwa domowego (np. zakupy, rachunki, opłaty). |
| Budżet | `budget` | Planowany limit wydatków przypisany do określonej kategorii w danym miesiącu. Służy do kontroli finansów. |
| Raport | `report` | Automatycznie generowane podsumowanie finansowe za wybrany okres rozliczeniowy (miesiąc, kwartał, rok). |
| Prognoza | `forecast` | Przewidywanie przyszłych wydatków lub przychodów na podstawie danych historycznych i trendów. |
| Cel oszczędnościowy | `savings_goal` | Cel finansowy z docelową kwotą i terminem realizacji. Umożliwia śledzenie postępu oszczędzania. |
| Transakcja cykliczna | `recurring_transaction` | Automatycznie powtarzający się przychód lub wydatek, realizowany w określonych odstępach czasu (np. czynsz co miesiąc, subskrypcja co rok). |
| Alert budżetowy | `budget_alert` | Powiadomienie generowane automatycznie przy przekroczeniu ustalonego progu wydatków w ramach budżetu danej kategorii. |
| Bilans | *wartość obliczana* | Różnica między sumą przychodów a sumą wydatków w danym okresie rozliczeniowym. Nie jest przechowywany bezpośrednio w tabeli — obliczany przez widoki i funkcje. |
| Okres rozliczeniowy | *parametr zapytań* | Jednostka czasu używana do raportowania i analizy finansowej: miesiąc, kwartał lub rok. Definiowany jako zakres dat w zapytaniach. |
| Próg alertu | `alert_threshold` | Wartość procentowa budżetu (np. 80%), po której przekroczeniu system wyzwala alert budżetowy. |
| Schemat bazy | `budget` (schema) | Schemat PostgreSQL używany w projekcie zamiast domyślnego schematu `public`. Wszystkie tabele i obiekty bazodanowe są tworzone w tym schemacie. |

---

## Uwagi

> [!NOTE]
> Konwencje nazewnictwa są opisane w pliku `docs/conventions.md`.

- Nazwy tabel są w języku angielskim, w liczbie mnogiej i w konwencji `snake_case` (np. `expenses`, `categories`).
- Nazwy kolumn są w języku angielskim i w konwencji `snake_case` (np. `created_at`, `user_id`).
- Klucze obce mają format `nazwa_tabeli_id` w liczbie pojedynczej (np. `category_id`, `household_id`).
- Wszystkie obiekty bazodanowe znajdują się w schemacie `budget`.
