-- Wyłączenie powiadomień podczas wstawiania danych
SET client_min_messages TO WARNING;

-- 1. Użytkownicy (3 testowych)
INSERT INTO budget.users (id, email, password_hash, display_name) VALUES
(1, 'jan.kowalski@example.com', 'hash_123', 'Jan Kowalski'),
(2, 'anna.nowak@example.com', 'hash_456', 'Anna Nowak'),
(3, 'piotr.wisniewski@example.com', 'hash_789', 'Piotr Wiśniewski');

-- Reset sekwencji dla tabeli users
SELECT setval('budget.users_id_seq', 3);

-- 2. Gospodarstwa domowe (2 testowe)
INSERT INTO budget.households (id, name, description) VALUES
(1, 'Rodzina Kowalskich', 'Wspólny budżet Jana i Anny'),
(2, 'Budżet Studencki Piotra', 'Wydatki na studia i mieszkanie');

SELECT setval('budget.households_id_seq', 2);

-- 3. Członkowie gospodarstw
INSERT INTO budget.household_members (household_id, user_id, role) VALUES
(1, 1, 'owner'),
(1, 2, 'member'),
(2, 3, 'owner');

-- 4. Kategorie
-- Kategorie główne (Gospodarstwo 1)
INSERT INTO budget.categories (id, household_id, name, type, parent_category_id, icon) VALUES
(1, 1, 'Jedzenie', 'expense', NULL, '🍔'),
(2, 1, 'Mieszkanie', 'expense', NULL, '🏠'),
(3, 1, 'Transport', 'expense', NULL, '🚗'),
(4, 1, 'Wynagrodzenie', 'income', NULL, '💰'),
-- Podkategorie (Gospodarstwo 1)
(5, 1, 'Restauracje', 'expense', 1, '🍕'),
(6, 1, 'Zakupy spożywcze', 'expense', 1, '🛒'),
(7, 1, 'Czynsz', 'expense', 2, '🏢'),
(8, 1, 'Media', 'expense', 2, '⚡'),
(9, 1, 'Paliwo', 'expense', 3, '⛽'),
-- Kategorie dla Gospodarstwa 2
(10, 2, 'Rozrywka', 'expense', NULL, '🎮'),
(11, 2, 'Edukacja', 'expense', NULL, '📚'),
(12, 2, 'Stypendium', 'income', NULL, '🎓');

SELECT setval('budget.categories_id_seq', 12);
