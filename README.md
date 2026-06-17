# 💰 Budżet Domowy - Projekt Bazy Danych

Aplikacja do zarządzania budżetem domowym. Projekt na przedmiot Bazy Danych (semestr VI).

## 🛠 Stos
- **Baza**: PostgreSQL 16+
- **Frontend**: HTML + CSS + JS
- **Docs**: Markdown + Mermaid

## 🚀 Jak zacząć?

### 1. Zainstaluj narzędzia
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) - do uruchomienia bazy lokalnie

### 2. Sklonuj repo
```bash
git clone https://github.com/Janosik8/Bazy-Danych.git
cd Bazy-Danych
```

### 3. Uruchom bazę danych (Docker)
Wystarczy użyć pliku `docker-compose.yml`, który postawi lokalną bazę PostgreSQL (wersja 16) gotową do pracy:
```bash
docker-compose up -d
```
> **Dane dostępowe:**
> - Użytkownik: `budget_user`
> - Hasło: `budget_pass`
> - Nazwa bazy: `budget_db`
> - Port: `5432`
>
> Pamiętaj: Jeśli umieścisz kod SQL w folderze `sql/migrations/` zaczynający się od `001_...` to po usunięciu kontenera i postawieniu go na nowo, skrypty wykonają się same!
> **Ważne:** Docker uruchamia domyślnie TYLKO pliki wrzucone bezpośrednio do `sql/migrations/`. Pliki z innych folderów (np. `sql/views/`, `sql/seed/`) nie uruchomią się same! Jeśli chcemy, by Docker je załadował, musimy zdefiniować w `sql/migrations/` skrypt (np. `.sh` lub `.sql`), który "ściągnie" i odpali resztę, tak jak zrobiliśmy to dla danych testowych.

### Jak wejść do bazy i pisać zapytania (psql)?
Gdy kontener już działa, możesz otworzyć wbudowaną konsolę PostgreSQL (`psql`) wpisując w terminalu:
```bash
docker exec -it budget_postgres psql -U budget_user -d budget_db
```
Będąc w środku konsoli bazy danych, przydadzą Ci się te komendy:
- `\dn` - wyświetla schematy (aby zobaczyć nasz schemat `budget`)
- `SET search_path TO budget;` - **BARDZO WAŻNE:** Musisz to wpisać po wejściu do bazy! Inaczej konsola szuka tabel w domyślnym, pustym schemacie `public` i po wpisaniu `\dt` nie pokaże niczego.
- `\dt` - wyświetla wszystkie tabele (zadziała poprawnie dopiero po ustawieniu `search_path`)
- `\dt budget.*` - alternatywny sposób na zobaczenie naszych tabel bez zmiany `search_path`
- `SELECT * FROM users;` - przykładowe zapytanie (po ustawieniu search_path)
- `\q` - wyjście z konsoli do normalnego terminala

### Co zrobić, gdy pojawią się nowe pliki SQL (migracje)?
Docker ładuje skrypty startowe **tylko raz**, przy pierwszym stworzeniu bazy. Gdy ktoś z zespołu doda nowy plik migracji na GitHuba, a Ty go pobierzesz, musisz zresetować bazę, żeby skrypt się załadował.
Użyj do tego polecenia (flaga `-v` jest bardzo ważna, bo kasuje stary stan bazy):
```bash
docker-compose down -v
docker-compose up -d
```


## 📁 Struktura i Dokumentacja
```
docs/          → Dokumentacja (wymagania, ERD, modele, konwencje)
sql/           → Cały SQL (migracje, widoki, funkcje, triggery...)
```


> 💡 **Jak zobaczyć diagram ERD w VS Code?**
> W pliku `docs/erd.md` użyliśmy formatu **Mermaid**. Aby go zobaczyć jako piękny diagram, zainstaluj wtyczkę do VS Code np. **"Markdown Preview Mermaid Support"** (wtyczka do Mermaid jest natywnie w VSC od wersji 1.121.) lub otwórz plik na GitHubie (który natywnie renderuje Mermaid).

## 👥 Zespół
- @mateog-918
- @Janosik8 
- @PawelKowalcze

