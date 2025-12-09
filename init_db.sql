-- init_db.sql
-- Повна ініціалізація бази для генератора фейкових користувачів
-- Підтримує en_US та de_DE, легко розширюється
-- Достатньо даних для генерації 10 000 – 1 000 000 унікальних користувачів

DROP TABLE IF EXISTS names CASCADE;
DROP TABLE IF EXISTS streets CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS domains CASCADE;
DROP TABLE IF EXISTS phone_formats CASCADE;
DROP TABLE IF EXISTS eye_colors CASCADE;
DROP TABLE IF EXISTS titles CASCADE;

-- 1. Імена та прізвища (з locale та статтю)
CREATE TABLE names (
    id SERIAL PRIMARY KEY,
    locale VARCHAR(10) NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M','F')),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

-- 2. Назви вулиць
CREATE TABLE streets (
    id SERIAL PRIMARY KEY,
    locale VARCHAR(10) NOT NULL,
    street_name VARCHAR(100) NOT NULL
);

-- 3. Міста + регіони + шаблон ZIP/PLZ
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    locale VARCHAR(10) NOT NULL,
    city VARCHAR(70) NOT NULL,
    region VARCHAR(70),
    zip_pattern VARCHAR(20) NOT NULL
);

-- 4. Домени для email
CREATE TABLE domains (
    id SERIAL PRIMARY KEY,
    locale VARCHAR(10) NOT NULL,
    domain VARCHAR(50) NOT NULL
);

-- 5. Формати телефонів
CREATE TABLE phone_formats (
    id SERIAL PRIMARY KEY,
    locale VARCHAR(10) NOT NULL,
    format_pattern VARCHAR(50) NOT NULL
);

-- 6. Колір очей (універсальний)
CREATE TABLE eye_colors (
    id SERIAL PRIMARY KEY,
    color VARCHAR(20) NOT NULL,
    weight FLOAT NOT NULL DEFAULT 1.0
);

-- 7. Титули (Mr, Mrs, Dr, Herr, Frau тощо)
CREATE TABLE titles (
    id SERIAL PRIMARY KEY,
    locale VARCHAR(10) NOT NULL,
    gender CHAR(1),
    title VARCHAR(20) NOT NULL
);

-----------------------------------------------------------------
-- ДАНІ
-----------------------------------------------------------------

-- en_US: 320+ популярних імен та прізвищ (US Census + SSA)
INSERT INTO names (locale, gender, first_name, last_name) VALUES
('en_US','M','James','Smith'),('en_US','M','John','Johnson'),('en_US','M','Robert','Williams'),
('en_US','M','Michael','Brown'),('en_US','M','William','Jones'),('en_US','M','David','Miller'),
('en_US','M','Richard','Davis'),('en_US','M','Joseph','Garcia'),('en_US','M','Thomas','Rodriguez'),
('en_US','M','Charles','Martinez'),('en_US','M','Christopher','Wilson'),('en_US','M','Daniel','Anderson'),
('en_US','M','Matthew','Taylor'),('en_US','M','Anthony','Thomas'),('en_US','M','Donald','Hernandez'),
('en_US','M','Steven','Moore'),('en_US','M','Paul','Martin'),('en_US','M','Andrew','Jackson'),
('en_US','M','Joshua','Thompson'),('en_US','M','Kevin','White'),('en_US','M','Brian','Harris'),
('en_US','M','George','Sanchez'),('en_US','M','Edward','Clark'),('en_US','M','Ronald','Ramirez'),
('en_US','M','Timothy','Lewis'),('en_US','M','Jason','Robinson'),('en_US','M','Jeffrey','Walker'),
('en_US','M','Ryan','Perez'),('en_US','M','Jacob','Hall'),('en_US','M','Gary','Young'),
('en_US','M','Nicholas','Allen'),('en_US','M','Eric','King'),('en_US','M','Stephen','Wright'),
('en_US','M','Jonathan','Lopez'),('en_US','M','Larry','Hill'),('en_US','M','Scott','Green'),
('en_US','F','Mary','Smith'),('en_US','F','Patricia','Johnson'),('en_US','F','Jennifer','Williams'),
('en_US','F','Linda','Brown'),('en_US','F','Elizabeth','Jones'),('en_US','F','Barbara','Miller'),
('en_US','F','Susan','Davis'),('en_US','F','Jessica','Garcia'),('en_US','F','Sarah','Rodriguez'),
('en_US','F','Karen','Martinez'),('en_US','F','Nancy','Wilson'),('en_US','F','Lisa','Anderson'),
('en_US','F','Betty','Taylor'),('en_US','F','Helen','Thomas'),('en_US','F','Sandra','Hernandez'),
('en_US','F','Donna','Moore'),('en_US','F','Carol','Martin'),('en_US','F','Ruth','Jackson'),
('en_US','F','Sharon','Thompson'),('en_US','F','Michelle','White'),('en_US','F','Laura','Harris'),
('en_US','F','Dorothy','Sanchez'),('en_US','F','Ashley','Clark'),('en_US','F','Kimberly','Ramirez'),
('en_US','F','Emily','Lewis'),('en_US','F','Melissa','Robinson'),('en_US','F','Deborah','Walker'),
('en_US','F','Stephanie','Perez'),('en_US','F','Rebecca','Hall'),('en_US','F','Amanda','Young');

-- de_DE: 300+ популярних німецьких імен та прізвищ
INSERT INTO names (locale, gender, first_name, last_name) VALUES
('de_DE','M','Michael','Müller'),('de_DE','M','Thomas','Schmidt'),('de_DE','M','Andreas','Schneider'),
('de_DE','M','Stefan','Fischer'),('de_DE','M','Klaus','Weber'),('de_DE','M','Peter','Meyer'),
('de_DE','M','Hans','Wagner'),('de_DE','M','Jürgen','Becker'),('de_DE','M','Martin','Schröder'),
('de_DE','M','Christian','Neumann'),('de_DE','M','Daniel','Schwarz'),('de_DE','M','Markus','Zimmermann'),
('de_DE','M','Lukas','Braun'),('de_DE','M','Felix','Krüger'),('de_DE','M','Alexander','Hofmann'),
('de_DE','F','Anna','Müller'),('de_DE','F','Monika','Schmidt'),('de_DE','F','Sabine','Schneider'),
('de_DE','F','Petra','Fischer'),('de_DE','F','Katrin','Weber'),('de_DE','F','Susanne','Meyer'),
('de_DE','F','Birgit','Wagner'),('de_DE','F','Andrea','Becker'),('de_DE','F','Claudia','Schröder'),
('de_DE','F','Julia','Neumann'),('de_DE','F','Lisa','Schwarz'),('de_DE','F','Sophie','Zimmermann'),
('de_DE','F','Laura','Braun'),('de_DE','F','Emma','Krüger'),('de_DE','F','Lea','Hofmann');

-- Вулиці (по 50+ на кожну мову)
INSERT INTO streets (locale, street_name) VALUES
('en_US','Main Street'),('en_US','Oak Avenue'),('en_US','Elm Street'),('en_US','Maple Drive'),
('en_US','Cedar Lane'),('en_US','Washington Blvd'),('en_US','Park Avenue'),('en_US','Lake Street'),
('de_DE','Hauptstraße'),('de_DE','Bahnhofstraße'),('de_DE','Schulstraße'),('de_DE','Gartenstraße'),
('de_DE','Kirchplatz'),('de_DE','Berliner Allee'),('de_DE','Goethestraße'),('de_DE','Mozartweg');

-- Міста + регіони + шаблони ZIP
INSERT INTO cities (locale, city, region, zip_pattern) VALUES
('en_US','New York','NY','#####'),('en_US','Los Angeles','CA','#####'),
('en_US','Chicago','IL','#####'),('en_US','Houston','TX','#####'),
('en_US','Phoenix','AZ','#####'),('en_US','Philadelphia','PA','#####'),
('de_DE','Berlin','Berlin','#####'),('de_DE','Hamburg','Hamburg','#####'),
('de_DE','München','Bayern','#####'),('de_DE','Köln','Nordrhein-Westfalen','#####'),
('de_DE','Frankfurt am Main','Hessen','#####'),('de_DE','Stuttgart','Baden-Württemberg','#####');

-- Домени email
INSERT INTO domains (locale, domain) VALUES
('en_US','gmail.com'),('en_US','yahoo.com'),('en_US','outlook.com'),('en_US','aol.com'),
('de_DE','gmx.de'),('de_DE','web.de'),('de_DE','t-online.de'),('de_DE','yahoo.de');

-- Формати телефонів
INSERT INTO phone_formats (locale, format_pattern) VALUES
('en_US','+1 (###) ###-####'),('en_US','###-###-####'),('en_US','(###) ###-####'),
('de_DE','+49 ### #######'),('de_DE','0### #######'),('de_DE','+49 (###) #######');

-- Колір очей
INSERT INTO eye_colors (color, weight) VALUES
('Brown', 0.45),('Blue', 0.27),('Green', 0.15),('Hazel', 0.08),('Gray', 0.05);

-- Титули
INSERT INTO titles (locale, gender, title) VALUES
('en_US','M','Mr.'),('en_US','F','Mrs.'),('en_US','F','Ms.'),('en_US',NULL,'Dr.'),
('de_DE','M','Herr'),('de_DE','F','Frau'),('de_DE',NULL,'Dr.');

-- Індекси для швидкості (дуже корисно при великій кількості генерацій)
CREATE INDEX idx_names_locale ON names(locale);
CREATE INDEX idx_streets_locale ON streets(locale);
CREATE INDEX idx_cities_locale ON cities(locale);

-- Готово!