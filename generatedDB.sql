-- lists and products can be deleted
-- categories cannot be deleted
-- users cannot be deleted

CREATE TABLE APP.USERS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	EMAIL VARCHAR(100) NOT NULL UNIQUE,
	PASSWORD VARCHAR(64) NOT NULL,
	FIRSTNAME VARCHAR(100) NOT NULL,
	LASTNAME VARCHAR(100) NOT NULL,
	IS_ADMIN BOOLEAN DEFAULT FALSE NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE APP.NV_USERS (
	EMAIL VARCHAR(100) NOT NULL,
	PASSWORD VARCHAR(64) NOT NULL,
	FIRSTNAME VARCHAR(100) NOT NULL,
	LASTNAME VARCHAR(100) NOT NULL,
	VERIFICATION_CODE VARCHAR(50) NOT NULL,
	PRIMARY KEY (EMAIL)
);

CREATE TABLE APP.LISTS_CATEGORIES (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000) NOT NULL,
	PRIMARY KEY (ID),
	UNIQUE (NAME)
);

CREATE TABLE APP.PRODUCTS_CATEGORIES (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	RENEW_TIME INTEGER NOT NULL DEFAULT 0,
	DESCRIPTION VARCHAR(1000) NOT NULL,
	PRIMARY KEY (ID),
	UNIQUE (NAME)
);

CREATE TABLE APP.LISTS_PRODUCTS_CATEGORIES (
	LIST_CAT INTEGER NOT NULL CONSTRAINT lists_products_categories__list_cat REFERENCES APP.LISTS_CATEGORIES (ID),
	PRODUCT_CAT INTEGER NOT NULL CONSTRAINT lists_products_categories__product_cat REFERENCES APP.PRODUCTS_CATEGORIES (ID),
	UNIQUE (LIST_CAT, PRODUCT_CAT)
);

CREATE TABLE APP.LISTS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL CONSTRAINT lists__category REFERENCES APP.LISTS_CATEGORIES (ID),
	OWNER INTEGER NOT NULL CONSTRAINT lists__owner REFERENCES APP.USERS (ID),
	PRIMARY KEY (ID),
	UNIQUE (NAME, CATEGORY, OWNER)
);

CREATE TABLE APP.LISTS_ANONYMOUS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL CONSTRAINT lists_anonymous__category REFERENCES APP.LISTS_CATEGORIES (ID),
	LAST_SEEN TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (ID)
);

CREATE TABLE APP.PRODUCTS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	UPPER_NAME GENERATED ALWAYS AS (UPPER(NAME)),
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL CONSTRAINT products__category REFERENCES APP.PRODUCTS_CATEGORIES (ID),
	CREATOR INTEGER NOT NULL CONSTRAINT products__creator REFERENCES APP.USERS (ID),
	NUM_VOTES INTEGER NOT NULL DEFAULT 0,
	RATING REAL NOT NULL DEFAULT 0,
	CONSTRAINT products__num_votes CHECK(NUM_VOTES >= 0),
	CONSTRAINT products__rating CHECK(RATING >= 0 AND RATING <= 5),
	PRIMARY KEY (ID),
	UNIQUE (NAME, CATEGORY, CREATOR)
);

CREATE INDEX productsUpperNameIndex ON APP.PRODUCTS(UPPER_NAME);

CREATE TABLE APP.LISTS_PRODUCTS (
	LIST INTEGER NOT NULL CONSTRAINT lists_products__list REFERENCES APP.LISTS (ID) ON DELETE CASCADE,
	PRODUCT INTEGER NOT NULL CONSTRAINT lists_products__product REFERENCES APP.PRODUCTS (ID) ON DELETE CASCADE,
	TOTAL INTEGER NOT NULL DEFAULT 1,
	PURCHASED INTEGER NOT NULL DEFAULT 0,
	LAST_PURCHASE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT lists_products__total CHECK(TOTAL >= 1),
	CONSTRAINT lists_products__purchased CHECK(PURCHASED <= TOTAL),
	PRIMARY KEY (LIST,PRODUCT)
);

CREATE TABLE APP.LISTS_ANONYMOUS_PRODUCTS (
	LIST_ANONYMOUS INTEGER NOT NULL CONSTRAINT lists_anonymous_products__list_anonymous REFERENCES APP.LISTS_ANONYMOUS (ID) ON DELETE CASCADE,
	PRODUCT INTEGER NOT NULL CONSTRAINT lists_anonymous_products__product REFERENCES APP.PRODUCTS (ID) ON DELETE CASCADE,
	TOTAL INTEGER NOT NULL DEFAULT 1,
	PURCHASED INTEGER NOT NULL DEFAULT 0,
	LAST_PURCHASE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT lists_anonymous_products__total CHECK(TOTAL >= 1),
	CONSTRAINT lists_anonymous_products__purchased CHECK(PURCHASED <= TOTAL),
	PRIMARY KEY (LIST_ANONYMOUS,PRODUCT)
);

CREATE TABLE APP.LISTS_SHARING (
	LIST INTEGER NOT NULL CONSTRAINT lists_sharing__list REFERENCES APP.LISTS (ID) ON DELETE CASCADE,
	USER_ID INTEGER NOT NULL CONSTRAINT lists_sharing__user_id REFERENCES APP.USERS (ID),
	ACCESS INTEGER NOT NULL	CONSTRAINT lists_sharing__access_ck CHECK (ACCESS IN (0, 1, 2)), -- (read, add/rm prods, full(rename, delete, etc))
	PRIMARY KEY (LIST,USER_ID)
);

CREATE TABLE APP.CHATS (
	LIST INTEGER NOT NULL CONSTRAINT chats__list REFERENCES APP.LISTS (ID) ON DELETE CASCADE,
	USER_ID INTEGER NOT NULL CONSTRAINT chats__user_id REFERENCES APP.USERS (ID),
	TIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	MESSAGE VARCHAR(500) NOT NULL,
	IS_LOG BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE APP.INVITES (
	INVITED INTEGER NOT NULL CONSTRAINT invites__invited REFERENCES APP.USERS (ID),
	LIST INTEGER NOT NULL CONSTRAINT invites__list REFERENCES APP.LISTS (ID) ON DELETE CASCADE,
	ACCESS INTEGER NOT NULL	CONSTRAINT invites__access_ck CHECK (ACCESS IN (0, 1, 2)), -- (read, add/rm prods, full(rename, delete, etc))
	PRIMARY KEY(INVITED, LIST)
);

INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrea.matte@studenti.unitn.it', '$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS', 'Andrea', 'Matto', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrei.diaconu@studenti.unitn.it', '$2a$10$bek3pnCbDuA7YfLXHDpVi./CPITBTv.nPud1Q63WukdgtKsrr.NCe', 'Andrei', 'Kontorto', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrea.iossa@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'Andrea', 'Ioza', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('edoardo.meneghini@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'Edoardo', 'Meneghini', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('matteo.bini@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'Matteo', 'Bini', false);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.toldo4@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.chiocco5@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.castellaneta6@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.trump7@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.chiocco8@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.amadori9@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.castellaneta10@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.castellaneta11@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.toldo12@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.chiocco13@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini14@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.trump15@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.toldo16@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.castellaneta17@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.amadori18@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.toldo19@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.castellaneta20@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.amadori21@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.chiocco22@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.bini23@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.bini24@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.amadori25@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.chiocco26@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.chiocco27@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.castellaneta28@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.trump29@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.castellaneta30@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.castellaneta31@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.trump32@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.toldo33@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.chiocco34@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.amadori35@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.trump36@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.amadori37@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.amadori38@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.toldo39@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.amadori40@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.trump41@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.castellaneta42@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini43@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.chiocco44@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini45@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini46@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.bini47@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.amadori48@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.amadori49@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Amadori',FALSE);




INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Verdura','desc',5);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Carne','desc',4);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Pasta','desc',15);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Dessert','desc',15);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Surgelati','desc',20);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Condimenti','desc',30);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Videogiochi','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Calcio','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Ciclismo','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Camping','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Fitness','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Musica','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Ferramenta','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Colori','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Attrezzi','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Giardinaggio','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Cucito','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Telefonia','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Fotocamere','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('TV','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Audio','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Desktop','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Scarpe','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Pantaloni','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Felpe','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Magliette','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Cappelli','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Giacche','desc',0);




INSERT INTO APP.LISTS_CATEGORIES ("NAME", DESCRIPTION) VALUES ('Cibo','desc');
INSERT INTO APP.LISTS_CATEGORIES ("NAME", DESCRIPTION) VALUES ('Tempo libero','desc');
INSERT INTO APP.LISTS_CATEGORIES ("NAME", DESCRIPTION) VALUES ('Fai da te','desc');
INSERT INTO APP.LISTS_CATEGORIES ("NAME", DESCRIPTION) VALUES ('Elettronica','desc');
INSERT INTO APP.LISTS_CATEGORIES ("NAME", DESCRIPTION) VALUES ('Abbigliamento','desc');




INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (1,1);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (1,2);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (1,3);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (1,4);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (1,5);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (1,6);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (2,7);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (2,8);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (2,9);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (2,10);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (2,11);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (2,12);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (3,13);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (3,14);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (3,15);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (3,16);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (3,17);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (4,18);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (4,19);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (4,20);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (4,21);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (4,22);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (5,23);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (5,24);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (5,25);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (5,26);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (5,27);
INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) VALUES (5,28);




INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spaghetti 500g','Gli spaghetti sono il risultato di una combinazione di grani duri eccellenti e trafile disegnate nei minimi dettagli. Hanno un gusto consistente e trattengono al meglio i sughi.',3,1,4.084891725784557,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne rigate 500g','Una pasta gradevolmente ruvida e porosa, grazie alla trafilatura di bronzo. Particolarmente adatta ad assorbire i condimenti, è estremamente versatile in cucina. Ottima abbinata a sughi di carne, verdure e salse bianche. ',3,4,2.7969199929219046,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fusilli biologici 500g','Tipo di pasta corta originario dell’Italia meridionale, dalla caratteristica forma a spirale, i fusilli si abbinano a diversi tipi di sugo, dai più semplici a quelli più elaborati. Sono diffusi e prodotti in tutta Italia, in certi casi secondo la metodologia tradizionale a mano.',3,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tagliatelle alluovo 500g','Nelle Tagliatelle alluovo è racchiuso tutto il sapore della migliore tradizione gastronomica emiliana. Una sfoglia a regola darte che unisce semola di grano duro e uova fresche da galline allevate a terra, in soli 2 millimetri di spessore.',3,3,2.7996069627483475,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tortelloni ai formaggi','Tortelloni farciti con una varietà di formaggi alto-atesini, dal sapore deciso e dal profumo caratteristico. Ogni tortellone viene farcito con formaggio e spezie (pepe, noci, origano, ...)',3,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gnocchetti alla tirolese','Gli gnocchetti tirolesi sono preparati con spinaci lessati, farina e uova. Sono caratterizzati dalla tipica forma a goccia e si prestano ad essere preparati da soli o con altri sughi e condimenti.',3,3,2.2578951010510853,35);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chicche di patate','Le chicche di patate sono preparate con pochi e semplici ingredienti: patate fresche cotte a vapore, farina e uova. Ideali per un piatto veloce da preparare e nutriente.',3,3,1.8981501047447213,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paccheri napoletani','I paccheri hanno la forma di maccheroni giganti e sono realizzati con trafila di bronzo e semola di grano duro. La superficie è ampia e rugosa, per mantenere alla perfezione il sugo. La forma a cilindro permette la farcitura interna.',3,2,4.377896538011699,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pizzoccheri della valtellina','La particolarità dei pizzoccheri è la combinazione di ingredienti che ne fanno la pasta. Dal caratteristico colore scuro e con una tessitura grossolana, si esaltano nel condimento tradizionale, una combinazione di pezzi di patate, verza, formaggio Valtellina Casera, burro e salvia.',3,1,2.6707708446953604,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corallini 500g','I Corallini hanno l’aspetto essenziale ed elegante di minuscoli tubetti, cortissimi e di forma liscia. Abili nel trattenere il brodo o i passati, che si incanalano nel loro minuscolo spiraglio, rappresentano una raffinata alternativa nella scelta delle pastine.',3,23,4.630286640448754,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne lisce 500g','Un formato davvero speciale sotto il profilo della versatilità. Sono perfette per penne allarrabbiata, o al ragù alla bolognese.',3,3,0.7926681553930082,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rigatoni 1kg','I rigatoni sono caratterizzati dalla rigatura sulla superficie esterna e dal diametro importante; trattengono perfettamente il condimento su tutta la superficie, esterna ed interna, restituendone ogni sfumatura.',3,4,3.0646985414968175,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucchine verdi','Hanno un sapore gustoso ed intenso: le zucchine verdi scure biologiche sono perfette per essere utilizzate sia da sole che con altri piatti, siano essei a base di verdure o carne. Perfino i loro fiori si usano in cucina con svariate preparazioni.',1,13,1.1380934341613969,50);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carote Almaverde Bio','Le carote biologiche almaverde bio, oltre ad essere incredibilmente versatili e fresche, fanno bene alla vista e durante la bella stagione sono indicate per aumentare labbronzatura.',1,3,4.15184319445858,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patate a pasta gialla','La patata a pasta gialla biologica è forse il tubero più consumato nel mondo. Le patate sono originarie dellamerica centrale e meridionale. Importata in Europa dopo la scoperta dellAmerica, nel 500, si è diffusa in Irlanda, in Inghilterra, in Francia e in Italia.',1,1,2.439249113760856,89);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Finocchio tondo oro','Coltivato nelle fertili terre della Campania, il finocchio oro ha un delizioso sapore dolce e una croccantezza unica. Al palato sprigiona un sapore irresistibile ed è ricco di vitamina A, B e C e se consumato crudo è uneccellente fonte di potassio.',1,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro datterino pachino','Succoso, dolce e profumato! Il pomodoro datterino è perfetto per dare un tocco gustoso alle insalate, ma anche per realizzare deliziose salse e condimenti. Coltivato sotto il caldo sole di Pachino, a Siracusa, è una vera eccellenza nostrana.',1,2,4.29910419542972,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro cuore di bue','Ricco di vitamine, sali minerali, acqua, fibre, il Pomodoro Cuore di Bue viene coltivato in varie zone dItalia. La terra fertile e le condizioni climatiche rendono possibile la coltivazione di un pomodoro dal sapore unico, dolce e succoso.',1,2,4.240216176525627,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cetrioli Almaverde Bio','l cetriolo biologico è un frutto ricco di sostanze nutritive che apportano benefici per chi li assume. Ha proprietà lassative grazie alle sue fibre, favorisce la diuresi per la notevole quantità di acqua presente ed è un buon alleato per la pelle se usato come maschera viso.',1,3,2.827319323172782,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carciofo violetto di sicilia','I carciofi sono buoni, utilizzabili per creare molti piatti e possiedono benefici notevoli; la varietà violetta può inoltre conferire un tocco particolare alle ricette di tutti i giorni. Ha un sapore squisito e mantiene le caratteristiche salutari dei carciofi.',1,4,1.7568725954674491,76);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucca gialla delicata','La zucca Spaghetti o Spaghetti squash è una varietà di zucca unica: la sua polpa è composta di tanti filamenti edibili dalla forma di spaghetti. Con il suo basso contenuto di calorie è ideale per chi vuole tenersi in forma. ',1,2,3.9782622524037414,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cipolla dorata bio','Cipolla dorata biologica con numerosi benefici e proprietà antiossidanti ed antinfiammatorie. Ideale per preparare zuppe, torte salate o insalate, ma anche e soprattutto ottimi soffritti.',1,3,3.2081201638898884,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Peperoni rossi bio','I peperoni rossi biologici sono ideali per stuzzicare il palato, preparare gustosi e saporiti sughi da abbinare a pasta, carne o zuppe.',1,2,2.454552109229394,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zampina','E’ una salsiccia di qualità, realizzata con carni miste di bovino (compreso primo taglio). La carne, dopo essere stata disossata, viene macinata insieme al basilico in un tritacarne. Il composto ottenuto è unito al resto degli ingredienti e collocato in un’impastatrice, in modo da ottenere un prodotto uniforme e privo di granuli. Infine viene insaccato nelle budella naturali di ovicaprino.',2,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Battuta di Fassona','La battuta al coltello di fassona è uno degli antipasti classici della gastronomia tipica piemontese. La carne di bovino della pregiata razza Fassona viene semplicemente battuta cruda al coltello, in modo da sminuzzarla senza macinarla meccanicamente, lasciando la giusta consistenza alla carne. Si condisce con un filo dolio, un pizzico di sale, pepe e volendo qualche goccia di limone. Si può servire con qualche scaglia di Parmigiano Reggiano.',2,3,1.9901489117522209,40);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arrosticini di fegato','Originale variante del classico arrosticino di pecora, per chi ama sperimentare combinazioni di sapori insolite e sfiziose. Piccoli bocconcini di freschissimo fegato ovino al 100% italiano, tagliati minuziosamente fino a ottenere porzioni da circa 40 g. Infilati con cura in pratici spiedini di bamboo, ogni singolo cubetto custodisce tutto il gusto intenso e deciso della carne ovina, valorizzato dalla dolcezza e dal carattere della cipolla di Tropea.',2,1,1.198442726614115,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia di suino fresca','La preparazione della salsiccia di suino fresca inizia disossando il maiale e selezionando i tagli di carne scelti, che vengono poi macinati con una piastra di diametro 4,5mm. Si procede quindi a preparare l’impasto, con l’aggiunta di solo sale e pepe, che viene amalgamato e poi insaccato. La salsiccia viene quindi legata a mano e lasciata ad asciugare. Si presenta di colore rosa con grana medio-fina. Al palato è morbida e saporita, con gusto leggermente sapido.',2,8,3.2261217636218587,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bombette','Gustosa carne di coppa suina, tagliata a fettine sottili e arrotolata a involtino attorno a sfiziosi cubetti di formaggio (sì, proprio quello che durante la cottura diventerà cremoso e filante) e sale. Disponibile anche nella variante impanata, sotto forma di spiedino.',2,4,4.082986173643787,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia tipo Bra','La Salsiccia di Bra è una salciccia tipica piemontese, prodotta con carni magre di vitellone, macinata finemente e insaccata in budello naturale. La salsiccia non avendo bisogno di stagionatura, può essere consumata fresca durante tutto lanno. Spesso viene venduta attorcigliata, con la caratteristica forma di spirale. Un grande classico della tradizione culinaria piemontese, spesso viene consumata cotta alla griglia, ma l’ideale è gustarla cruda come antipasto.',2,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Hamburger ai carciofi','Il gusto delicato e leggermente amaro dei carciofi conferisce una nota particolare alle pregiate schiacciatine di vitello. La tenera carne, macellata e resa ancora più morbida dall’aggiunta di pane e Grana Padano, si sposa alla perfezione con il gusto del carciofo, che la esalta senza coprirne il sapore.',2,4,4.158222943215363,29);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coscia alla trevigiana','Le cosce di maiale sono prima disossate, poi speziate e legate a mano. Si procede quindi alla cottura al forno a bassa temperatura, solo con l’aggiunta di spezie naturali, in modo da conservare tutti gli aromi e la morbidezza delle carni. A cottura ultimata, la coscia al forno viene messa a raffreddare, tagliata a metà.  Il colore della carne è rosato, la consistenza è soda e il gusto intenso e molto saporito.',2,2,1.012511217806088,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spezzatino disossato','Tenero, magro e saporito: lo spezzatino biologico senza osso dellazienda agricola Querceta non teme rivali in fatto di qualità, gusto e consistenza. Ricavato dalle parti muscolose di bovini allevati liberamente e con alimentazione biologica dallazienda, questo taglio è a dir poco perfetto sia per il brodo che per la cottura in umido, che rende la carne ancora più morbida e gustosa.',2,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuore di costata','Il cuore di costata di Querceta viene ricavato dai migliori tagli magri di carne bovina, accompagnata da una minima presenza di porzione grassa che, riuscendo a diluire parzialmente il contenuto connettivo, la rende più tenera e saporita.',2,4,0.8732388743496511,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bragiolette','Tenere fettine di carne bovina accuratamente selezionata e farcite con saporito formaggio, prezzemolo e una punta di aglio per ravvivare ulteriormente il già ricco sapore.',2,2,1.4534516674245446,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini Findus','I Bastoncini sono fatti con 100% filetti di merluzzo da pesca sostenibile e certificata MSC, sfilettati ancora freschi e surgelati a bordo per garantirti la massima qualità. Sono avvolti nel pangrattato, semplice e croccante, per un gusto inimitabile.',5,2,2.1588609310271134,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pisellini primavera','I Pisellini Primavera sono la parte migliore del raccolto perché vengono selezionati solo quelli più piccoli, teneri e dolci rispetto ai Piselli Novelli. Sono così piccoli, teneri e dolci da rendere ogni piatto più buono.',5,3,1.710993738768557,19);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sofficini','I sofficini godono di un ripieno vibrante e di un gusto mediterraneo, con pomodoro DOP e Mozzarella filante di altissima qualità, in unimpanatura croccante e gustosa.',5,4,3.2225224527477794,91);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Misto per soffritto','Questo delizioso misto di verdure accuratamente tagliate: carote, sedano e cipolle, è ideale per accompagnare qualsiasi piatto. La preparazione è velocissima.',5,2,1.7814114651635538,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spinaci cubello','In questa porzione di spinaci surgelati, le foglie della pianta sono adagiate delicatamente una sullaltra, per mantenersi più soffici e più integre. Inoltre, dal punto di vista nutrizionale, i cubelli di Spinaci Foglia forniscono una dose di calcio sufficiente a soddisfare il fabbisogno quotidiano.',5,18,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fiori di nasello','I Fiori di Nasello, così teneri e carnosi, sono la parte migliore dei filetti. Pescato nelle acque profonde dellOceano Pacifico, viene sfilettato ancora fresco e surgelato entro 3 ore così da preservarne al meglio sapore e consistenza.',5,4,4.604453940624959,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Minestrone tradizionale','Con il minestrone tradizionale, sarà possibile gustare la bontà autentica di ingredienti IGP e DOP, con il gusto unico di verdure al 100% italiane, coltivate in terreni selezionati. Nel minestrone sono presenti patate, carote, cipolle, porri, zucche, spinaci e verze.',5,2,4.217907578148726,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patatine fritte','Esistono di forma rotonda, ovale o allungata, a pasta bianca o gialla, addirittura viola. Vengono selezionate con attenzione per qualità, dimensione e caratteristiche organolettiche, così da offrire tutto il meglio delle patate offerte dalla terra.',5,1,0.7794208318924567,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cimette di broccoli','Il broccolo è una varietà di cavolo che presenta uninfiorescenza commestibile. La raccolta dei broccoli avviene entro i 4-6 mesi successivi alla semina, poi le cimette sono rapidamente surgelati per preservare le loro proprietà nutrizionali.',5,2,3.6888100229540166,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polpette finocchietto','Deliziosi tortini di verdure subito pronti da gustare come antipasto, come contorno o come pratico piatto unico completato da uninsalata.',5,3,1.990820138194368,104);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Torroncini duri','Un assortimento di torroncini originale e sfizioso, tra cui vale la pena menzionare quelli profumati dalle note agrumate dei bergamotti e dei limoni calabresi, per poi farsi tentare dai gusti più golosi come caffè e nutella.',4,2,4.143660544069841,82);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cantucci con cioccolato','Dolci toscani per eccellenza, da accompagnare con vini liquorosi come il Vin Santo, i cantucci offrono un ampio margine per sperimentare nuovi sapori. Fin dal primo morso si apprezza il perfetto equilibrio tra il gusto inconfondibile del cioccolato, esaltato da un lieve sentore di arancia, e limpasto tradizionale del cantuccio, per un risultato croccante e goloso.',4,2,1.6910251023715972,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Dolcetti alla nocciola','Piccoli e fragranti, con il loro invitante aspetto a forma di rosellina, questi dolcetti alla nocciola sono una specialità dal sapore antico e sempre stuzzicante. Lavorati con nocciole piemontesi Tonda Gentile IGP, i biscottini Michelis sono l’ideale da servire con un buon tè aromatico e delicato. Ottimi anche per la prima colazione.',4,4,4.805981867870257,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paste di meliga','Tipiche del Piemonte, le paste di Meliga del Monregalese sono dei frollini dalla storia antichissima. La qualità del prodotto è data dallabbinamento di zucchero, uova fresche, burro a chilometro zero e farine locali, per un biscotto semplice e genuino. Fondamentale è il mais Ottofile. La grana grossolana della farina che ne deriva è il segreto di questi biscotti friabili.',4,4,0.7869019148768552,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Amaretti di sicilia','L’aspetto ricorda quello di un semplice biscotto secco ma le apparenze, che spesso ingannano, vengono subito smentite quando al primo morso la pasta comincerà a sciogliersi e rivelarsi in tutta la sua dolcezza. Gli Amaretti di Sicilia vengono presentati in eleganti confezioni regalo, una per ogni variante proposta: classica, al pistacchio di Sicilia, alla gianduia delle Langhe e al mandarino di Sicilia.',4,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Celli pieni','Pochi ingredienti, semplici e genuini: il segreto della bontà dei celli ripieni è questo. Basta un piccolo morso per lasciarsi conquistare dal gusto intenso della scrucchijata, speciale confettura a base di uva di Montepulciano che non solo fa da ripieno, ma è il vero e proprio “cuore” di questo antico dolce della tradizione abruzzese.',4,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cannoli siciliani','Il cannolo è il dolce siciliano per eccellenza, disponibile in formato mignon e grande. Proveniente dai pascoli del Parco dei Nebrodi e del Parco delle Madonie, la migliore ricotta viene selezionata e lavorata in più fasi per renderla leggera e vellutata, creando un irresistibile contrasto con la granella di pistacchio e la friabile pasta che la ospita.',4,4,1.0969920781845532,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crema gianduia','Senza grassi aggiunti, né aromi, ogni vasetto custodisce tutta l’essenza dei migliori ingredienti italiani, lavorati con cura e valorizzati da una piacevolissima consistenza. Un’ammaliante linea di creme dal gusto intenso e dolce, che coinvolgerà il palato in una sinfonia di sapori.',4,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Plum cake','Del classico plum cake resta la morbidezza e la delicatezza, ma per tutto il resto, linterpretazione siciliana si differenzia dallo standard. Uva passa e rum sanno elevare il carattere timido di questo dolce in maniera netta e riuscita. La giusta componente alcolica accende di gusto luva e la frutta secca presente nellimpasto.',4,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pignolata','Probabilmente il dolce più caratteristico di tutta Messina, immancabile a carnevale ma preparato ed apprezzato tutto lanno. Tanti piccoli gnocchetti di impasto realizzato con farina, uova e alcol vengono fritti ed assemblati. La fase finale prevede una glassatura deliziosa: per metà al limone e per la restante metà al cioccolato.',4,2,2.5419444881666386,23);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo Switch','Nintendo Switch, una console casalinga rivoluzionaria che non solo si connette al televisore di casa tramite la base e il cavo HDMI, ma si trasforma anche in un sistema da gioco portatile estraendola dalla base, grazie al suo schermo ad alta definizione.',7,2,3.777517962174892,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grand Theft Auto V','Il mondo a esplorazione libera più grande, dinamico e vario mai creato, Grand Theft Auto V fonde narrazione e giocabilità in modi sempre innovativi: i giocatori vestiranno di volta in volta i panni dei tre protagonisti, giocando una storia intricatissima in tutti i suoi aspetti.',7,2,0.9224765770156096,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Toy story 2','Il conto alla rovescia per questavventura comincia su Playstation 1, nei panni di Buzz Lightyear, Woody e tutti i loro amici. Sarà una corsa contro il tempo per salvare la galassia dal malvagio imperatore Zurg.',7,12,1.860578062426127,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ratchet and Clank','Una fantastica avventura con Ratchet, un orfano Lombax solitario ed esuberante ed un Guerrabot difettoso scappato dalla fabbrica del perfido Presidente Drek, intenzionato ad uccidere i Ranger Galattici perché non intralcino i suoi piani. Questo lincipit dellavventura più cult che ci sia su Playstation.',7,4,1.2362261977798317,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo snes mini','Replica in miniatura del classico Super Nintendo Entertainment System. Include 21 videogiochi classici, tra cui Super Mario World, The Legend of Zelda, Super Metroid e Final Fantasy III. Sono inclusi 2 controller classici cablati, un cavo HDMI e un cavo di alimentazione.',7,6,4.171780447728156,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Playstation 3 Slim','PlayStation 3 slim, a distanza di anni dal lancio del primo modello nel 2007, continua ad essere un sofisticato sistema di home entertainment, grazie al lettore incorporato di Blu-ray disc™ (BD) e alle uscite video che consentono il collegamento ad unampia gamma di schermi dai convenzionali televisori, fino ai più recenti schermi piatti in tecnologia full HD (1080i/1080p).',7,4,2.0538357577958966,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xbox 360','Xbox 360 garantisce l’accesso al più vasto portafoglio di giochi disponibile ed un’incredibile offerta di intrattenimento, il tutto ad un prezzo conveniente e con un design fresco ed accattivante, senza rinunciare a performance eccellenti.',7,7,3.4876415895076684,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crash Bandicoot trilogy','Crash Bandicoot è tornato! Più forte e pronto a scatenarsi con N. Sane Trilogy game collection. Sarà possibile provare Crash Bandicoot come mai prima d’ora in HD. Ruota, salta, scatta e divertiti atttraverso le sfide e le avventure dei tre giochi da dove tutto è iniziato',7,2,4.303848234340267,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pokemon rosso fuoco','In Pokemon Rosso Fuoco sarà possibile sperimentare le nuove funzionalità wireless di Gameboy Advance, impersonando Rosso, un ragazzino di Biancavilla, nel suo viaggio a Kanto. Il suo sogno? Diventare lallenatore più bravo di tutto il mondo!',7,1,3.1243613911624557,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('God of War','Tra dei dellOlimpo e storie di vendette e intrighi di famiglia, Kratos vive nella terra delle divinità e dei mostri norreni. Qui dovrà combattere per la sopravvivenza ed insegnare a suo figlio a fare lo stesso e ad evitare di ripetere gli stessi errori fatali del Fantasma di Sparta.',7,1,0.15999311064161859,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nastro parastinchi','Nastro adesivo in colorazione giallo neon, disponibile anche in altre colorazioni. 3,8cm x 10m. Ideale per legare calzettoni e parastinchi.',8,4,3.243533610441575,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Calzettoni Adidas','Calzettoni Adidas disponibili in numerose colorazioni, con polsini e caviglie con angoli elasticizzati a costine. Imbottiture anatomiche che sostengono e proteggono la caviglia.',8,1,4.539903008802838,76);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglietta Italia','Maglia FIGC, replica originale nazionale italiana. Realizzata con tecnologia Dry Cell Puma, che allontana lumidità dalla pelle per mantenere il corpo asciutto.',8,2,1.1784452130112544,89);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borsone palestra','Borsa Brera / adatto per la scuola - palestra - allenamento - ideale per il tempo libero. Disponibile in diverse colorazioni e adatta a sportivi di qualsiasi tipo. Involucro protettivo incluso.',8,2,2.8105369290378635,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Nike Mercurial','La scarpa da calcio da uomo Nike Mercurial Superfly VI academy CR7 garantisce una perfetta sensazione di palla e con la sua vestibilità comoda e sicura garantisce unaccelerazione ottimale e un rapido cambio di direzione su diverse superfici.',8,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Porta da giardino','Porta da Calcio in miniatura, adatta a giardini. Realizzata in uPVC 2,4 x1,7 m; Diametro pali : 68mm. Sistema di bloccaggio ad incastro per maggiore flessibilità e stabilità, per essere montata in appena qualche minuto.',8,2,2.892732298704448,92);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cinesini','Piccoli coni per allenare lagitlità, il coordinamento e la velocità. Molti campi di impiego nellallenamento per il calcio. Sono ben visibili, grazie ai colori appariscenti e contrastanti. Il materiale è flessibile e resistente.',8,2,0.23450846514472823,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set per arbitri','Carte arbitro da calcio: set di carte arbitro include cartellini rossi e gialli, matita, libro tascabile con carte di scopo punteggio del gioco allinterno e un fischietto allenatore di metallo con un cordino.',8,3,2.1735814295826583,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglia personalizzata','La Maglia è nella versione neutra e viene personalizzata con Nome e Numero termoapplicati da personale esperto. Viene realizzata al 100% in poliestere. Non ha lo sponsor tecnico e le scritte sono stampate.',8,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pallone Mondiali','Pallone ufficiale dei mondiali di calcio Fifa. Il pallone Telstar Mechta, il cui nome deriva dalla parola russa per sogno o ambizione, celebra la partecipazione ai mondiali di calcio FIFA 2018 e la competizione. Questo pallone viene fornito con lo stesso design monopanel del Telstar ufficiale 18. ',8,25,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zaino da alpinismo','Questa borsa è disponibile in colori attraenti. Ci sono molte tasche con cerniere in questa borsa per diversi oggetti che potrebbero essere necessari per un viaggio allaperto. È imbottito per il massimo comfort. Questa borsa è di 40 e 50/60/80 litri. Tessuto in nylon idrorepellente e antistrappo. Cinghie regolabili e lunghezza del torace.',10,2,2.444979929284602,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo demergenza','Questo sacco a pelo di emergenza trattiene il 90% del calore corporeo irradiato in modo da preservare il calore vitale in circostanze fredde e difficili. È abbastanza grande da coprirti dalla testa ai piedi. Dai colori vivaci in arancione vivo, questo sacco a pelo può essere immediatamente visto da lontano, rendendolo un rifugio indispensabile in attesa delle squadre di soccorso. Questo articolo ti aiuta a rimanere adeguatamente isolato dallaria fredda in modo da poter dormire comodamente e calorosamente quando vai in campeggio in inverno. È impermeabile e resistente alla neve, quindi puoi indossarlo come impermeabile per proteggerti dalla pioggia e dalla neve. Se necessario, puoi anche stenderlo su un grande prato come tappetino da picnic.',10,20,0.39051013085722674,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo','Sacco a pelo lungo di 2 metri per 70 cm di larghezza, ampi, con la possibilità di piegare la borsa quando aperto come una trapunta. Facile da aprire e chiudere con una cerniera che può essere bloccata. La parte superiore è circolare per un maggiore comfort per lutilizzatore. Cerniera di alta qualità e la tasca interna utile per riporre piccoli oggetti. Zipper riduce la perdita di calore. Il tessuto esterno è impermeabile e umidità realizzato con materiali di alta qualità e pieni di fibre offrono comfort e calore. Campo di temperatura tra i 6 ei 21 gradi. Questo sacco a pelo vi terrà al caldo, indipendentemente dal luogo o periodo dellanno.',10,1,0.6064406300650449,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo matrimoniale','Questo sacco a pelo di lusso è semplicemente fantastico. Si arrotola e si ripone facilmente in una borsa da trasporto, include una cerniera integrale con due tiretti ed è dotato di cinghie in velcro laterali. Alcuni dei nostri prodotti sono realizzati o rifiniti a mano. Il colore può variare leggermente e possono essere presenti piccole imperfezioni nelle parti metalliche dovute al processo di rifinitura a mano, che crediamo aggiunga carattere e autenticità al prodotto.',10,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tenda 4 persone','Comode tasche nella tenda interna per accessori e un porta lampada per una lampada da campeggio o torcia completano il comfort. Tenda ventilata per un sonno indisturbato. L ingresso con zanzariera tiene alla larga le fastidiose zanzare. Le cuciture assicurano una grande resistenza allo strappo e, quindi, alla rottura.',10,17,2.5505511580541085,80);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltello Magnum 8cm','Ottimo accessorio da avere sul campo, per essere pronti a qualsiasi tipo di wood carving o altra necessità. Le dimensioni ne richiedono, tuttavia, lutilizzo previo possesso di porto darmi. Il manico è in colore rosso lucido.',10,1,2.1438451631235313,23);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini trekking','I bastoncini di fibra di carbonio resistente offrono un supporto più forte dei modelli dalluminio; il peso ultra-leggero (195 g/ciascuno) facilita le camminate riducendo la tensione sui polsi.',10,4,1.4559565972503419,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lanterna da fronte','Torcia da testa Inova STS Headlamp Charcoal. Corpo in policarbonato nero resistente. Cinghia elastica in tessuto nero. LED bianco e rosso. Caratteristiche interfaccia Swipe-to-Shine che permette un accesso semplice alle molteplici modalita - il tutto con il tocco di un dito.',10,14,1.6907286665118482,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fornelletto a gas','Fornelletto da campo di facilissimo utilizzo: è sufficiente girare la manopola, ricaricare con una bomboletta di butano e sarà subito pronto a scaldare le pietanze che vi vengono poggiate. Ha uno stabile supporto in plastica dura e la potenza del bruciatore è di 1200 watt.',10,4,2.783529348948397,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borraccia con filtro','Rimuove il 99.99% di batteri a base d acqua,, e il 99.99% di iodio a base d acqua, protozoi parassiti senza sostanze chimiche, o batteriche. Ideale per viaggi, backpacking, campeggi e kit demergenza.',10,2,4.27205649362647,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rullo per allenamento','Bloccaggio fast fixing: è possibile agganciare e sganciare la bicicletta con un sola rapida operazione. 5 livelli di resistenza magnetica. Nuovo sistema di supporto regolabile dell’unità che consente un’idonea e costante pressione tra rullino dell’unità e pneumatico',9,2,3.4671590529475393,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pedali Shimano','Pedale di tipo click spd, con peso di coppia 380G, con i migliori materiali targati Shimano. Utilizzo previsto: MTB, tuttavia è possibile utilizzarli anche per viaggiare su strada',9,16,0.35875324060561153,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Catena 114L Ultegra','Catena bici da corsa 10 velocità. Pesa 118g, argento, 114 maglie. Ideale per qualsiasi tipo di terreno e di utilizzo. Garantita la resistenza fino a 5000km di utilizzo, soddisfatti o rimborsati',9,4,4.925494238272089,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Freni a pattino','Freni a pattino per cerchioni in alluminio. La confezione contiene 4 pezzi, quindi permettte di sostituire entrambi gli impianti di frenatura: quello anteriore e quello posteriore. Sono lunghi 70mm e universali.',9,1,2.2677084067526785,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sella da corsa Uomo','Sella da corsa, talmente comoda che è stata progettata utilizzzando gli stessi materiali e blueprint delle selle da trekking o touring. Imbottitura in gel poliuretanico morbido, con un telaio color acciacio molto resistente.',9,2,2.364139431716122,71);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ruota Maxxis da strada','Ottima gomma per chi oltre allo sterrato fa anche asfalto, da usare sia con camera daria che tubless. La linea centrale di tacchetti offre un buon supporto in asfalto ed evita che la gomma si usuri troppo ai lati. Nello sterrato asciutto nessun problem, ottima tenuta in curva. Per chi ha problemi di forature sulla spalla esiste anche la versione EXO.',9,7,0.07910896743508533,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rastrelliera da parete','Rastrellilera verticale, da parete, con supporto fino a cinque biciclette di dimensioni naturali. I ganci sono rivestiti in plastica per una massima protezione dai graffi. I fissaggi non sono inclusi.',9,2,4.551778874793179,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Barra per tandem','Consente di collegare qualsiasi bicicletta convenzionali per bambini a biciclette per adulti. Veloce e facile da montare, può essere attaccato senza attrezzi ed essere usato con le biciclette per bambini da 12 a 20 e con un supporto massimo per un peso di 32kg.',9,1,4.975758400432992,89);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lucchetto antifurto','Lucchetto Onguard Brute a U, x4p quattro Bolt. Intrecciato con bubblok, con un cilindro particolare incluso. I materiali con cui è stato realizzato sono acciaio inossidabile temperato e doppio rivestimento in gomma dura.',9,4,4.933784063762471,50);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Casco AeroLite rossonero','Doppio In-Mould costruzione fonde il guscio esterno in policarbonato con Caschi assorbenti del nucleo interno schiuma, dando un casco estremamente leggero e resistente.',9,3,1.9533091906112843,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tappetino da yoga','180 x 61 cm tappeto per utilizzi molteplici. Realizzato in Gomma NBR espansa ad alta densità, lo spessore premium da 12 mm ammortizza confortevolmente la colonna vertebrale, fianchi, ginocchia e gomiti su pavimenti duri.',11,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitness tracker Xiaomi Mi Band 3','Display touch full OLED da 0,78. Durata della batteria fino a 20 giorni (110 mAh). 20 gr di peso. Impermeabile fino a 50 metri (5ATM), Bluetooth 4.2 BLE, compatibile con Android 4.4 / iOS 9.0 o versioni successive.',11,2,4.3438327422962555,54);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corda da saltare','Gritin Corda per Saltare, Regolabile Speed Corda di Salto con la Maniglia di Schiuma di Memoria Molle e Cuscinetti a Sfera - Regolatore di Lunghezza della Corda di Ricambio(Nero)',11,16,4.307536896406173,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ciclette ultrasport cardio','Ultrasport F-Bike Design, Cyclette da Allenamento, Home Trainer, Fitness Bike Pieghevole con Sella in Gel, con Portabevande, Display LCD, Sensori delle Pulsazioni, Capacità di Carico 110kg',11,3,1.0135590663260907,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fasce elastiche fitness','nsonder Elastiche Fitness Set di 4 Bande Elastiche e Fasce di Resistenza per Fitness Yoga Crossfit',11,10,3.2305105136263093,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tesmed elettrostimolatore','Tesmed MAX 830, Elettrostimolatore Muscolare Professionale con 20 elettrodi: massima potenza, addominali, potenziamento muscolare, contratture e inestetismi',11,4,3.5598449910109298,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fascia dimagrante addominale','Fascia Addominale Dimagrante per Uomo e Donna, Regolabile Cintura Addominale Snellente, Brucia Grassi e Fa Sudare, Sauna Dimagranti Addominali, Di Neoprene (Fascia Addominale Dimagrante di fascia 2)',11,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Palla da pilates','BODYMATE Palla da Ginnastica/Fitness Palla da Yoga per Allenamento Yoga & Pilates Core Compresa Pompa - Resistente Fino a 300kg, Disponibile nelle Dimensioni da 55, 65, 75, 85 cm',11,17,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pedana di equilibrio','Emooqi Pedana di Equilibrio in Legno antiscivolo Balance Board per equilibrio e coordinazione Carico massimo circa 150 kg/ dimensione circa 39.5 cm',11,4,2.906256549457499,80);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Piccoli manubri','Coppia di piccoli pesi, perfetti per lallenamento casalingo con centinaia di ripetizioni. Bel colore, materiale gradevole al tatto con ottima grippabilita (anche a mani sudate).',11,1,0.06630300769473574,51);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike React Element 55','Riprendendo le linee di design dai nostri modelli da running leggendari, come Internationalist, la scarpa Nike React Element 55 - Uomo accoglie la storia e la spinge verso il futuro. La schiuma Nike React assicura leggerezza e comfort, mentre i perni in gomma sulla suola e i dettagli rifrangenti offrono un look allavanguardia che vuole una reazione.',23,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike Air Max 1','La scarpa Nike Air Max 1 - Uomo aggiorna il leggendario design con nuovi colori e materiali senza rinunciare alla stessa ammortizzazione leggera delloriginale.',23,4,4.365340229873029,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Air Jordan 1 Retro High OG','La scarpa Air Jordan 1 Retro High OG sfoggia uno stile ispirato alla tradizione, con materiali premium e ammortizzazione reattiva. Il colore mostrato in foto è Vintage Coral/Sail.',23,4,0.23234929061112242,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike Benassi JDI SE','Grazie al suo design astratto, la slider Nike Benassi JDI SE Slide è perfetta per dare energia e vivacità al tuo look. Fascetta sintetica, fodera in jersey e intersuola in schiuma per una sensazione di morbidezza e un comfort ideale.',23,2,0.026361985774540075,109);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Air Jordan 1 Low','Air Jordan 1 Low: struttura premium, morbido comfort. Uno tra i modelli più iconici in assoluto della linea Nike. Uno dei simboli della storia delle scarpe da Basket.',23,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Adidas Stan Smith','Le classiche sneaker Stan Smith in una nuova versione che ripropone dettagli autentici, come la tomaia in pelle con 3 strisce traforate e finiture brillanti a contrasto. Le chiusure a strappo assicurano praticità e comfort',23,17,1.4105540907727476,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ciabatte Adidas Duramo','Perfette prima e dopo ogni allenamento, le ciabatte adidas Duramo sono un classico sportivo. Con un design monoblocco impeccabile, ad asciugatura rapida, queste semplici ciabatte per la doccia offrono un comfort allinsegna della praticità e prestazioni affidabili.',23,1,4.026933151724565,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Gazelle Adidas','Un inno allessenzialità che stupisce da oltre trentanni. Questo remake delle Gazelle rende omaggio al modello del 1991 riproponendo materiali, colori, texture e proporzioni della versione originale. La tomaia in pelle sfoggia 3 strisce a contrasto e un rinforzo sul tallone.',23,1,0.07533093805257685,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('All Star Classic High Top','Le Chuck Taylor All Star sono delle sneaker classiche, che resistono allesame del tempo, a prescindere dalla stagione, dal luogo e dal look. In questo tono giallo pacato daranno la possibilità di sembrare pulcini, per quanto poco utile possa essere.',23,2,1.8065076822763293,86);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Converse One Star Corduroy','Le Converse Custom One Star Corduroy Low Top sono un modello moderno, che non rinuncia allo stile classico ed equilibrato. Prende tuttavia uno spunto dal mondo degli skateboarders americani.',23,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Abbey','I Van Orton Design reinterpretano in chiave pop una delle copertine più celebri e citate della storia della musica e rendono omaggio alla band che ha ridefinito il concetto stesso di “pop”.',26,14,2.00132912000755,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Gran Tour','Un viaggio spensierato tra arte e design, la leggerezza di una gita fuori porta, una famiglia a cavallo di una vespa. Tutto dipinto in punta di pennello, perché ogni viaggio comincia con l’immaginazione.',26,2,1.1666711630172621,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Pink Floyd','“So, so you think you can tell heaven from hell?”. Questa t-shirt dei gemelli Van Orton Design è indossabile soltanto da chi riconosce la citazione originale, che coglierà anche il motivo della grafica rappresentante una stretta di mano particolarmente calda.',26,18,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Go Fast','Come un pinguino, di pancia, sullo skate. Sì, lo sappiamo: i pinguini scivolano benissimo anche senza skate. Ma, vuoi mettere? Philip Giordano ci ricorda che tutto è possibile.',26,3,3.766907433703727,62);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Coca Cola','Doveva essere la copertina per un libro del filosofo Jean Baudrillard ma poi è diventata una maglietta. Forse non ci crederai, ma Matteo Berton ci ha assicurato che le bare a forma di Coca Cola esistono davvero!',26,1,3.375348042805327,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Equilibrio','Questo artwork di Jonathan Calugi nasce da una ricerca sulle connessioni e le percezioni. Un equilibrio di corpi e punti che ci dimostra come l’occhio umano, anche in presenza di elementi incompleti, riesca a ricostruire un’immagine nitida di ciò che sta osservando.',26,3,0.46211477872805995,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Serenade','Un vecchio giradischi, un vinile e quella canzone che ti ricorda di quella volta che avete ballato insieme per la prima volta. Il tutto in unincredibile e futurista illustrazione del maestro di graphic design Alessandro Giorgini.',26,11,2.8908856189444965,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Colori e luce','Riccardo Guasco riesce a rendere poetico anche un fascio di strisce orizzontali; e regalare un sorriso. L’illustrazione fa parte di un progetto col quale Rik ha voluto reinterpretare a modo suo lo stile asettico della scuola astrattista.',26,1,4.691026382604195,105);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Connessioni','Questo lavoro nasce per la serie limitata di carte da gioco Playing Arts. Jonathan ha scelto di illustrare il 2 di fiori con il suo inconfondibile tratto unico rappresentando sovrapposizioni e connessioni che si fondono e si confondono.',26,2,0.956028099297016,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Pizza true love','“Pizza. T’amo senza sapere come, né quando, né dove. T’amo senza limiti né orgoglio: t’amo così, perché non so amarti altrimenti”. Per Mauro Gatti il vero amore sa di pizza.',26,10,3.9456022385059972,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Curved Bill','Il cappellino da jockey Vans Mayfield Curved Bill è un modello con logo Vans ricamato sulla visiera.',27,1,2.5883511133903347,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Vans x Marvel','Vans e Marvel si uniscono per celebrare gli iconici supereroi dellUniverso Marvel in una collezione straordinaria di abbigliamento, calzature e accessori. Il cappellino jockey Vans x Marvel è un modello retrofit regolabile a 6 pannelli con ricamo di Iron Man su tessuto.',27,3,4.666853820688399,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Berretto Core Basics','Il berretto Vans Core Basic è uno zuccotto con targhetta con logo Vans, in colorazione Port Royale. Taglia unica. Disponibile in 7 colorazioni diverse, due delle quali colorate a camouflage.',27,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cappellino Davis 5','Il cappellino Vans Davis è un modello camper a 5 pannelli con etichetta Vans in ecopelle sul pannello anteriore e cinghia di regolazione sul retro. Disponibile in 4 colorazioni bicolore.',27,3,3.5405832905055767,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Vans x Hulk','Vans e Marvel si uniscono per celebrare gli iconici supereroi dellUniverso Marvel in una collezione straordinaria di abbigliamento, calzature e accessori. Il cappellino jockey Vans x Marvel è un modello retrofit regolabile a 6 pannelli con ricamo di Hulk su tessuto.',27,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Baseball Disney x Vans','Realizzato per celebrare lo spirito e levoluzione di Topolino, il cappellino da baseball Disney X Vans in 100% cotone è un modello a 5 pannelli con stampa rétro di Topolino serigrafata.',27,1,1.7326890897402925,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Baseball classic patch','Il cappellino da baseball Classic Patch è un modello a 5 pannelli in 80% acrilico e 20% lana con una visiera in 100% cotone e unapplicazione Vans Off The Wall sul pannello anteriore.',27,1,0.7140522159910201,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Vans Visor Cuff','Il berretto Vans Visor Cuff presenta una stampa mimetica integrale, visiera ed etichetta Vans sul davanti. Pensato per gli skaters che non si vogliono fermare davanti ad un inverno rigido',27,2,2.638081808579803,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cappellino Camper 5','Il cappellino camper Vans Flap a 5 pannelli è realizzato in 100% tela di cotone cerata, presenta copriorecchie trapuntati e unapplicazione Vans in ecopelle a rilievo.',27,4,0.6844234848368325,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Berretto Pom Off The Wall','Il berretto Off The Wall Pom è un modello in 93% acrilico, 6% nylon e 1% elastan con grafica OFF THE WALL in jacquard e pompon.',27,2,2.9325801298262446,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chino Elasticizzati','I pantaloni chino in twill Sturdy Stretch sfoggiano unintramontabile combinazione tra stile classico e praticità necessaria per lo skateboard',24,2,1.8243301097862663,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chino Authentic','Un modello realizzato per mantenere a lungo la forma e lelasticità, con tasche anteriori allamericana, tasche posteriori a filo con chiusura a bottone, unetichetta del brand intessuta e una comoda vestibilità slim leggermente affusolata.',24,4,4.1445681062724224,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Cross Town','I pantaloni sportivi Vans Cross Town presentano nastri su entrambi i lati con il logo Off The Wall, un cordino regolabile con motivo a scacchi in vita e una tasca posteriore con letichetta Vans. Il modello è alto 1,86 m e indossa una taglia 32.',24,4,3.3089847627251743,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jean Vintage Blute Taper','Pensati per offrire comodità e resistenza nel tempo, i Vans V46 Taper sono jeans a vita media in denim con finitura grezza. Questo modello presenta 5 tasche, una patta con cerniera, una mostrina in vera pelle al livello della vita e una vestibilità affusolata che si restringe alla caviglia.',24,2,3.5400718448990434,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jeans Inversion','Dalla vestibilità ampia, i jeans Vans Inversion sono un modello straight con striscia laterale stile smoking, due tasche laterali e due posteriori.',24,3,2.6243301297661747,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Summit','La collezione Design Assembly unisce un design innovativo a un tocco urbano per creare uno stile ricco di dettagli. I pantaloni Vans Summit sono un modello a vita alta corto alla caviglia, con tasche laterali e posteriori, passanti per cintura ed etichetta Vans sul retro.',24,3,3.3612675703166617,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Checkboard Authentic','La collezione Design Assembly unisce un design innovativo a un tocco urbano per creare uno stile ricco di dettagli. Comodi, caldi e oversize come labbigliamento maschile ma con un tocco di femminilità, i pantaloni a gamba larga Design Assembly Checkerboard presentano tasche allamericana e vita medio alta.',24,4,3.71491338814246,48);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Framework Salopette','La salopette Vans Framework è un modello carpenter con cuciture a punto triplo e diverse tasche, tra cui due oblique, una frontale sul petto e tre posteriori. Decorata da bottoni in metallo con logo.',24,2,2.8039099883287277,37);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jeans Skinny 9','I Vans Skinny 9 sono dei jeans skinny a vita alta con tagli sulle ginocchia, due tasche frontali e due posteriori.',24,12,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloncini Tremain','Modello cargo dalla vestibilità comoda, i pantaloncini Tremain sono realizzati in 100% cotone dobby tinto in filo. Colorazione beige e con camouflage militare.',24,3,4.384498534935045,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Girocollo Retro Tall','La felpa girocollo Vans Retro Tall Type è un modello a maniche lunghe con logo Vans sulla parte sinistra del petto e sul retro.',25,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Versa Quarter Zip','Progettata da designer esperti e con collo a lupetto, la felpa Versa Quarter offre il massimo delle prestazioni senza rinunciare allo stile. Realizzata con maestria per resistere alle condizioni atmosferiche e allusura causata dallo skateboard',25,3,2.61055029140125,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa con cappuccio versa','La felpa in pile di qualità è dotata di una tasca a marsupio sul davanti, fodera del cappuccio con stampa a contrasto, maniche con motivo checkerboard serigrafato e un ricamo sul petto.',25,5,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa cappuccio cross town','La felpa Vans Cross Town è un modello a maniche lunghe con tasca frontale a marsupio e cappuccio dotato di cordino con motivo a scacchi. Presenta il logo Vans sul davanti e la grafica Off The Wall sulle cuciture.',25,23,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa classic con cappuccio','La felpa Vans Classic è un modello a maniche lunghe con cappuccio, zip, tasche frontali e logo Vans sul petto.',25,3,0.1712694255167757,109);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa con cappuccio skate','La felpa con cappuccio Vans Skate è realizzata in pile e presenta una tasca a marsupio frontale e il logo Vans sulla parte sinistra del petto.',25,1,2.0773726142150117,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Tall Box Stripe','La felpa con cappuccio Tall Box Stripe è realizzata in 60% cotone e 40% poliestere e presenta una tasca a marsupio sul davanti, righe tinte in filo e ricamo del logo sul petto.',25,2,1.9766411356282865,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Distort','La felpa Vans Distort presenta una tasca a marsupio sul davanti, maniche lunghe, tramezzi laterali a coste e loghi Vans serigrafati su busto, cappuccio e fondo della manica.',25,3,4.590107005709393,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Square Root','La felpa Vans Square Root è un modello con cappuccio, maniche lunghe e una tasca a marsupio sul davanti. È inoltre decorata con il logo Vans sulla parte sinistra del petto e dettaglio checkerboard lungo la manica sinistra.',25,4,3.3476712210153226,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Classic Crew','La felpa Vans Classic è un modello a girocollo con logo Vans stampato sul petto. Disponibile in varie colorazioni, tutte in colori brillanti e stampe di altissima qualità.',25,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('GoPro hero7','Riprese incredibilmente stabili. Capacità di acquisizione intelligente. Robusta e impermeabile senza bisogno di custodia. Tutto questo è HERO7 Black: la GoPro più avanzata di sempre.',19,2,0.690990095113958,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sony DSC-RX100','Sony DSC-RX100 fotocamera digitale compatta, Cyber-shot, sensore CMOS Exmor R da 1 e 20.2 MP, obiettivo Zeiss Vario-Sonnar T, con zoom ottico 3.6x e nero.',19,1,2.201375379116296,26);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nikon D3500','Nikon D3500: fotografa, riprendi video, condividi, divertiti, stupisci. La nuova reflex digitale entry level da 24,2 Megapixel è la fotocamera perfetta per chi si avvicina al mondo della fotografia, in virtù del suo design confortevole e delle sue modalità di ripresa che ne rendono facilissimo luso.',19,1,0.4823287296696266,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sony Alpha 7K','Con i suoi 24,3 megapixel, il sensore Exmor full-frame 35 mm della α7 offre prestazioni che non temono quelle delle migliori reflex digitali. Inoltre, grazie al processore Bionz X e alla messa a fuoco automatica ottima di Sony, lα7 offre un livello di dettaglio, sensibilità e qualità eccellente. Sei pronto per uno shooting fotografico da urlo.',19,16,2.9865051659603017,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nikon Coolpix W100','La W100 è progettata per resistere agli urti da unaltezza massima di 1,8 m, impermeabile fino a 10 m, resistente al freddo fino a -10°C e alla polvere.',19,1,1.3230377995348808,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polaroid Snap','Dai ritratti ai selfie, questa potente fotocamera da 10 MP cattura ogni dettaglio e stampa in un istante, senza bisogno di pellicole o toner. Aggiungi una scheda microSD per salvare le tue foto e stamparle successivamente.',19,4,3.046298934592703,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samoleus Fotocamera Giocattolo','La mini macchina fotografica digitale ha uno schermo di 1,5 pollici. È adatto per migliorare i bambini linteresse di scattare foto, sviluppare il loro cervello e farli amare le attività allaria aperta. Può anche essere usato come regalo perfetto per i bambini.',19,20,4.3805117333417005,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fujifilm X-A5','Fujifilm X-A5 Silver Fotocamera Digitale da 24 Mp e Obiettivo Fujinon XC15-45mm f3.5-5.6 OIS PZ, Sensore CMOS APS-C, Ottiche Intercambiabili, Argento/Nero',19,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Canon EOS M6','Allinterno del corpo compatto di EOS M6 troverai un ampio sensore CMOS da 24,2 megapixel che produce risultati eccellenti anche in condizioni di scarsa luminosità o ad alto contrasto',19,11,4.43834665282308,32);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Olympus OM-1','Una delle migliori fotocamere a pellicola che siano storicamente esistite. Grazie allimpugnatura in cuoio nero e il corpo in acciaio riesce sempre ad essere un grande strumento fotografico, ma allo stesso tempo un grande oggetto di design',19,13,2.9255649299838806,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Apple iPhone XS','Phone X è uno smartphone diverso da tutti gli altri iPhone che abbiamo visto finora e lo splendido schermo OLED è solo uno dei fattori che contribuiscono a fargli ottenere punteggi elevatissimi.',18,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung S9','Samsung Galaxy S9 è uno degli smartphone Android più avanzati e completi che ci siano in circolazione. Dispone di un grande display da 5.8 pollici e di una risoluzione da 2960x1440 pixel che è fra le più elevate attualmente in circolazione.',18,12,1.8812135318465473,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('OnePlus 6T','OnePlus 6T è veloce e fluido grazie al processore Qualcomm Snapdragon 847. OnePlus 6T ha un display 19.5:9 Optic AMOLED che regala un’esperienza immersiva. Uno dei migliori smartphone Android in circolazione.',18,3,0.20061202108136222,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nokia 3310','Uno dei telefoni storicamente più importanti della storia delluomo. Si narra che la leggenda della spada nella roccia sia nata da qui, così come lestinzione dei dinosauri sulla Terra.',18,4,2.9615217074829783,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Topcom Sologic T101','Questo telefono analogico con filo è molto facile da usare. Adatto a persone con problemi di vista grazie ai tasti di grandi dimensioni.',18,2,1.1303144215477778,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Google Pixel 3XL',' Questo smartphone è l’incarnazione di ciò che Google ritiene debba offrire uno smartphone: prestazioni avanzate del comparto fotografico, display ampio e di buona qualità, supporto nativo a tutte le feature dell’assistente virtuale e aggiornamenti costanti del sistema operativo. ',18,1,2.1270221013268555,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG G6','Questo smartphone è la rivoluzione in casa coreana, con design unibody, schermo inedito e addio alla modularità. Il risultato è un prodotto solido e capace di tenere testa a qualunque altra ammiraglia.',18,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei P10 lite','Huawei P10 Lite è l’atto finale di una trilogia e l’inizio della seconda vita di Huawei. Dopo P8 e P9, il lancio del P10 segna un capitolo fondamentale per questa serie di smartphones, portando una serie di innovazioni dal punto di vista dello schermo, della fotocamera e della batteria.',18,1,2.6893769046546137,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Panasonic Telefono Cordless','Panasonic KX-TG1611 offre funzioni come: la rubrica da 50 voci (nome e numero), la memoria di riselezione (fino a 10 numeri), la suoneria portatile selezionabile, la sveglia e lorologio, la risposta con qualsiasi tasto, e altro ancora',18,4,0.2085540898718241,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Motorola RAZR V3','Simbolo dei millennials, questo precursore degli smartphone, caratterizzato dalla forma a guscio tagliente, rimarrà sempre una pietra miliare nella telefonia e nella storia di Motorola.',18,2,4.569886616569669,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundLink Mini Bluetooth II','Il diffusore SoundLink Mini Bluetooth II offre un suono pieno, naturale e con bassi profondi che non ti aspetteresti da un dispositivo così piccolo. Inoltre, è dotato di microfono integrato per rispondere alle chiamate e facilita la connessione in wireless ovunque e in qualsiasi momento.',21,2,0.4535208180662653,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Wave SoundTouch IV','Il Wave music system SoundTouch® appartiene a unintera famiglia di prodotti wireless, da sistemi all-in-one a configurazioni home cinema. I sistemi interagiscono per riprodurre la stessa musica ovunque o musica diversa in stanze diverse. Con SoundTouch®, ascoltare e scoprire nuova musica è più semplice che mai.',21,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundTouch 10','Ciascun diffusore SoundTouch 10 offre un suono ricco e profondo e consente di accedere in wireless alla tua musica preferita. Per cui puoi riprodurre musica diversa in due stanze differenti, o la stessa musica in entrambe le stanze. Inoltre, non potrebbe essere più facile da usare. Per riprodurre la tua musica in streaming, installa lapp gratuita SoundTouch sul tuo dispositivo.',21,1,1.455402526073063,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Soundbar Bose 300','La soundbar SoundTouch 300 offre prestazioni, ampiezza sonora e bassi migliori rispetto a qualsiasi altra soundbar all-in-one di pari dimensioni. Le innovative tecnologie contenute in questa soundbar ti consentono di ottenere il meglio da tutto quello che guardi e ascolti. Driver personalizzati, tecnologie QuietPort e PhaseGuide. ',21,17,2.2823939773948645,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('QuietComfort 20 Noise Canc','Le cuffie QuietComfort 20 Acoustic Noise Cancelling offrono un suono straordinario, ovunque tu sia. Attiva la funzione di riduzione del rumore per concentrarti sullascolto della tua musica e annullare il mondo circostante.',21,2,2.3685590959394744,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuffie QuietComfort 35','Cuffie QuietComfort 35 II wireless: il meglio di Bose. Vantano una tecnologia di riduzione del rumore di prima qualità e accesso diretto ad Amazon Alexa e Google Assistant per un semplice controllo vocale ovunque. La tua musica. La tua voce. Controllo totale.',21,2,2.2533293819002465,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Multimedia Companion',' Il sistema Companion® 50 crea un ambiente acustico di grande impatto, degno di un sistema composto da cinque diffusori. Invece, grazie a Bose®, sono sufficienti due eleganti diffusori da scrivania e un modulo Acoustimass® occultabile.',21,3,1.1341055993162974,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundLink Micro Bluetooth',' Il SoundLink Micro è un diffusore compatto ma potente, estremamente robusto e impermeabile. Inoltre, è dotato di un cinturino in silicone resistente agli strappi, per portarlo sempre con te ovunque. ',21,4,3.8413787841847946,35);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Home Speaker 500','Allinterno del Bose Home Speaker 500, due driver personalizzati puntano in direzioni opposte per far rimbalzare il suono dalle pareti. Il risultato? Un fronte sonoro più ampio di qualsiasi altro diffusore smart, così potente da riempire qualsiasi ambiente con un suono stereo straordinario.',21,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Bass Module 700','Bose Soundbar 700, è il miglior modulo bassi wireless che abbiamo mai ideato per i nostri sistemi home cinema. Infatti, offre le migliori prestazioni possibili con un subwoofer di queste dimensioni. Si connette in wireless alla soundbar e aggiunge ancora più profondità e impatto a tutti i contenuti, dagli effetti speciali dei film dazione alle playlist che risuonano in tutta la casa.',21,1,0.4467553226739307,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG oled tv e8','Il TV LG OLED E8 porta il TV a un livello superiore grazie all’eccezionale qualità delle immagini e al design innovativo che si fondono armoniosamente. L’eleganza del vetro sposa la ricercatezza senza pari della tecnologia OLED per riprodurre immagini straordinarie che sembrano aprire la porta a nuovi mondi.',20,3,0.6942804092484967,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG signature tv oled','TV LG SIGNATURE OLED W rispecchia l’essenza autentica del TV. Il design minimalista, il processore intelligente α9 e AI TV di LG completano la tua esperienza di visione.',20,3,3.137566412017531,19);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung QLED tv 8k','Il TV Samsung QLED 8K Q900R offre un realismo dalla profondità quasi infinita, con dettagli così definiti che ti sembrerà di poterli toccare, come se stessi vivendo ogni scena in prima persona. Questa risoluzione super-elevata è una novità assoluta per la qualità dell’immagine.',20,17,0.3193593914303916,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung The Frame','Più di un semplice TV, The Frame è stato progettato per rendere ogni momento in casa qualcosa di magico. In più, questo televisore vanta una qualità dell’immagine eccellente, poiché si tratta di un incredibile 4K UHD. Scopri di più, ricopri la tua parete di arte ed eleganza.',20,14,0.4236805889669948,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('TV LCD portatile zoshing','1.9 pollici TV widescreen portatile, Risoluzione: 800 x 480, Rapporto: 16: 9. Attraverso lantenna, ingresso USB, lettore di schede TF, ingresso AV e altre opzioni per fornire immagini chiare. Controllo remoto completo.',20,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Philips 55 Smart TV UHD 4K','Smart TV LED 4K ultra sottile con Ambilight su 3 lati e Pixel Plus Ultra HD Versione Ambilight: 3 lati Funzioni Ambilight: Ambilight+Hue integrato Ambilight Music Modalità gioco Modalità Lounge.',20,4,2.4250671696403323,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung MU 6125','I TV UHD Samsung offrono un’esperienza visiva di qualità, con prestazioni Smart immediate e veloci, grazie a: risoluzione 4 volte superiore ai TV FHD, design Slim, da ogni lato, esperienza Smart powered by Tizen.',20,3,4.555052486304259,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('HISense Tv Led','HISENSE H43AE6000 4K Ultra HD con tecnologia HDR e tecnologia Precision Colour, nuova piattaforma SMART VIDAA U e il sistema audio Crystal Clear. La tecnologia HDR estende la gamma di luci e colori migliorando così nettamente la qualità delle immagini, per neri profondi e bianchi brillanti e intensi anche in condizioni di forte contrasto. Potrai così finalmente vedere ogni immagine in ogni minimo dettaglio.',20,4,4.263809401014163,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grundig mod p45','Televisore tubo catodico da camera con doppia antenna ricezione originale e uscite scrd e tv. Modello top di gamma Grundig.',20,2,1.360434003147536,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Philips 6500 series','Smart TV LED ultra sottile 4K. Philips 6500 series Smart TV LED UHD 4K ultra sottile 43PUS6503/12, 109,2 cm (43\), 3840 x 2160 Pixel, LED, Smart TV, Wi-Fi, Nero',20,3,2.9241790464059267,32);




INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list1','desc',1,28);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list2','desc',1,28);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list3','desc',1,12);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list4','desc',1,10);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list5','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list6','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list7','desc',1,14);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list8','desc',1,22);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list9','desc',1,16);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list10','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list11','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list12','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list13','desc',1,11);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list14','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list15','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list16','desc',1,22);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list17','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list18','desc',1,25);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list19','desc',1,14);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list20','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list21','desc',1,20);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list22','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list23','desc',1,28);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list24','desc',1,28);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list25','desc',1,17);




INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,36,9,9,'2019-01-31 02:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,6,5,5,'2019-01-31 19:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,9,7,0,'2019-01-31 07:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,40,2,1,'2019-01-31 15:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,33,1,0,'2019-01-31 04:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,6,6,0,'2019-01-31 02:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,54,16,16,'2019-01-31 17:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,51,5,0,'2019-01-31 15:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,27,8,0,'2019-01-31 11:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,47,15,7,'2019-01-31 00:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,3,4,4,'2019-01-31 04:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,31,18,18,'2019-01-31 03:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,12,17,17,'2019-01-31 18:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,17,8,0,'2019-01-31 10:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,13,19,19,'2019-01-31 13:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,43,18,0,'2019-01-31 13:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,27,6,6,'2019-01-31 04:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,19,8,8,'2019-01-31 01:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,33,2,0,'2019-01-31 12:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,15,17,17,'2019-01-31 07:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,6,9,5,'2019-01-31 19:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,27,16,1,'2019-01-31 02:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,2,18,0,'2019-01-31 00:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,3,5,2,'2019-01-31 11:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,36,7,7,'2019-01-31 13:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,47,5,2,'2019-01-31 14:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,19,15,0,'2019-01-31 06:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,16,18,18,'2019-01-31 05:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,34,3,2,'2019-01-31 11:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,48,3,1,'2019-01-31 03:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,38,14,12,'2019-01-31 11:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,26,14,0,'2019-01-31 01:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,5,7,7,'2019-01-31 06:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,46,4,4,'2019-01-31 12:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,2,3,3,'2019-01-31 07:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,22,10,7,'2019-01-31 17:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,10,7,3,'2019-01-31 16:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,46,20,3,'2019-01-31 11:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,19,17,17,'2019-01-31 10:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,34,7,4,'2019-01-31 16:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,41,10,10,'2019-01-31 14:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,40,20,0,'2019-01-31 18:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,4,14,14,'2019-01-31 04:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,35,20,0,'2019-01-31 05:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,51,11,11,'2019-01-31 01:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,29,16,16,'2019-01-31 12:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,32,3,0,'2019-01-31 07:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,22,8,0,'2019-01-31 14:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,34,14,14,'2019-01-31 03:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,1,19,17,'2019-01-31 04:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,37,16,16,'2019-01-31 02:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,9,15,3,'2019-01-31 09:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,20,14,14,'2019-01-31 12:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,41,5,0,'2019-01-31 01:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,5,4,0,'2019-01-31 10:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,27,19,19,'2019-01-31 00:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,36,10,0,'2019-01-31 10:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,12,13,0,'2019-01-31 01:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,3,17,3,'2019-01-31 18:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,44,9,9,'2019-01-31 07:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,28,18,0,'2019-01-31 19:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,37,20,5,'2019-01-31 16:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,13,5,5,'2019-01-31 12:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,33,20,0,'2019-01-31 16:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,27,6,1,'2019-01-31 00:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,21,10,6,'2019-01-31 12:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,54,19,0,'2019-01-31 16:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,36,8,0,'2019-01-31 18:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,3,11,0,'2019-01-31 18:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,35,4,4,'2019-01-31 15:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,24,4,4,'2019-01-31 16:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,44,17,17,'2019-01-31 04:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,53,15,9,'2019-01-31 12:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,37,6,4,'2019-01-31 00:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,29,20,20,'2019-01-31 18:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,24,13,13,'2019-01-31 03:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,17,15,9,'2019-01-31 14:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,15,20,0,'2019-01-31 19:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,29,6,1,'2019-01-31 05:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,33,4,2,'2019-01-31 13:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,54,7,0,'2019-01-31 09:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,43,12,12,'2019-01-31 15:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,41,14,0,'2019-01-31 04:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,39,3,3,'2019-01-31 00:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,42,17,0,'2019-01-31 11:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,33,4,4,'2019-01-31 01:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,41,16,0,'2019-01-31 08:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,25,5,0,'2019-01-31 09:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,9,3,3,'2019-01-31 08:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,33,5,0,'2019-01-31 11:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,45,9,0,'2019-01-31 19:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,47,8,0,'2019-01-31 13:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,33,8,8,'2019-01-31 00:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,12,18,18,'2019-01-31 17:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,3,18,0,'2019-01-31 09:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,13,14,14,'2019-01-31 14:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,20,17,17,'2019-01-31 01:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,6,18,18,'2019-01-31 07:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,51,13,13,'2019-01-31 12:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,35,16,16,'2019-01-31 17:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,46,13,5,'2019-01-31 14:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,44,1,0,'2019-01-31 09:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,39,20,14,'2019-01-31 08:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,53,6,0,'2019-01-31 14:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,46,5,5,'2019-01-31 17:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,43,19,16,'2019-01-31 02:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,39,15,0,'2019-01-31 17:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,19,16,10,'2019-01-31 13:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,54,12,0,'2019-01-31 06:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,33,8,0,'2019-01-31 02:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,41,11,0,'2019-01-31 18:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,48,2,1,'2019-01-31 18:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,24,6,0,'2019-01-31 04:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,30,17,0,'2019-01-31 02:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,45,2,0,'2019-01-31 06:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,13,6,0,'2019-01-31 19:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,16,18,18,'2019-01-31 15:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,40,9,2,'2019-01-31 04:40:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,9,19,0,'2019-01-31 05:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,5,16,16,'2019-01-31 06:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,29,13,13,'2019-01-31 04:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,22,12,9,'2019-01-31 08:38:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,48,14,14,'2019-01-31 13:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,37,1,1,'2019-01-31 17:41:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,41,12,12,'2019-01-31 17:44:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,43,17,7,'2019-01-31 18:43:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,6,17,4,'2019-01-31 04:43:01');




INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,24,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,23,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,14,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,11,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,24,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,7,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,28,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,19,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,9,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,25,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,7,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,11,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,14,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,24,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,25,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,26,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,26,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,24,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,15,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,25,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,9,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,29,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,11,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,14,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,9,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,19,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,8,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,23,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,15,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,13,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,13,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,28,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,28,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,17,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,29,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,14,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,19,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,26,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,13,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,20,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,16,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,29,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,28,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,25,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,22,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,28,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,11,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,20,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,24,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,5,1);




INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,26,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 19:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,23,'Sto andando a fare la spesa','2019-01-31 02:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,23,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 05:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,29,'Sì','2019-01-31 04:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,29,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 03:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,22,'Sto andando a fare la spesa','2019-01-31 00:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,10,'No','2019-01-31 08:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 01:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,11,'No','2019-01-31 08:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,11,'Sto andando a fare la spesa','2019-01-31 11:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,24,'Sì','2019-01-31 10:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,24,'No','2019-01-31 07:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 04:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 18:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 23:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,24,'No','2019-01-30 21:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,11,'No','2019-01-30 17:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 07:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,11,'No','2019-01-30 23:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,14,'No','2019-01-31 04:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,11,'No','2019-01-31 12:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,14,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 22:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,11,'Sì','2019-01-31 04:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,16,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 22:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,14,'Sto andando a fare la spesa','2019-01-30 20:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,19,'Sto andando a fare la spesa','2019-01-30 20:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,20,'No','2019-01-30 16:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,7,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 07:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,14,'No','2019-01-31 09:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 00:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,24,'Sto andando a fare la spesa','2019-01-31 07:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,24,'Sto andando a fare la spesa','2019-01-31 12:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,25,'No','2019-01-30 16:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 18:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,15,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 01:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,26,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 06:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,26,'No','2019-01-31 12:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,15,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 22:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Sì','2019-01-30 17:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Sì','2019-01-31 07:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'No','2019-01-31 14:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'Sto andando a fare la spesa','2019-01-30 15:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'No','2019-01-31 02:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'No','2019-01-31 09:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'Sto andando a fare la spesa','2019-01-31 01:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'Sto andando a fare la spesa','2019-01-30 18:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,22,'Sto andando a fare la spesa','2019-01-30 17:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,16,'Sì','2019-01-30 15:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 15:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,6,'No','2019-01-31 12:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,29,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 04:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,11,'Sto andando a fare la spesa','2019-01-31 13:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,19,'Sì','2019-01-30 20:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 16:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,9,'Sì','2019-01-31 02:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,21,'Sto andando a fare la spesa','2019-01-31 07:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,21,'Sì','2019-01-30 15:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,9,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 11:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,21,'Sì','2019-01-30 22:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,9,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 06:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,19,'Sì','2019-01-31 11:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,19,'No','2019-01-31 12:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,5,'Sto andando a fare la spesa','2019-01-30 15:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,5,'Sto andando a fare la spesa','2019-01-31 01:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,5,'Sto andando a fare la spesa','2019-01-31 14:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 03:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,5,'No','2019-01-31 05:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,5,'Sto andando a fare la spesa','2019-01-31 09:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,23,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 18:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,5,'Sì','2019-01-31 03:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,12,'No','2019-01-31 00:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,12,'Sto andando a fare la spesa','2019-01-30 15:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,12,'No','2019-01-31 08:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,12,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 19:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,8,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 20:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 01:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,27,'No','2019-01-30 15:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,13,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 09:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,21,'No','2019-01-31 09:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,21,'No','2019-01-30 22:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,13,'Sto andando a fare la spesa','2019-01-31 13:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Sto andando a fare la spesa','2019-01-30 21:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,17,'Sì','2019-01-31 06:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 15:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,28,'No','2019-01-31 09:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,15,'Sì','2019-01-31 12:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'Sì','2019-01-30 16:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'Sto andando a fare la spesa','2019-01-30 19:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'No','2019-01-30 19:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'Sto andando a fare la spesa','2019-01-31 08:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,21,'Sto andando a fare la spesa','2019-01-31 11:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,18,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 08:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,14,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 10:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 16:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,17,'Sì','2019-01-30 19:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,6,'No','2019-01-30 21:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,6,'Sì','2019-01-30 20:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,14,'Sì','2019-01-30 15:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,6,'Sto andando a fare la spesa','2019-01-31 14:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,14,'No','2019-01-30 21:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,21,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 07:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,21,'No','2019-01-30 23:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,20,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 20:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,21,'Sto andando a fare la spesa','2019-01-30 17:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,8,'Sto andando a fare la spesa','2019-01-31 14:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,6,'Sto andando a fare la spesa','2019-01-31 07:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,25,'Sì','2019-01-30 20:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 20:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,25,'Sì','2019-01-31 00:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 06:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,25,'No','2019-01-31 11:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,29,'Sì','2019-01-31 03:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,29,'Sto andando a fare la spesa','2019-01-31 09:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,25,'No','2019-01-31 00:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,25,'Sto andando a fare la spesa','2019-01-30 19:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,9,'Sì','2019-01-30 16:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,20,'Sto andando a fare la spesa','2019-01-30 15:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,20,'Sto andando a fare la spesa','2019-01-30 20:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,9,'No','2019-01-31 08:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,28,'Sì','2019-01-31 10:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,20,'No','2019-01-30 18:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,5,'Sto andando a fare la spesa','2019-01-30 18:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,21,'Sì','2019-01-31 13:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 14:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,29,'No','2019-01-30 19:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 01:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,21,'No','2019-01-30 18:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,27,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 11:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 19:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,5,'No','2019-01-31 05:40:07');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,5,'No','2019-01-31 03:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-31 03:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sto andando a fare la spesa','2019-01-30 15:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sto andando a fare la spesa','2019-01-31 00:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 17:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sto andando a fare la spesa','2019-01-31 09:45:52');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'No','2019-01-30 21:41:33');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'No','2019-01-31 04:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sì','2019-01-31 11:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sì','2019-01-30 18:44:26');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sto andando a fare la spesa','2019-01-30 23:42:59');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,17,'Sto andando a fare la spesa','2019-01-31 03:44:26');




INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,26,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,22,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,15,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,15,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,26,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,25,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,23,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,25,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,15,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,28,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,18,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,10,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,16,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,28,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,6,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,26,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,4,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,22,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,16,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,16,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,27,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,26,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,4,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,16,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,14,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,28,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,6,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,16,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,11,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,10,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,19,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,23,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,8,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,5,1);




