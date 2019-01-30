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
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.amadori4@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.castellaneta5@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.amadori6@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.toldo7@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.castellaneta8@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.chiocco9@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.chiocco10@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.castellaneta11@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.trump12@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.amadori13@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.trump14@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.amadori15@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.amadori16@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.amadori17@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.toldo18@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.trump19@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.trump20@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.chiocco21@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini22@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.amadori23@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.toldo24@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.castellaneta25@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.bini26@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.toldo27@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.toldo28@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.amadori29@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.castellaneta30@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.trump31@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.bini32@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.bini33@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.chiocco34@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.amadori35@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.chiocco36@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.castellaneta37@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.bini38@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.trump39@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.amadori40@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.bini41@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.trump42@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.trump43@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.toldo44@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.chiocco45@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.bini46@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.toldo47@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.castellaneta48@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.toldo49@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Toldo',FALSE);




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




INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spaghetti 500g','Gli spaghetti sono il risultato di una combinazione di grani duri eccellenti e trafile disegnate nei minimi dettagli. Hanno un gusto consistente e trattengono al meglio i sughi.',3,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne rigate 500g','Una pasta gradevolmente ruvida e porosa, grazie alla trafilatura di bronzo. Particolarmente adatta ad assorbire i condimenti, è estremamente versatile in cucina. Ottima abbinata a sughi di carne, verdure e salse bianche. ',3,3,0.24112673626106362,97);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fusilli biologici 500g','Tipo di pasta corta originario dell’Italia meridionale, dalla caratteristica forma a spirale, i fusilli si abbinano a diversi tipi di sugo, dai più semplici a quelli più elaborati. Sono diffusi e prodotti in tutta Italia, in certi casi secondo la metodologia tradizionale a mano.',3,2,0.9426434784974103,77);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tagliatelle alluovo 500g','Nelle Tagliatelle alluovo è racchiuso tutto il sapore della migliore tradizione gastronomica emiliana. Una sfoglia a regola darte che unisce semola di grano duro e uova fresche da galline allevate a terra, in soli 2 millimetri di spessore.',3,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tortelloni ai formaggi','Tortelloni farciti con una varietà di formaggi alto-atesini, dal sapore deciso e dal profumo caratteristico. Ogni tortellone viene farcito con formaggio e spezie (pepe, noci, origano, ...)',3,3,2.8955753795196673,29);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gnocchetti alla tirolese','Gli gnocchetti tirolesi sono preparati con spinaci lessati, farina e uova. Sono caratterizzati dalla tipica forma a goccia e si prestano ad essere preparati da soli o con altri sughi e condimenti.',3,1,3.693429148479038,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chicche di patate','Le chicche di patate sono preparate con pochi e semplici ingredienti: patate fresche cotte a vapore, farina e uova. Ideali per un piatto veloce da preparare e nutriente.',3,4,4.121272243315345,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paccheri napoletani','I paccheri hanno la forma di maccheroni giganti e sono realizzati con trafila di bronzo e semola di grano duro. La superficie è ampia e rugosa, per mantenere alla perfezione il sugo. La forma a cilindro permette la farcitura interna.',3,6,2.7559536277595553,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pizzoccheri della valtellina','La particolarità dei pizzoccheri è la combinazione di ingredienti che ne fanno la pasta. Dal caratteristico colore scuro e con una tessitura grossolana, si esaltano nel condimento tradizionale, una combinazione di pezzi di patate, verza, formaggio Valtellina Casera, burro e salvia.',3,3,1.9821027681940884,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corallini 500g','I Corallini hanno l’aspetto essenziale ed elegante di minuscoli tubetti, cortissimi e di forma liscia. Abili nel trattenere il brodo o i passati, che si incanalano nel loro minuscolo spiraglio, rappresentano una raffinata alternativa nella scelta delle pastine.',3,23,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne lisce 500g','Un formato davvero speciale sotto il profilo della versatilità. Sono perfette per penne allarrabbiata, o al ragù alla bolognese.',3,2,0.3952626242570578,86);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rigatoni 1kg','I rigatoni sono caratterizzati dalla rigatura sulla superficie esterna e dal diametro importante; trattengono perfettamente il condimento su tutta la superficie, esterna ed interna, restituendone ogni sfumatura.',3,19,0.05342912360817964,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucchine verdi','Hanno un sapore gustoso ed intenso: le zucchine verdi scure biologiche sono perfette per essere utilizzate sia da sole che con altri piatti, siano essei a base di verdure o carne. Perfino i loro fiori si usano in cucina con svariate preparazioni.',1,3,0.8971917520587402,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carote Almaverde Bio','Le carote biologiche almaverde bio, oltre ad essere incredibilmente versatili e fresche, fanno bene alla vista e durante la bella stagione sono indicate per aumentare labbronzatura.',1,2,2.221137503855429,48);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patate a pasta gialla','La patata a pasta gialla biologica è forse il tubero più consumato nel mondo. Le patate sono originarie dellamerica centrale e meridionale. Importata in Europa dopo la scoperta dellAmerica, nel 500, si è diffusa in Irlanda, in Inghilterra, in Francia e in Italia.',1,2,2.5578026215148086,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Finocchio tondo oro','Coltivato nelle fertili terre della Campania, il finocchio oro ha un delizioso sapore dolce e una croccantezza unica. Al palato sprigiona un sapore irresistibile ed è ricco di vitamina A, B e C e se consumato crudo è uneccellente fonte di potassio.',1,20,4.888290264597415,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro datterino pachino','Succoso, dolce e profumato! Il pomodoro datterino è perfetto per dare un tocco gustoso alle insalate, ma anche per realizzare deliziose salse e condimenti. Coltivato sotto il caldo sole di Pachino, a Siracusa, è una vera eccellenza nostrana.',1,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro cuore di bue','Ricco di vitamine, sali minerali, acqua, fibre, il Pomodoro Cuore di Bue viene coltivato in varie zone dItalia. La terra fertile e le condizioni climatiche rendono possibile la coltivazione di un pomodoro dal sapore unico, dolce e succoso.',1,1,4.220519034204284,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cetrioli Almaverde Bio','l cetriolo biologico è un frutto ricco di sostanze nutritive che apportano benefici per chi li assume. Ha proprietà lassative grazie alle sue fibre, favorisce la diuresi per la notevole quantità di acqua presente ed è un buon alleato per la pelle se usato come maschera viso.',1,4,3.33759830303207,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carciofo violetto di sicilia','I carciofi sono buoni, utilizzabili per creare molti piatti e possiedono benefici notevoli; la varietà violetta può inoltre conferire un tocco particolare alle ricette di tutti i giorni. Ha un sapore squisito e mantiene le caratteristiche salutari dei carciofi.',1,2,1.8698506137135928,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucca gialla delicata','La zucca Spaghetti o Spaghetti squash è una varietà di zucca unica: la sua polpa è composta di tanti filamenti edibili dalla forma di spaghetti. Con il suo basso contenuto di calorie è ideale per chi vuole tenersi in forma. ',1,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cipolla dorata bio','Cipolla dorata biologica con numerosi benefici e proprietà antiossidanti ed antinfiammatorie. Ideale per preparare zuppe, torte salate o insalate, ma anche e soprattutto ottimi soffritti.',1,4,2.8559308547527706,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Peperoni rossi bio','I peperoni rossi biologici sono ideali per stuzzicare il palato, preparare gustosi e saporiti sughi da abbinare a pasta, carne o zuppe.',1,2,0.798920450050632,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zampina','E’ una salsiccia di qualità, realizzata con carni miste di bovino (compreso primo taglio). La carne, dopo essere stata disossata, viene macinata insieme al basilico in un tritacarne. Il composto ottenuto è unito al resto degli ingredienti e collocato in un’impastatrice, in modo da ottenere un prodotto uniforme e privo di granuli. Infine viene insaccato nelle budella naturali di ovicaprino.',2,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Battuta di Fassona','La battuta al coltello di fassona è uno degli antipasti classici della gastronomia tipica piemontese. La carne di bovino della pregiata razza Fassona viene semplicemente battuta cruda al coltello, in modo da sminuzzarla senza macinarla meccanicamente, lasciando la giusta consistenza alla carne. Si condisce con un filo dolio, un pizzico di sale, pepe e volendo qualche goccia di limone. Si può servire con qualche scaglia di Parmigiano Reggiano.',2,3,2.3382706921842997,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arrosticini di fegato','Originale variante del classico arrosticino di pecora, per chi ama sperimentare combinazioni di sapori insolite e sfiziose. Piccoli bocconcini di freschissimo fegato ovino al 100% italiano, tagliati minuziosamente fino a ottenere porzioni da circa 40 g. Infilati con cura in pratici spiedini di bamboo, ogni singolo cubetto custodisce tutto il gusto intenso e deciso della carne ovina, valorizzato dalla dolcezza e dal carattere della cipolla di Tropea.',2,3,2.6400089643289,104);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia di suino fresca','La preparazione della salsiccia di suino fresca inizia disossando il maiale e selezionando i tagli di carne scelti, che vengono poi macinati con una piastra di diametro 4,5mm. Si procede quindi a preparare l’impasto, con l’aggiunta di solo sale e pepe, che viene amalgamato e poi insaccato. La salsiccia viene quindi legata a mano e lasciata ad asciugare. Si presenta di colore rosa con grana medio-fina. Al palato è morbida e saporita, con gusto leggermente sapido.',2,17,3.636579780223943,59);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bombette','Gustosa carne di coppa suina, tagliata a fettine sottili e arrotolata a involtino attorno a sfiziosi cubetti di formaggio (sì, proprio quello che durante la cottura diventerà cremoso e filante) e sale. Disponibile anche nella variante impanata, sotto forma di spiedino.',2,2,2.647927779711796,43);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia tipo Bra','La Salsiccia di Bra è una salciccia tipica piemontese, prodotta con carni magre di vitellone, macinata finemente e insaccata in budello naturale. La salsiccia non avendo bisogno di stagionatura, può essere consumata fresca durante tutto lanno. Spesso viene venduta attorcigliata, con la caratteristica forma di spirale. Un grande classico della tradizione culinaria piemontese, spesso viene consumata cotta alla griglia, ma l’ideale è gustarla cruda come antipasto.',2,1,1.7983390735739602,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Hamburger ai carciofi','Il gusto delicato e leggermente amaro dei carciofi conferisce una nota particolare alle pregiate schiacciatine di vitello. La tenera carne, macellata e resa ancora più morbida dall’aggiunta di pane e Grana Padano, si sposa alla perfezione con il gusto del carciofo, che la esalta senza coprirne il sapore.',2,2,0.9748090325629877,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coscia alla trevigiana','Le cosce di maiale sono prima disossate, poi speziate e legate a mano. Si procede quindi alla cottura al forno a bassa temperatura, solo con l’aggiunta di spezie naturali, in modo da conservare tutti gli aromi e la morbidezza delle carni. A cottura ultimata, la coscia al forno viene messa a raffreddare, tagliata a metà.  Il colore della carne è rosato, la consistenza è soda e il gusto intenso e molto saporito.',2,2,2.0151039542497298,77);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spezzatino disossato','Tenero, magro e saporito: lo spezzatino biologico senza osso dellazienda agricola Querceta non teme rivali in fatto di qualità, gusto e consistenza. Ricavato dalle parti muscolose di bovini allevati liberamente e con alimentazione biologica dallazienda, questo taglio è a dir poco perfetto sia per il brodo che per la cottura in umido, che rende la carne ancora più morbida e gustosa.',2,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuore di costata','Il cuore di costata di Querceta viene ricavato dai migliori tagli magri di carne bovina, accompagnata da una minima presenza di porzione grassa che, riuscendo a diluire parzialmente il contenuto connettivo, la rende più tenera e saporita.',2,2,0.09010153165097678,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bragiolette','Tenere fettine di carne bovina accuratamente selezionata e farcite con saporito formaggio, prezzemolo e una punta di aglio per ravvivare ulteriormente il già ricco sapore.',2,4,4.500315374362183,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini Findus','I Bastoncini sono fatti con 100% filetti di merluzzo da pesca sostenibile e certificata MSC, sfilettati ancora freschi e surgelati a bordo per garantirti la massima qualità. Sono avvolti nel pangrattato, semplice e croccante, per un gusto inimitabile.',5,1,1.2206755274844394,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pisellini primavera','I Pisellini Primavera sono la parte migliore del raccolto perché vengono selezionati solo quelli più piccoli, teneri e dolci rispetto ai Piselli Novelli. Sono così piccoli, teneri e dolci da rendere ogni piatto più buono.',5,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sofficini','I sofficini godono di un ripieno vibrante e di un gusto mediterraneo, con pomodoro DOP e Mozzarella filante di altissima qualità, in unimpanatura croccante e gustosa.',5,22,1.8565361942487146,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Misto per soffritto','Questo delizioso misto di verdure accuratamente tagliate: carote, sedano e cipolle, è ideale per accompagnare qualsiasi piatto. La preparazione è velocissima.',5,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spinaci cubello','In questa porzione di spinaci surgelati, le foglie della pianta sono adagiate delicatamente una sullaltra, per mantenersi più soffici e più integre. Inoltre, dal punto di vista nutrizionale, i cubelli di Spinaci Foglia forniscono una dose di calcio sufficiente a soddisfare il fabbisogno quotidiano.',5,6,2.294880611315823,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fiori di nasello','I Fiori di Nasello, così teneri e carnosi, sono la parte migliore dei filetti. Pescato nelle acque profonde dellOceano Pacifico, viene sfilettato ancora fresco e surgelato entro 3 ore così da preservarne al meglio sapore e consistenza.',5,1,0.517184555187431,63);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Minestrone tradizionale','Con il minestrone tradizionale, sarà possibile gustare la bontà autentica di ingredienti IGP e DOP, con il gusto unico di verdure al 100% italiane, coltivate in terreni selezionati. Nel minestrone sono presenti patate, carote, cipolle, porri, zucche, spinaci e verze.',5,1,1.8991904630699419,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patatine fritte','Esistono di forma rotonda, ovale o allungata, a pasta bianca o gialla, addirittura viola. Vengono selezionate con attenzione per qualità, dimensione e caratteristiche organolettiche, così da offrire tutto il meglio delle patate offerte dalla terra.',5,3,1.9305110551075089,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cimette di broccoli','Il broccolo è una varietà di cavolo che presenta uninfiorescenza commestibile. La raccolta dei broccoli avviene entro i 4-6 mesi successivi alla semina, poi le cimette sono rapidamente surgelati per preservare le loro proprietà nutrizionali.',5,6,1.5069993421493066,95);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polpette finocchietto','Deliziosi tortini di verdure subito pronti da gustare come antipasto, come contorno o come pratico piatto unico completato da uninsalata.',5,2,3.715365543845135,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Torroncini duri','Un assortimento di torroncini originale e sfizioso, tra cui vale la pena menzionare quelli profumati dalle note agrumate dei bergamotti e dei limoni calabresi, per poi farsi tentare dai gusti più golosi come caffè e nutella.',4,2,1.2811774939415776,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cantucci con cioccolato','Dolci toscani per eccellenza, da accompagnare con vini liquorosi come il Vin Santo, i cantucci offrono un ampio margine per sperimentare nuovi sapori. Fin dal primo morso si apprezza il perfetto equilibrio tra il gusto inconfondibile del cioccolato, esaltato da un lieve sentore di arancia, e limpasto tradizionale del cantuccio, per un risultato croccante e goloso.',4,2,4.408933810566102,80);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Dolcetti alla nocciola','Piccoli e fragranti, con il loro invitante aspetto a forma di rosellina, questi dolcetti alla nocciola sono una specialità dal sapore antico e sempre stuzzicante. Lavorati con nocciole piemontesi Tonda Gentile IGP, i biscottini Michelis sono l’ideale da servire con un buon tè aromatico e delicato. Ottimi anche per la prima colazione.',4,3,0.09463828646055883,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paste di meliga','Tipiche del Piemonte, le paste di Meliga del Monregalese sono dei frollini dalla storia antichissima. La qualità del prodotto è data dallabbinamento di zucchero, uova fresche, burro a chilometro zero e farine locali, per un biscotto semplice e genuino. Fondamentale è il mais Ottofile. La grana grossolana della farina che ne deriva è il segreto di questi biscotti friabili.',4,3,1.5150630026080436,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Amaretti di sicilia','L’aspetto ricorda quello di un semplice biscotto secco ma le apparenze, che spesso ingannano, vengono subito smentite quando al primo morso la pasta comincerà a sciogliersi e rivelarsi in tutta la sua dolcezza. Gli Amaretti di Sicilia vengono presentati in eleganti confezioni regalo, una per ogni variante proposta: classica, al pistacchio di Sicilia, alla gianduia delle Langhe e al mandarino di Sicilia.',4,1,0.4262739204955468,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Celli pieni','Pochi ingredienti, semplici e genuini: il segreto della bontà dei celli ripieni è questo. Basta un piccolo morso per lasciarsi conquistare dal gusto intenso della scrucchijata, speciale confettura a base di uva di Montepulciano che non solo fa da ripieno, ma è il vero e proprio “cuore” di questo antico dolce della tradizione abruzzese.',4,3,1.6452781163636288,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cannoli siciliani','Il cannolo è il dolce siciliano per eccellenza, disponibile in formato mignon e grande. Proveniente dai pascoli del Parco dei Nebrodi e del Parco delle Madonie, la migliore ricotta viene selezionata e lavorata in più fasi per renderla leggera e vellutata, creando un irresistibile contrasto con la granella di pistacchio e la friabile pasta che la ospita.',4,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crema gianduia','Senza grassi aggiunti, né aromi, ogni vasetto custodisce tutta l’essenza dei migliori ingredienti italiani, lavorati con cura e valorizzati da una piacevolissima consistenza. Un’ammaliante linea di creme dal gusto intenso e dolce, che coinvolgerà il palato in una sinfonia di sapori.',4,9,3.9649194972984434,105);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Plum cake','Del classico plum cake resta la morbidezza e la delicatezza, ma per tutto il resto, linterpretazione siciliana si differenzia dallo standard. Uva passa e rum sanno elevare il carattere timido di questo dolce in maniera netta e riuscita. La giusta componente alcolica accende di gusto luva e la frutta secca presente nellimpasto.',4,4,4.956007695450902,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pignolata','Probabilmente il dolce più caratteristico di tutta Messina, immancabile a carnevale ma preparato ed apprezzato tutto lanno. Tanti piccoli gnocchetti di impasto realizzato con farina, uova e alcol vengono fritti ed assemblati. La fase finale prevede una glassatura deliziosa: per metà al limone e per la restante metà al cioccolato.',4,2,4.371923291681247,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo Switch','Nintendo Switch, una console casalinga rivoluzionaria che non solo si connette al televisore di casa tramite la base e il cavo HDMI, ma si trasforma anche in un sistema da gioco portatile estraendola dalla base, grazie al suo schermo ad alta definizione.',7,4,3.0626156453342004,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grand Theft Auto V','Il mondo a esplorazione libera più grande, dinamico e vario mai creato, Grand Theft Auto V fonde narrazione e giocabilità in modi sempre innovativi: i giocatori vestiranno di volta in volta i panni dei tre protagonisti, giocando una storia intricatissima in tutti i suoi aspetti.',7,2,1.4340139107159533,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Toy story 2','Il conto alla rovescia per questavventura comincia su Playstation 1, nei panni di Buzz Lightyear, Woody e tutti i loro amici. Sarà una corsa contro il tempo per salvare la galassia dal malvagio imperatore Zurg.',7,11,0.6399752321657903,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ratchet and Clank','Una fantastica avventura con Ratchet, un orfano Lombax solitario ed esuberante ed un Guerrabot difettoso scappato dalla fabbrica del perfido Presidente Drek, intenzionato ad uccidere i Ranger Galattici perché non intralcino i suoi piani. Questo lincipit dellavventura più cult che ci sia su Playstation.',7,18,4.570525843373864,80);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo snes mini','Replica in miniatura del classico Super Nintendo Entertainment System. Include 21 videogiochi classici, tra cui Super Mario World, The Legend of Zelda, Super Metroid e Final Fantasy III. Sono inclusi 2 controller classici cablati, un cavo HDMI e un cavo di alimentazione.',7,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Playstation 3 Slim','PlayStation 3 slim, a distanza di anni dal lancio del primo modello nel 2007, continua ad essere un sofisticato sistema di home entertainment, grazie al lettore incorporato di Blu-ray disc™ (BD) e alle uscite video che consentono il collegamento ad unampia gamma di schermi dai convenzionali televisori, fino ai più recenti schermi piatti in tecnologia full HD (1080i/1080p).',7,3,2.082352758365661,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xbox 360','Xbox 360 garantisce l’accesso al più vasto portafoglio di giochi disponibile ed un’incredibile offerta di intrattenimento, il tutto ad un prezzo conveniente e con un design fresco ed accattivante, senza rinunciare a performance eccellenti.',7,6,4.498516205189388,95);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crash Bandicoot trilogy','Crash Bandicoot è tornato! Più forte e pronto a scatenarsi con N. Sane Trilogy game collection. Sarà possibile provare Crash Bandicoot come mai prima d’ora in HD. Ruota, salta, scatta e divertiti atttraverso le sfide e le avventure dei tre giochi da dove tutto è iniziato',7,4,1.035415301968191,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pokemon rosso fuoco','In Pokemon Rosso Fuoco sarà possibile sperimentare le nuove funzionalità wireless di Gameboy Advance, impersonando Rosso, un ragazzino di Biancavilla, nel suo viaggio a Kanto. Il suo sogno? Diventare lallenatore più bravo di tutto il mondo!',7,7,0.014679730294475668,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('God of War','Tra dei dellOlimpo e storie di vendette e intrighi di famiglia, Kratos vive nella terra delle divinità e dei mostri norreni. Qui dovrà combattere per la sopravvivenza ed insegnare a suo figlio a fare lo stesso e ad evitare di ripetere gli stessi errori fatali del Fantasma di Sparta.',7,25,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nastro parastinchi','Nastro adesivo in colorazione giallo neon, disponibile anche in altre colorazioni. 3,8cm x 10m. Ideale per legare calzettoni e parastinchi.',8,1,2.470539641738209,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Calzettoni Adidas','Calzettoni Adidas disponibili in numerose colorazioni, con polsini e caviglie con angoli elasticizzati a costine. Imbottiture anatomiche che sostengono e proteggono la caviglia.',8,1,4.768506648964074,77);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglietta Italia','Maglia FIGC, replica originale nazionale italiana. Realizzata con tecnologia Dry Cell Puma, che allontana lumidità dalla pelle per mantenere il corpo asciutto.',8,3,4.368172385659977,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borsone palestra','Borsa Brera / adatto per la scuola - palestra - allenamento - ideale per il tempo libero. Disponibile in diverse colorazioni e adatta a sportivi di qualsiasi tipo. Involucro protettivo incluso.',8,2,0.8079888938444679,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Nike Mercurial','La scarpa da calcio da uomo Nike Mercurial Superfly VI academy CR7 garantisce una perfetta sensazione di palla e con la sua vestibilità comoda e sicura garantisce unaccelerazione ottimale e un rapido cambio di direzione su diverse superfici.',8,1,1.8878199637699544,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Porta da giardino','Porta da Calcio in miniatura, adatta a giardini. Realizzata in uPVC 2,4 x1,7 m; Diametro pali : 68mm. Sistema di bloccaggio ad incastro per maggiore flessibilità e stabilità, per essere montata in appena qualche minuto.',8,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cinesini','Piccoli coni per allenare lagitlità, il coordinamento e la velocità. Molti campi di impiego nellallenamento per il calcio. Sono ben visibili, grazie ai colori appariscenti e contrastanti. Il materiale è flessibile e resistente.',8,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set per arbitri','Carte arbitro da calcio: set di carte arbitro include cartellini rossi e gialli, matita, libro tascabile con carte di scopo punteggio del gioco allinterno e un fischietto allenatore di metallo con un cordino.',8,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglia personalizzata','La Maglia è nella versione neutra e viene personalizzata con Nome e Numero termoapplicati da personale esperto. Viene realizzata al 100% in poliestere. Non ha lo sponsor tecnico e le scritte sono stampate.',8,1,1.789962989987448,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pallone Mondiali','Pallone ufficiale dei mondiali di calcio Fifa. Il pallone Telstar Mechta, il cui nome deriva dalla parola russa per sogno o ambizione, celebra la partecipazione ai mondiali di calcio FIFA 2018 e la competizione. Questo pallone viene fornito con lo stesso design monopanel del Telstar ufficiale 18. ',8,3,2.6608419755271298,82);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zaino da alpinismo','Questa borsa è disponibile in colori attraenti. Ci sono molte tasche con cerniere in questa borsa per diversi oggetti che potrebbero essere necessari per un viaggio allaperto. È imbottito per il massimo comfort. Questa borsa è di 40 e 50/60/80 litri. Tessuto in nylon idrorepellente e antistrappo. Cinghie regolabili e lunghezza del torace.',10,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo demergenza','Questo sacco a pelo di emergenza trattiene il 90% del calore corporeo irradiato in modo da preservare il calore vitale in circostanze fredde e difficili. È abbastanza grande da coprirti dalla testa ai piedi. Dai colori vivaci in arancione vivo, questo sacco a pelo può essere immediatamente visto da lontano, rendendolo un rifugio indispensabile in attesa delle squadre di soccorso. Questo articolo ti aiuta a rimanere adeguatamente isolato dallaria fredda in modo da poter dormire comodamente e calorosamente quando vai in campeggio in inverno. È impermeabile e resistente alla neve, quindi puoi indossarlo come impermeabile per proteggerti dalla pioggia e dalla neve. Se necessario, puoi anche stenderlo su un grande prato come tappetino da picnic.',10,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo','Sacco a pelo lungo di 2 metri per 70 cm di larghezza, ampi, con la possibilità di piegare la borsa quando aperto come una trapunta. Facile da aprire e chiudere con una cerniera che può essere bloccata. La parte superiore è circolare per un maggiore comfort per lutilizzatore. Cerniera di alta qualità e la tasca interna utile per riporre piccoli oggetti. Zipper riduce la perdita di calore. Il tessuto esterno è impermeabile e umidità realizzato con materiali di alta qualità e pieni di fibre offrono comfort e calore. Campo di temperatura tra i 6 ei 21 gradi. Questo sacco a pelo vi terrà al caldo, indipendentemente dal luogo o periodo dellanno.',10,3,2.5823661099164195,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo matrimoniale','Questo sacco a pelo di lusso è semplicemente fantastico. Si arrotola e si ripone facilmente in una borsa da trasporto, include una cerniera integrale con due tiretti ed è dotato di cinghie in velcro laterali. Alcuni dei nostri prodotti sono realizzati o rifiniti a mano. Il colore può variare leggermente e possono essere presenti piccole imperfezioni nelle parti metalliche dovute al processo di rifinitura a mano, che crediamo aggiunga carattere e autenticità al prodotto.',10,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tenda 4 persone','Comode tasche nella tenda interna per accessori e un porta lampada per una lampada da campeggio o torcia completano il comfort. Tenda ventilata per un sonno indisturbato. L ingresso con zanzariera tiene alla larga le fastidiose zanzare. Le cuciture assicurano una grande resistenza allo strappo e, quindi, alla rottura.',10,17,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltello Magnum 8cm','Ottimo accessorio da avere sul campo, per essere pronti a qualsiasi tipo di wood carving o altra necessità. Le dimensioni ne richiedono, tuttavia, lutilizzo previo possesso di porto darmi. Il manico è in colore rosso lucido.',10,1,1.4705472467982939,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini trekking','I bastoncini di fibra di carbonio resistente offrono un supporto più forte dei modelli dalluminio; il peso ultra-leggero (195 g/ciascuno) facilita le camminate riducendo la tensione sui polsi.',10,2,1.2866692118054424,102);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lanterna da fronte','Torcia da testa Inova STS Headlamp Charcoal. Corpo in policarbonato nero resistente. Cinghia elastica in tessuto nero. LED bianco e rosso. Caratteristiche interfaccia Swipe-to-Shine che permette un accesso semplice alle molteplici modalita - il tutto con il tocco di un dito.',10,19,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fornelletto a gas','Fornelletto da campo di facilissimo utilizzo: è sufficiente girare la manopola, ricaricare con una bomboletta di butano e sarà subito pronto a scaldare le pietanze che vi vengono poggiate. Ha uno stabile supporto in plastica dura e la potenza del bruciatore è di 1200 watt.',10,2,3.333956516314002,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borraccia con filtro','Rimuove il 99.99% di batteri a base d acqua,, e il 99.99% di iodio a base d acqua, protozoi parassiti senza sostanze chimiche, o batteriche. Ideale per viaggi, backpacking, campeggi e kit demergenza.',10,1,2.5960945962354662,35);




INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list1','desc',1,16);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list2','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list3','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list4','desc',1,14);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list5','desc',1,30);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list6','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list7','desc',1,14);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list8','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list9','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list10','desc',1,11);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list11','desc',1,26);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list12','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list13','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list14','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list15','desc',1,7);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list16','desc',1,16);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list17','desc',1,7);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list18','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list19','desc',1,11);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list20','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list21','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list22','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list23','desc',1,8);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list24','desc',1,25);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list25','desc',1,15);




INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,50,7,0,'2019-01-30 21:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,49,7,0,'2019-01-31 00:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,24,7,0,'2019-01-31 00:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,1,5,4,'2019-01-30 18:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,11,19,0,'2019-01-30 06:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,27,17,5,'2019-01-30 20:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,53,14,13,'2019-01-30 17:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,38,8,0,'2019-01-30 19:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,19,20,0,'2019-01-30 09:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,24,17,17,'2019-01-30 22:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,15,9,9,'2019-01-30 15:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,48,16,16,'2019-01-30 15:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,44,5,1,'2019-01-30 16:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,37,5,0,'2019-01-30 06:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,10,8,1,'2019-01-30 07:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,9,5,2,'2019-01-30 15:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,51,20,0,'2019-01-30 22:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,47,2,1,'2019-01-30 16:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,29,15,0,'2019-01-30 10:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,44,14,0,'2019-01-30 09:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,41,9,0,'2019-01-30 16:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,9,10,0,'2019-01-30 08:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,49,16,16,'2019-01-30 23:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,47,9,2,'2019-01-30 21:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,28,15,15,'2019-01-30 16:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,17,3,1,'2019-01-30 15:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,27,12,12,'2019-01-30 23:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,27,20,8,'2019-01-30 22:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,7,3,0,'2019-01-30 20:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,32,7,1,'2019-01-30 07:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,47,17,7,'2019-01-30 17:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,39,19,0,'2019-01-30 22:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,33,18,0,'2019-01-30 07:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,50,20,20,'2019-01-30 09:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,47,3,0,'2019-01-30 22:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,14,17,0,'2019-01-30 11:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,3,15,0,'2019-01-30 09:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,19,20,20,'2019-01-30 11:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,24,14,8,'2019-01-30 23:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,7,7,3,'2019-01-30 20:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,30,4,1,'2019-01-30 12:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,6,18,6,'2019-01-30 18:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,16,13,13,'2019-01-30 16:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,48,17,0,'2019-01-30 15:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,1,20,20,'2019-01-30 11:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,53,19,0,'2019-01-30 06:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,19,19,0,'2019-01-30 20:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,41,4,4,'2019-01-30 21:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,20,12,12,'2019-01-30 09:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,31,4,0,'2019-01-30 10:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,36,7,7,'2019-01-30 07:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,44,10,0,'2019-01-30 15:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,20,1,1,'2019-01-30 07:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,9,9,9,'2019-01-31 01:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,34,12,8,'2019-01-30 13:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,35,18,0,'2019-01-30 07:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,10,15,15,'2019-01-30 19:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,27,4,4,'2019-01-30 23:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,21,7,7,'2019-01-30 20:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,45,11,0,'2019-01-30 11:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,35,14,12,'2019-01-30 13:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,10,5,5,'2019-01-30 07:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,9,16,13,'2019-01-30 06:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,4,4,2,'2019-01-30 21:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,21,12,0,'2019-01-30 10:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,38,5,5,'2019-01-30 18:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,28,11,11,'2019-01-30 22:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,12,8,7,'2019-01-30 14:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,30,13,0,'2019-01-30 21:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,44,10,10,'2019-01-30 08:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,4,19,0,'2019-01-30 19:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,47,10,9,'2019-01-31 00:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,54,8,0,'2019-01-30 07:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,13,5,0,'2019-01-30 17:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,17,9,1,'2019-01-30 12:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,28,11,3,'2019-01-30 22:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,46,19,0,'2019-01-30 15:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,3,17,17,'2019-01-30 12:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,30,1,0,'2019-01-30 06:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,1,7,6,'2019-01-30 11:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,29,13,13,'2019-01-30 11:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,21,8,0,'2019-01-30 09:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,40,20,20,'2019-01-30 14:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,22,11,8,'2019-01-30 19:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,47,18,0,'2019-01-30 22:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,17,6,2,'2019-01-30 06:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,14,3,0,'2019-01-30 11:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,35,19,19,'2019-01-30 19:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,29,5,4,'2019-01-30 21:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,15,12,8,'2019-01-30 10:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,40,15,0,'2019-01-31 01:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,4,17,17,'2019-01-30 10:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,26,17,17,'2019-01-30 21:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,4,20,20,'2019-01-30 13:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,26,2,2,'2019-01-30 17:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,53,18,18,'2019-01-30 09:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,34,20,13,'2019-01-30 07:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,25,5,0,'2019-01-30 11:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,44,17,0,'2019-01-30 07:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,11,8,6,'2019-01-30 08:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,3,6,1,'2019-01-30 14:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,35,8,2,'2019-01-30 19:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,8,12,7,'2019-01-30 14:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,42,9,9,'2019-01-30 18:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,4,7,7,'2019-01-30 17:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,3,6,6,'2019-01-30 19:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,23,12,0,'2019-01-30 07:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,16,5,0,'2019-01-30 11:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,46,20,0,'2019-01-30 19:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,36,16,1,'2019-01-30 19:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,17,1,1,'2019-01-30 16:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,37,1,1,'2019-01-30 10:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,28,8,0,'2019-01-30 21:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,46,10,0,'2019-01-30 17:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,27,3,3,'2019-01-30 12:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,35,6,6,'2019-01-30 20:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,31,10,3,'2019-01-30 18:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,11,6,6,'2019-01-30 19:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,10,4,3,'2019-01-30 22:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,54,12,11,'2019-01-30 15:36:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,52,19,19,'2019-01-30 21:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,53,10,3,'2019-01-30 20:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,47,2,2,'2019-01-30 14:31:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,9,13,3,'2019-01-30 21:30:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,52,9,5,'2019-01-30 08:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,22,18,18,'2019-01-30 16:33:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,26,15,2,'2019-01-30 12:34:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,17,6,0,'2019-01-30 19:31:42');




INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,24,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,12,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,19,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,16,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,22,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,26,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,15,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,24,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,7,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,23,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,7,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,17,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,20,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,16,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,7,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,24,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,7,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,23,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,28,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,28,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,20,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,21,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,22,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,25,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,8,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,20,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,7,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,24,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,28,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,21,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,28,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,23,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,26,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,16,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,12,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,9,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,15,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,26,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,28,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,19,1);




INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,20,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,20,'Sì','2019-01-30 12:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,16,'Sì','2019-01-30 20:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,20,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 14:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,20,'Sì','2019-01-30 03:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,20,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 17:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,25,'Sì','2019-01-30 10:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 01:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,18,'No','2019-01-30 12:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,15,'Sì','2019-01-30 11:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 23:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,22,'Sì','2019-01-30 13:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,15,'No','2019-01-30 06:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,19,'Sto andando a fare la spesa','2019-01-30 04:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 11:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,22,'Sì','2019-01-30 04:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,22,'Sto andando a fare la spesa','2019-01-30 03:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,15,'No','2019-01-30 06:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,15,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 03:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Sto andando a fare la spesa','2019-01-30 01:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Sì','2019-01-29 23:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 22:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Sì','2019-01-30 07:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,26,'Sto andando a fare la spesa','2019-01-30 05:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,22,'No','2019-01-29 22:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,16,'Sto andando a fare la spesa','2019-01-30 07:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,22,'No','2019-01-30 15:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,11,'Sto andando a fare la spesa','2019-01-30 11:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,5,'No','2019-01-30 02:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,5,'Sto andando a fare la spesa','2019-01-29 22:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,30,'Sto andando a fare la spesa','2019-01-30 10:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 23:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,30,'Sto andando a fare la spesa','2019-01-30 00:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,30,'No','2019-01-30 08:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,30,'Sto andando a fare la spesa','2019-01-30 00:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,30,'No','2019-01-30 14:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,15,'Sto andando a fare la spesa','2019-01-30 19:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,5,'Sì','2019-01-30 08:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,23,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 06:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,17,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 11:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,18,'Sto andando a fare la spesa','2019-01-30 08:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,23,'No','2019-01-30 04:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,7,'No','2019-01-30 03:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,18,'Sì','2019-01-30 20:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,14,'Sto andando a fare la spesa','2019-01-30 07:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,14,'Sto andando a fare la spesa','2019-01-30 19:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,14,'Sto andando a fare la spesa','2019-01-30 05:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,19,'Sì','2019-01-30 13:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,14,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 11:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,19,'Sto andando a fare la spesa','2019-01-30 13:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,14,'Sto andando a fare la spesa','2019-01-29 22:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,5,'Sì','2019-01-30 06:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'No','2019-01-30 02:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Sì','2019-01-30 06:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Sì','2019-01-30 06:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'No','2019-01-30 13:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Sto andando a fare la spesa','2019-01-30 13:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,5,'Sto andando a fare la spesa','2019-01-30 08:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,20,'Sto andando a fare la spesa','2019-01-30 11:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,20,'Sto andando a fare la spesa','2019-01-30 20:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'No','2019-01-30 05:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Sì','2019-01-29 22:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Sto andando a fare la spesa','2019-01-29 21:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Sì','2019-01-30 08:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,20,'Sì','2019-01-30 07:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Sì','2019-01-30 03:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,20,'No','2019-01-30 11:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Sto andando a fare la spesa','2019-01-30 09:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Sì','2019-01-30 12:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 14:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Sto andando a fare la spesa','2019-01-30 14:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Sto andando a fare la spesa','2019-01-30 11:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 06:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 09:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 03:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'No','2019-01-30 08:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,20,'Sto andando a fare la spesa','2019-01-30 04:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,7,'Sto andando a fare la spesa','2019-01-30 00:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,20,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 19:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Sì','2019-01-30 11:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,26,'Sto andando a fare la spesa','2019-01-29 22:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,16,'Sì','2019-01-29 23:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 07:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,13,'Sì','2019-01-30 13:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,8,'Sì','2019-01-30 02:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,16,'Sì','2019-01-30 02:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,16,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 04:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,8,'No','2019-01-30 14:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 05:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 04:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 01:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,24,'Sto andando a fare la spesa','2019-01-30 14:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 07:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,24,'Sto andando a fare la spesa','2019-01-30 02:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,25,'Sì','2019-01-30 19:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'No','2019-01-30 05:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,5,'No','2019-01-29 21:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,29,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 00:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,25,'Sì','2019-01-30 08:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,5,'Sì','2019-01-29 23:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,5,'Sto andando a fare la spesa','2019-01-30 07:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,5,'Sto andando a fare la spesa','2019-01-29 21:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,5,'No','2019-01-30 04:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 11:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,25,'No','2019-01-30 03:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 04:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,7,'Sto andando a fare la spesa','2019-01-30 08:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,7,'No','2019-01-30 02:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,26,'Sì','2019-01-30 09:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,26,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 04:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 17:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,28,'Sì','2019-01-30 20:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,26,'Sì','2019-01-30 10:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,21,'No','2019-01-30 11:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'Sto andando a fare la spesa','2019-01-30 20:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,16,'Sì','2019-01-30 09:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,20,'Sì','2019-01-30 03:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,18,'Sto andando a fare la spesa','2019-01-30 10:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,27,'Sì','2019-01-29 22:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,27,'No','2019-01-30 11:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,27,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 10:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,18,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 17:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,8,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,5,'Sto andando a fare la spesa','2019-01-29 23:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,22,'Sì','2019-01-30 08:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,8,'No','2019-01-29 22:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,8,'Sto andando a fare la spesa','2019-01-29 23:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,22,'Sì','2019-01-30 07:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,22,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 08:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,8,'No','2019-01-30 01:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,22,'No','2019-01-30 10:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,5,'Sì','2019-01-30 08:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,8,'Sì','2019-01-30 06:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,27,'Sto andando a fare la spesa','2019-01-29 23:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,7,'Sì','2019-01-30 09:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,11,'Sì','2019-01-30 14:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,27,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 10:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,27,'Sto andando a fare la spesa','2019-01-30 10:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'No','2019-01-30 10:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'No','2019-01-30 03:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'Sto andando a fare la spesa','2019-01-30 05:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 09:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,24,'No','2019-01-30 20:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,27,'No','2019-01-30 00:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,26,'Sto andando a fare la spesa','2019-01-29 23:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,27,'Sì','2019-01-30 05:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,16,'Sto andando a fare la spesa','2019-01-30 00:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,16,'No','2019-01-30 20:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,8,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 02:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,16,'No','2019-01-30 13:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,23,'No','2019-01-30 11:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,18,'Sì','2019-01-30 06:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,10,'No','2019-01-30 19:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,6,'Sì','2019-01-30 13:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,8,'Sto andando a fare la spesa','2019-01-30 16:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,10,'Sì','2019-01-30 11:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,8,'Sto andando a fare la spesa','2019-01-30 09:33:08');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,8,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 05:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,11,'No','2019-01-30 08:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,11,'No','2019-01-30 13:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,11,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 09:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,26,'No','2019-01-30 15:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,8,'Sto andando a fare la spesa','2019-01-30 13:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,25,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 23:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 04:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,10,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 03:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,10,'No','2019-01-30 04:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,15,'No','2019-01-30 08:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,9,'Sto andando a fare la spesa','2019-01-29 22:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 10:36:01');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,15,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 08:34:34');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,10,'Sto andando a fare la spesa','2019-01-30 05:37:27');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,28,'Sì','2019-01-30 15:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 01:31:42');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 03:37:27');




INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,27,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,4,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,13,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,8,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,24,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,21,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,27,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,10,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,27,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,14,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,16,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,22,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,14,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,24,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,18,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,21,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,18,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,24,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,15,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,16,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,28,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,28,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,16,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,18,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,23,2);




