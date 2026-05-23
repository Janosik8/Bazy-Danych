# 💰 Budżet Domowy - Projekt Bazy Danych

Aplikacja do zarządzania budżetem domowym. Projekt na przedmiot Bazy Danych (semestr VI).

## 🛠 Stos
- **Baza**: PostgreSQL 16+
- **Frontend**: HTML + CSS + JS
- **Docs**: Markdown + Mermaid

## 🚀 Jak zacząć?

### 1. Zainstaluj narzędzia
- [PostgreSQL 16+](https://www.postgresql.org/download/)
- [Antigravity CLI](https://github.com/google-gemini/antigravity-cli) - nasz agent AI
- [GitHub CLI](https://cli.github.com/) - do issues

### 2. Sklonuj repo
```bash
git clone https://github.com/Janosik8/Bazy-Danych.git
cd Bazy-Danych
```

### 3. AI-Driven Workflow
Ten projekt jest prowadzony z agentem AI (Antigravity CLI). Każdy członek zespołu:

1. **Otwiera terminal** w katalogu repo
2. **Uruchamia** `agy` (Antigravity CLI)
3. **Agent automatycznie ładuje kontekst** z `GEMINI.md` - wie co to za projekt
4. **Bierze issue z GitHub** i mówi agentowi co ma zrobić
5. Agent tworzy kod, dokumentację, SQL - w odpowiednich katalogach

> 💡 **Tip**: Agent rozumie cały kontekst projektu. Wystarczy powiedzieć np. "Zrób issue #12" i on wie co robić.

### 4. Workflow krok po kroku
```
1. Sprawdź issues:        gh issue list
2. Przypisz się:          gh issue edit <nr> --add-assignee @me
3. Utwórz branch:         git checkout -b feature/<nr>-opis
4. Odpal agenta:          agy
5. Powiedz mu co robić:   "Zrób zadanie z issue #<nr>"
6. Commit + Push:          git add . && git commit -m "..." && git push
7. Utwórz PR:             gh pr create
```

## 📁 Struktura i Dokumentacja
```
docs/          → Dokumentacja (wymagania, ERD, modele, konwencje)
sql/           → Cały SQL (migracje, widoki, funkcje, triggery...)
frontend/      → Prosty frontend
```

### Dokumentacja - co czytać?
- **Dla developera**: Przede wszystkim `docs/requirements.md` (wymagania funkcjonalne) oraz `docs/conventions.md` (konwencje projektowe). Warto też zerknąć na `docs/erd.md` dla ogólnego zarysu struktury.
- **Dla agenta AI**: Agent wykorzystuje wszystkie pliki, ale szczególnie polega na szczegółowych plikach jak `logical-model.md` czy `physical-model.md`, które opisują relacje, typy i 3NF w bazie.

> 💡 **Jak zobaczyć diagram ERD w VS Code?**
> W pliku `docs/erd.md` użyliśmy formatu **Mermaid**. Aby go zobaczyć jako piękny, zainstaluj wtyczkę do VS Code np. **"Markdown Preview Mermaid Support"** (wtyczka do Mermaid jest natywnie w VSC od wersji 1.121.) lub otwórz plik na GitHubie (który natywnie renderuje Mermaid).

## 👥 Zespół
- Osoba A - @mateog-918
- Osoba B - @Janosik8 
- Osoba C - @PawelKowalcze

## 📋 Issues
Wszystkie zadania są na [GitHub Issues](https://github.com/Janosik8/Bazy-Danych/issues). Bierz po kolei, przypisuj się, rób.
