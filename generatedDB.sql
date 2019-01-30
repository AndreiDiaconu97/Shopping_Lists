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
	ID VARCHAR(100) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL CONSTRAINT lists_anonymous__category REFERENCES APP.LISTS_CATEGORIES (ID),
	LAST_SEEN TIMESTAMP NOT NULL,
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
	LIST_ANONYMOUS VARCHAR(100) NOT NULL CONSTRAINT lists_anonymous_products__list_anonymous REFERENCES APP.LISTS_ANONYMOUS (ID) ON DELETE CASCADE,
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
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.chiocco4@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.trump5@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.castellaneta6@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini7@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.chiocco8@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.trump9@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.amadori10@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.trump11@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.castellaneta12@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.trump13@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.toldo14@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.toldo15@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.toldo16@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.chiocco17@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.trump18@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.trump19@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.bini20@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.toldo21@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.bini22@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.trump23@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.bini24@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.bini25@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.chiocco26@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.chiocco27@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.trump28@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.trump29@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.trump30@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.toldo31@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.toldo32@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.castellaneta33@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.castellaneta34@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.chiocco35@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mattea.toldo36@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mattea','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.bini37@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.bini38@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.trump39@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini40@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.amadori41@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.trump42@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.castellaneta43@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizia.trump44@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizia','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.castellaneta45@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Castellaneta',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.chiocco46@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Chiocco',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('anna.bini47@alice.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Anna','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('michele.bini48@hotmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Michele','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gianmaria.toldo49@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gianmaria','Toldo',FALSE);




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




INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spaghetti 500g','Gli spaghetti sono il risultato di una combinazione di grani duri eccellenti e trafile disegnate nei minimi dettagli. Hanno un gusto consistente e trattengono al meglio i sughi.',3,1,1.7938018042493276,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne rigate 500g','Una pasta gradevolmente ruvida e porosa, grazie alla trafilatura di bronzo. Particolarmente adatta ad assorbire i condimenti, è estremamente versatile in cucina. Ottima abbinata a sughi di carne, verdure e salse bianche. ',3,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fusilli biologici 500g','Tipo di pasta corta originario dell’Italia meridionale, dalla caratteristica forma a spirale, i fusilli si abbinano a diversi tipi di sugo, dai più semplici a quelli più elaborati. Sono diffusi e prodotti in tutta Italia, in certi casi secondo la metodologia tradizionale a mano.',3,15,2.0524076988609865,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tagliatelle alluovo 500g','Nelle Tagliatelle alluovo è racchiuso tutto il sapore della migliore tradizione gastronomica emiliana. Una sfoglia a regola darte che unisce semola di grano duro e uova fresche da galline allevate a terra, in soli 2 millimetri di spessore.',3,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tortelloni ai formaggi','Tortelloni farciti con una varietà di formaggi alto-atesini, dal sapore deciso e dal profumo caratteristico. Ogni tortellone viene farcito con formaggio e spezie (pepe, noci, origano, ...)',3,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gnocchetti alla tirolese','Gli gnocchetti tirolesi sono preparati con spinaci lessati, farina e uova. Sono caratterizzati dalla tipica forma a goccia e si prestano ad essere preparati da soli o con altri sughi e condimenti.',3,11,1.6518054644082858,91);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chicche di patate','Le chicche di patate sono preparate con pochi e semplici ingredienti: patate fresche cotte a vapore, farina e uova. Ideali per un piatto veloce da preparare e nutriente.',3,1,1.7914822566810296,26);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paccheri napoletani','I paccheri hanno la forma di maccheroni giganti e sono realizzati con trafila di bronzo e semola di grano duro. La superficie è ampia e rugosa, per mantenere alla perfezione il sugo. La forma a cilindro permette la farcitura interna.',3,2,0.27847603750088656,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pizzoccheri della valtellina','La particolarità dei pizzoccheri è la combinazione di ingredienti che ne fanno la pasta. Dal caratteristico colore scuro e con una tessitura grossolana, si esaltano nel condimento tradizionale, una combinazione di pezzi di patate, verza, formaggio Valtellina Casera, burro e salvia.',3,1,2.9126891781203126,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corallini 500g','I Corallini hanno l’aspetto essenziale ed elegante di minuscoli tubetti, cortissimi e di forma liscia. Abili nel trattenere il brodo o i passati, che si incanalano nel loro minuscolo spiraglio, rappresentano una raffinata alternativa nella scelta delle pastine.',3,2,0.4327287752026554,71);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne lisce 500g','Un formato davvero speciale sotto il profilo della versatilità. Sono perfette per penne allarrabbiata, o al ragù alla bolognese.',3,3,1.2977739846330516,62);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rigatoni 1kg','I rigatoni sono caratterizzati dalla rigatura sulla superficie esterna e dal diametro importante; trattengono perfettamente il condimento su tutta la superficie, esterna ed interna, restituendone ogni sfumatura.',3,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucchine verdi','Hanno un sapore gustoso ed intenso: le zucchine verdi scure biologiche sono perfette per essere utilizzate sia da sole che con altri piatti, siano essei a base di verdure o carne. Perfino i loro fiori si usano in cucina con svariate preparazioni.',1,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carote Almaverde Bio','Le carote biologiche almaverde bio, oltre ad essere incredibilmente versatili e fresche, fanno bene alla vista e durante la bella stagione sono indicate per aumentare labbronzatura.',1,3,1.0161343656896693,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patate a pasta gialla','La patata a pasta gialla biologica è forse il tubero più consumato nel mondo. Le patate sono originarie dellamerica centrale e meridionale. Importata in Europa dopo la scoperta dellAmerica, nel 500, si è diffusa in Irlanda, in Inghilterra, in Francia e in Italia.',1,1,3.1455159708111537,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Finocchio tondo oro','Coltivato nelle fertili terre della Campania, il finocchio oro ha un delizioso sapore dolce e una croccantezza unica. Al palato sprigiona un sapore irresistibile ed è ricco di vitamina A, B e C e se consumato crudo è uneccellente fonte di potassio.',1,3,1.6419616947540794,37);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro datterino pachino','Succoso, dolce e profumato! Il pomodoro datterino è perfetto per dare un tocco gustoso alle insalate, ma anche per realizzare deliziose salse e condimenti. Coltivato sotto il caldo sole di Pachino, a Siracusa, è una vera eccellenza nostrana.',1,1,4.629826168067748,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro cuore di bue','Ricco di vitamine, sali minerali, acqua, fibre, il Pomodoro Cuore di Bue viene coltivato in varie zone dItalia. La terra fertile e le condizioni climatiche rendono possibile la coltivazione di un pomodoro dal sapore unico, dolce e succoso.',1,2,4.8606425158131135,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cetrioli Almaverde Bio','l cetriolo biologico è un frutto ricco di sostanze nutritive che apportano benefici per chi li assume. Ha proprietà lassative grazie alle sue fibre, favorisce la diuresi per la notevole quantità di acqua presente ed è un buon alleato per la pelle se usato come maschera viso.',1,1,0.9533730961970854,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carciofo violetto di sicilia','I carciofi sono buoni, utilizzabili per creare molti piatti e possiedono benefici notevoli; la varietà violetta può inoltre conferire un tocco particolare alle ricette di tutti i giorni. Ha un sapore squisito e mantiene le caratteristiche salutari dei carciofi.',1,4,0.35038562862025446,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucca gialla delicata','La zucca Spaghetti o Spaghetti squash è una varietà di zucca unica: la sua polpa è composta di tanti filamenti edibili dalla forma di spaghetti. Con il suo basso contenuto di calorie è ideale per chi vuole tenersi in forma. ',1,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cipolla dorata bio','Cipolla dorata biologica con numerosi benefici e proprietà antiossidanti ed antinfiammatorie. Ideale per preparare zuppe, torte salate o insalate, ma anche e soprattutto ottimi soffritti.',1,24,3.5500904470750347,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Peperoni rossi bio','I peperoni rossi biologici sono ideali per stuzzicare il palato, preparare gustosi e saporiti sughi da abbinare a pasta, carne o zuppe.',1,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zampina','E’ una salsiccia di qualità, realizzata con carni miste di bovino (compreso primo taglio). La carne, dopo essere stata disossata, viene macinata insieme al basilico in un tritacarne. Il composto ottenuto è unito al resto degli ingredienti e collocato in un’impastatrice, in modo da ottenere un prodotto uniforme e privo di granuli. Infine viene insaccato nelle budella naturali di ovicaprino.',2,4,2.415496145435659,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Battuta di Fassona','La battuta al coltello di fassona è uno degli antipasti classici della gastronomia tipica piemontese. La carne di bovino della pregiata razza Fassona viene semplicemente battuta cruda al coltello, in modo da sminuzzarla senza macinarla meccanicamente, lasciando la giusta consistenza alla carne. Si condisce con un filo dolio, un pizzico di sale, pepe e volendo qualche goccia di limone. Si può servire con qualche scaglia di Parmigiano Reggiano.',2,4,0.2516146790804985,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arrosticini di fegato','Originale variante del classico arrosticino di pecora, per chi ama sperimentare combinazioni di sapori insolite e sfiziose. Piccoli bocconcini di freschissimo fegato ovino al 100% italiano, tagliati minuziosamente fino a ottenere porzioni da circa 40 g. Infilati con cura in pratici spiedini di bamboo, ogni singolo cubetto custodisce tutto il gusto intenso e deciso della carne ovina, valorizzato dalla dolcezza e dal carattere della cipolla di Tropea.',2,1,3.806981537161356,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia di suino fresca','La preparazione della salsiccia di suino fresca inizia disossando il maiale e selezionando i tagli di carne scelti, che vengono poi macinati con una piastra di diametro 4,5mm. Si procede quindi a preparare l’impasto, con l’aggiunta di solo sale e pepe, che viene amalgamato e poi insaccato. La salsiccia viene quindi legata a mano e lasciata ad asciugare. Si presenta di colore rosa con grana medio-fina. Al palato è morbida e saporita, con gusto leggermente sapido.',2,4,2.4749926946104814,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bombette','Gustosa carne di coppa suina, tagliata a fettine sottili e arrotolata a involtino attorno a sfiziosi cubetti di formaggio (sì, proprio quello che durante la cottura diventerà cremoso e filante) e sale. Disponibile anche nella variante impanata, sotto forma di spiedino.',2,1,4.917730206300048,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia tipo Bra','La Salsiccia di Bra è una salciccia tipica piemontese, prodotta con carni magre di vitellone, macinata finemente e insaccata in budello naturale. La salsiccia non avendo bisogno di stagionatura, può essere consumata fresca durante tutto lanno. Spesso viene venduta attorcigliata, con la caratteristica forma di spirale. Un grande classico della tradizione culinaria piemontese, spesso viene consumata cotta alla griglia, ma l’ideale è gustarla cruda come antipasto.',2,3,3.024159430817596,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Hamburger ai carciofi','Il gusto delicato e leggermente amaro dei carciofi conferisce una nota particolare alle pregiate schiacciatine di vitello. La tenera carne, macellata e resa ancora più morbida dall’aggiunta di pane e Grana Padano, si sposa alla perfezione con il gusto del carciofo, che la esalta senza coprirne il sapore.',2,3,1.2565248027964926,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coscia alla trevigiana','Le cosce di maiale sono prima disossate, poi speziate e legate a mano. Si procede quindi alla cottura al forno a bassa temperatura, solo con l’aggiunta di spezie naturali, in modo da conservare tutti gli aromi e la morbidezza delle carni. A cottura ultimata, la coscia al forno viene messa a raffreddare, tagliata a metà.  Il colore della carne è rosato, la consistenza è soda e il gusto intenso e molto saporito.',2,2,1.9776852527648192,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spezzatino disossato','Tenero, magro e saporito: lo spezzatino biologico senza osso dellazienda agricola Querceta non teme rivali in fatto di qualità, gusto e consistenza. Ricavato dalle parti muscolose di bovini allevati liberamente e con alimentazione biologica dallazienda, questo taglio è a dir poco perfetto sia per il brodo che per la cottura in umido, che rende la carne ancora più morbida e gustosa.',2,2,2.9734953570798375,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuore di costata','Il cuore di costata di Querceta viene ricavato dai migliori tagli magri di carne bovina, accompagnata da una minima presenza di porzione grassa che, riuscendo a diluire parzialmente il contenuto connettivo, la rende più tenera e saporita.',2,3,2.836461586148069,29);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bragiolette','Tenere fettine di carne bovina accuratamente selezionata e farcite con saporito formaggio, prezzemolo e una punta di aglio per ravvivare ulteriormente il già ricco sapore.',2,1,2.3832276557883314,106);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini Findus','I Bastoncini sono fatti con 100% filetti di merluzzo da pesca sostenibile e certificata MSC, sfilettati ancora freschi e surgelati a bordo per garantirti la massima qualità. Sono avvolti nel pangrattato, semplice e croccante, per un gusto inimitabile.',5,3,0.5059426783779508,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pisellini primavera','I Pisellini Primavera sono la parte migliore del raccolto perché vengono selezionati solo quelli più piccoli, teneri e dolci rispetto ai Piselli Novelli. Sono così piccoli, teneri e dolci da rendere ogni piatto più buono.',5,2,2.9214610343099476,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sofficini','I sofficini godono di un ripieno vibrante e di un gusto mediterraneo, con pomodoro DOP e Mozzarella filante di altissima qualità, in unimpanatura croccante e gustosa.',5,1,1.5971274519975098,37);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Misto per soffritto','Questo delizioso misto di verdure accuratamente tagliate: carote, sedano e cipolle, è ideale per accompagnare qualsiasi piatto. La preparazione è velocissima.',5,3,1.9209405311085148,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spinaci cubello','In questa porzione di spinaci surgelati, le foglie della pianta sono adagiate delicatamente una sullaltra, per mantenersi più soffici e più integre. Inoltre, dal punto di vista nutrizionale, i cubelli di Spinaci Foglia forniscono una dose di calcio sufficiente a soddisfare il fabbisogno quotidiano.',5,1,3.405442622758321,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fiori di nasello','I Fiori di Nasello, così teneri e carnosi, sono la parte migliore dei filetti. Pescato nelle acque profonde dellOceano Pacifico, viene sfilettato ancora fresco e surgelato entro 3 ore così da preservarne al meglio sapore e consistenza.',5,2,4.4563816694778335,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Minestrone tradizionale','Con il minestrone tradizionale, sarà possibile gustare la bontà autentica di ingredienti IGP e DOP, con il gusto unico di verdure al 100% italiane, coltivate in terreni selezionati. Nel minestrone sono presenti patate, carote, cipolle, porri, zucche, spinaci e verze.',5,4,4.0990286440549,54);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patatine fritte','Esistono di forma rotonda, ovale o allungata, a pasta bianca o gialla, addirittura viola. Vengono selezionate con attenzione per qualità, dimensione e caratteristiche organolettiche, così da offrire tutto il meglio delle patate offerte dalla terra.',5,14,3.319171948829788,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cimette di broccoli','Il broccolo è una varietà di cavolo che presenta uninfiorescenza commestibile. La raccolta dei broccoli avviene entro i 4-6 mesi successivi alla semina, poi le cimette sono rapidamente surgelati per preservare le loro proprietà nutrizionali.',5,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polpette finocchietto','Deliziosi tortini di verdure subito pronti da gustare come antipasto, come contorno o come pratico piatto unico completato da uninsalata.',5,10,1.7474735534413366,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Torroncini duri','Un assortimento di torroncini originale e sfizioso, tra cui vale la pena menzionare quelli profumati dalle note agrumate dei bergamotti e dei limoni calabresi, per poi farsi tentare dai gusti più golosi come caffè e nutella.',4,1,3.973857084278989,71);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cantucci con cioccolato','Dolci toscani per eccellenza, da accompagnare con vini liquorosi come il Vin Santo, i cantucci offrono un ampio margine per sperimentare nuovi sapori. Fin dal primo morso si apprezza il perfetto equilibrio tra il gusto inconfondibile del cioccolato, esaltato da un lieve sentore di arancia, e limpasto tradizionale del cantuccio, per un risultato croccante e goloso.',4,3,3.168208935486331,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Dolcetti alla nocciola','Piccoli e fragranti, con il loro invitante aspetto a forma di rosellina, questi dolcetti alla nocciola sono una specialità dal sapore antico e sempre stuzzicante. Lavorati con nocciole piemontesi Tonda Gentile IGP, i biscottini Michelis sono l’ideale da servire con un buon tè aromatico e delicato. Ottimi anche per la prima colazione.',4,2,4.685268268813784,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paste di meliga','Tipiche del Piemonte, le paste di Meliga del Monregalese sono dei frollini dalla storia antichissima. La qualità del prodotto è data dallabbinamento di zucchero, uova fresche, burro a chilometro zero e farine locali, per un biscotto semplice e genuino. Fondamentale è il mais Ottofile. La grana grossolana della farina che ne deriva è il segreto di questi biscotti friabili.',4,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Amaretti di sicilia','L’aspetto ricorda quello di un semplice biscotto secco ma le apparenze, che spesso ingannano, vengono subito smentite quando al primo morso la pasta comincerà a sciogliersi e rivelarsi in tutta la sua dolcezza. Gli Amaretti di Sicilia vengono presentati in eleganti confezioni regalo, una per ogni variante proposta: classica, al pistacchio di Sicilia, alla gianduia delle Langhe e al mandarino di Sicilia.',4,3,2.035098496812038,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Celli pieni','Pochi ingredienti, semplici e genuini: il segreto della bontà dei celli ripieni è questo. Basta un piccolo morso per lasciarsi conquistare dal gusto intenso della scrucchijata, speciale confettura a base di uva di Montepulciano che non solo fa da ripieno, ma è il vero e proprio “cuore” di questo antico dolce della tradizione abruzzese.',4,3,4.114606619563206,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cannoli siciliani','Il cannolo è il dolce siciliano per eccellenza, disponibile in formato mignon e grande. Proveniente dai pascoli del Parco dei Nebrodi e del Parco delle Madonie, la migliore ricotta viene selezionata e lavorata in più fasi per renderla leggera e vellutata, creando un irresistibile contrasto con la granella di pistacchio e la friabile pasta che la ospita.',4,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crema gianduia','Senza grassi aggiunti, né aromi, ogni vasetto custodisce tutta l’essenza dei migliori ingredienti italiani, lavorati con cura e valorizzati da una piacevolissima consistenza. Un’ammaliante linea di creme dal gusto intenso e dolce, che coinvolgerà il palato in una sinfonia di sapori.',4,2,1.9863136358595723,86);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Plum cake','Del classico plum cake resta la morbidezza e la delicatezza, ma per tutto il resto, linterpretazione siciliana si differenzia dallo standard. Uva passa e rum sanno elevare il carattere timido di questo dolce in maniera netta e riuscita. La giusta componente alcolica accende di gusto luva e la frutta secca presente nellimpasto.',4,4,3.8845593622846444,74);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pignolata','Probabilmente il dolce più caratteristico di tutta Messina, immancabile a carnevale ma preparato ed apprezzato tutto lanno. Tanti piccoli gnocchetti di impasto realizzato con farina, uova e alcol vengono fritti ed assemblati. La fase finale prevede una glassatura deliziosa: per metà al limone e per la restante metà al cioccolato.',4,3,0.5628852013880836,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo Switch','Nintendo Switch, una console casalinga rivoluzionaria che non solo si connette al televisore di casa tramite la base e il cavo HDMI, ma si trasforma anche in un sistema da gioco portatile estraendola dalla base, grazie al suo schermo ad alta definizione.',7,3,3.071228699735827,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grand Theft Auto V','Il mondo a esplorazione libera più grande, dinamico e vario mai creato, Grand Theft Auto V fonde narrazione e giocabilità in modi sempre innovativi: i giocatori vestiranno di volta in volta i panni dei tre protagonisti, giocando una storia intricatissima in tutti i suoi aspetti.',7,19,0.9144278808264295,16);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Toy story 2','Il conto alla rovescia per questavventura comincia su Playstation 1, nei panni di Buzz Lightyear, Woody e tutti i loro amici. Sarà una corsa contro il tempo per salvare la galassia dal malvagio imperatore Zurg.',7,2,4.859990389365229,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ratchet and Clank','Una fantastica avventura con Ratchet, un orfano Lombax solitario ed esuberante ed un Guerrabot difettoso scappato dalla fabbrica del perfido Presidente Drek, intenzionato ad uccidere i Ranger Galattici perché non intralcino i suoi piani. Questo lincipit dellavventura più cult che ci sia su Playstation.',7,1,2.3907931892637713,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo snes mini','Replica in miniatura del classico Super Nintendo Entertainment System. Include 21 videogiochi classici, tra cui Super Mario World, The Legend of Zelda, Super Metroid e Final Fantasy III. Sono inclusi 2 controller classici cablati, un cavo HDMI e un cavo di alimentazione.',7,4,4.928696776009512,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Playstation 3 Slim','PlayStation 3 slim, a distanza di anni dal lancio del primo modello nel 2007, continua ad essere un sofisticato sistema di home entertainment, grazie al lettore incorporato di Blu-ray disc™ (BD) e alle uscite video che consentono il collegamento ad unampia gamma di schermi dai convenzionali televisori, fino ai più recenti schermi piatti in tecnologia full HD (1080i/1080p).',7,4,2.9372813706435066,74);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xbox 360','Xbox 360 garantisce l’accesso al più vasto portafoglio di giochi disponibile ed un’incredibile offerta di intrattenimento, il tutto ad un prezzo conveniente e con un design fresco ed accattivante, senza rinunciare a performance eccellenti.',7,1,4.339126492977505,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crash Bandicoot trilogy','Crash Bandicoot è tornato! Più forte e pronto a scatenarsi con N. Sane Trilogy game collection. Sarà possibile provare Crash Bandicoot come mai prima d’ora in HD. Ruota, salta, scatta e divertiti atttraverso le sfide e le avventure dei tre giochi da dove tutto è iniziato',7,4,2.3995064876426095,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pokemon rosso fuoco','In Pokemon Rosso Fuoco sarà possibile sperimentare le nuove funzionalità wireless di Gameboy Advance, impersonando Rosso, un ragazzino di Biancavilla, nel suo viaggio a Kanto. Il suo sogno? Diventare lallenatore più bravo di tutto il mondo!',7,2,0.5166952395885449,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('God of War','Tra dei dellOlimpo e storie di vendette e intrighi di famiglia, Kratos vive nella terra delle divinità e dei mostri norreni. Qui dovrà combattere per la sopravvivenza ed insegnare a suo figlio a fare lo stesso e ad evitare di ripetere gli stessi errori fatali del Fantasma di Sparta.',7,10,2.9145766095841577,77);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nastro parastinchi','Nastro adesivo in colorazione giallo neon, disponibile anche in altre colorazioni. 3,8cm x 10m. Ideale per legare calzettoni e parastinchi.',8,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Calzettoni Adidas','Calzettoni Adidas disponibili in numerose colorazioni, con polsini e caviglie con angoli elasticizzati a costine. Imbottiture anatomiche che sostengono e proteggono la caviglia.',8,4,1.372014587569016,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglietta Italia','Maglia FIGC, replica originale nazionale italiana. Realizzata con tecnologia Dry Cell Puma, che allontana lumidità dalla pelle per mantenere il corpo asciutto.',8,11,4.298462482715573,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borsone palestra','Borsa Brera / adatto per la scuola - palestra - allenamento - ideale per il tempo libero. Disponibile in diverse colorazioni e adatta a sportivi di qualsiasi tipo. Involucro protettivo incluso.',8,4,4.028697500598958,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Nike Mercurial','La scarpa da calcio da uomo Nike Mercurial Superfly VI academy CR7 garantisce una perfetta sensazione di palla e con la sua vestibilità comoda e sicura garantisce unaccelerazione ottimale e un rapido cambio di direzione su diverse superfici.',8,1,3.8385622116553506,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Porta da giardino','Porta da Calcio in miniatura, adatta a giardini. Realizzata in uPVC 2,4 x1,7 m; Diametro pali : 68mm. Sistema di bloccaggio ad incastro per maggiore flessibilità e stabilità, per essere montata in appena qualche minuto.',8,3,1.7761872139276913,77);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cinesini','Piccoli coni per allenare lagitlità, il coordinamento e la velocità. Molti campi di impiego nellallenamento per il calcio. Sono ben visibili, grazie ai colori appariscenti e contrastanti. Il materiale è flessibile e resistente.',8,2,1.1596577831268817,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set per arbitri','Carte arbitro da calcio: set di carte arbitro include cartellini rossi e gialli, matita, libro tascabile con carte di scopo punteggio del gioco allinterno e un fischietto allenatore di metallo con un cordino.',8,4,4.061667564666899,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglia personalizzata','La Maglia è nella versione neutra e viene personalizzata con Nome e Numero termoapplicati da personale esperto. Viene realizzata al 100% in poliestere. Non ha lo sponsor tecnico e le scritte sono stampate.',8,2,0.4865607826450613,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pallone Mondiali','Pallone ufficiale dei mondiali di calcio Fifa. Il pallone Telstar Mechta, il cui nome deriva dalla parola russa per sogno o ambizione, celebra la partecipazione ai mondiali di calcio FIFA 2018 e la competizione. Questo pallone viene fornito con lo stesso design monopanel del Telstar ufficiale 18. ',8,2,2.998602189891696,70);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zaino da alpinismo','Questa borsa è disponibile in colori attraenti. Ci sono molte tasche con cerniere in questa borsa per diversi oggetti che potrebbero essere necessari per un viaggio allaperto. È imbottito per il massimo comfort. Questa borsa è di 40 e 50/60/80 litri. Tessuto in nylon idrorepellente e antistrappo. Cinghie regolabili e lunghezza del torace.',10,2,1.8977035195584313,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo demergenza','Questo sacco a pelo di emergenza trattiene il 90% del calore corporeo irradiato in modo da preservare il calore vitale in circostanze fredde e difficili. È abbastanza grande da coprirti dalla testa ai piedi. Dai colori vivaci in arancione vivo, questo sacco a pelo può essere immediatamente visto da lontano, rendendolo un rifugio indispensabile in attesa delle squadre di soccorso. Questo articolo ti aiuta a rimanere adeguatamente isolato dallaria fredda in modo da poter dormire comodamente e calorosamente quando vai in campeggio in inverno. È impermeabile e resistente alla neve, quindi puoi indossarlo come impermeabile per proteggerti dalla pioggia e dalla neve. Se necessario, puoi anche stenderlo su un grande prato come tappetino da picnic.',10,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo','Sacco a pelo lungo di 2 metri per 70 cm di larghezza, ampi, con la possibilità di piegare la borsa quando aperto come una trapunta. Facile da aprire e chiudere con una cerniera che può essere bloccata. La parte superiore è circolare per un maggiore comfort per lutilizzatore. Cerniera di alta qualità e la tasca interna utile per riporre piccoli oggetti. Zipper riduce la perdita di calore. Il tessuto esterno è impermeabile e umidità realizzato con materiali di alta qualità e pieni di fibre offrono comfort e calore. Campo di temperatura tra i 6 ei 21 gradi. Questo sacco a pelo vi terrà al caldo, indipendentemente dal luogo o periodo dellanno.',10,2,4.349990466845083,86);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo matrimoniale','Questo sacco a pelo di lusso è semplicemente fantastico. Si arrotola e si ripone facilmente in una borsa da trasporto, include una cerniera integrale con due tiretti ed è dotato di cinghie in velcro laterali. Alcuni dei nostri prodotti sono realizzati o rifiniti a mano. Il colore può variare leggermente e possono essere presenti piccole imperfezioni nelle parti metalliche dovute al processo di rifinitura a mano, che crediamo aggiunga carattere e autenticità al prodotto.',10,4,3.1013789670430425,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tenda 4 persone','Comode tasche nella tenda interna per accessori e un porta lampada per una lampada da campeggio o torcia completano il comfort. Tenda ventilata per un sonno indisturbato. L ingresso con zanzariera tiene alla larga le fastidiose zanzare. Le cuciture assicurano una grande resistenza allo strappo e, quindi, alla rottura.',10,2,2.112806937853474,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltello Magnum 8cm','Ottimo accessorio da avere sul campo, per essere pronti a qualsiasi tipo di wood carving o altra necessità. Le dimensioni ne richiedono, tuttavia, lutilizzo previo possesso di porto darmi. Il manico è in colore rosso lucido.',10,5,4.078964202933381,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini trekking','I bastoncini di fibra di carbonio resistente offrono un supporto più forte dei modelli dalluminio; il peso ultra-leggero (195 g/ciascuno) facilita le camminate riducendo la tensione sui polsi.',10,4,4.415677357045261,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lanterna da fronte','Torcia da testa Inova STS Headlamp Charcoal. Corpo in policarbonato nero resistente. Cinghia elastica in tessuto nero. LED bianco e rosso. Caratteristiche interfaccia Swipe-to-Shine che permette un accesso semplice alle molteplici modalita - il tutto con il tocco di un dito.',10,4,4.6962068257273994,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fornelletto a gas','Fornelletto da campo di facilissimo utilizzo: è sufficiente girare la manopola, ricaricare con una bomboletta di butano e sarà subito pronto a scaldare le pietanze che vi vengono poggiate. Ha uno stabile supporto in plastica dura e la potenza del bruciatore è di 1200 watt.',10,1,1.2509930301692374,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borraccia con filtro','Rimuove il 99.99% di batteri a base d acqua,, e il 99.99% di iodio a base d acqua, protozoi parassiti senza sostanze chimiche, o batteriche. Ideale per viaggi, backpacking, campeggi e kit demergenza.',10,2,4.302015017902017,32);




INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list1','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list2','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list3','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list4','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list5','desc',1,9);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list6','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list7','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list8','desc',1,12);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list9','desc',1,25);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list10','desc',1,27);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list11','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list12','desc',1,20);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list13','desc',1,20);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list14','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list15','desc',1,20);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list16','desc',1,15);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list17','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list18','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list19','desc',1,7);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list20','desc',1,28);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list21','desc',1,16);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list22','desc',1,12);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list23','desc',1,25);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list24','desc',1,26);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('list25','desc',1,27);




INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,36,10,5,'2019-01-30 03:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,42,18,18,'2019-01-29 17:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,26,17,6,'2019-01-30 07:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,31,5,0,'2019-01-29 23:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,40,14,0,'2019-01-29 21:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,12,17,0,'2019-01-29 21:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,32,15,15,'2019-01-29 21:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,54,14,5,'2019-01-29 17:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,33,3,3,'2019-01-30 07:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,24,13,13,'2019-01-30 06:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,28,7,7,'2019-01-29 18:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,45,6,0,'2019-01-29 21:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,14,4,4,'2019-01-30 07:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,21,13,13,'2019-01-29 14:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,37,9,2,'2019-01-29 17:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,3,10,5,'2019-01-29 20:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,17,20,0,'2019-01-29 23:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,8,9,8,'2019-01-29 15:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,49,19,0,'2019-01-30 00:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,37,9,8,'2019-01-29 13:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,29,17,14,'2019-01-30 03:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,20,7,5,'2019-01-30 00:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,1,6,6,'2019-01-30 01:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,36,4,2,'2019-01-30 05:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,28,3,0,'2019-01-29 23:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,39,13,9,'2019-01-29 23:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,50,3,1,'2019-01-30 01:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,32,16,16,'2019-01-30 00:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,51,9,8,'2019-01-29 22:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,4,19,0,'2019-01-29 19:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,15,18,13,'2019-01-30 00:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,22,13,0,'2019-01-29 17:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,19,3,3,'2019-01-30 06:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,25,19,17,'2019-01-29 14:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,5,16,16,'2019-01-30 02:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,28,5,0,'2019-01-30 03:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,14,5,1,'2019-01-30 03:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,33,14,4,'2019-01-29 20:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,38,10,10,'2019-01-30 00:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,31,4,4,'2019-01-29 23:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,27,13,0,'2019-01-30 04:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,38,1,0,'2019-01-29 14:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,1,2,2,'2019-01-29 12:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,28,14,6,'2019-01-30 00:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,19,20,0,'2019-01-30 04:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,52,17,17,'2019-01-29 22:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,22,16,0,'2019-01-29 14:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,50,5,0,'2019-01-30 02:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,35,18,18,'2019-01-29 15:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,39,3,1,'2019-01-29 16:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,23,5,2,'2019-01-30 01:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,44,20,20,'2019-01-29 14:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,32,5,5,'2019-01-29 18:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,26,7,7,'2019-01-29 19:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,4,10,0,'2019-01-30 05:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,17,8,1,'2019-01-29 12:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,46,17,0,'2019-01-30 04:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,11,18,0,'2019-01-29 13:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,5,3,0,'2019-01-29 14:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,43,3,3,'2019-01-29 23:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,10,2,1,'2019-01-29 15:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,54,4,3,'2019-01-30 03:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,46,14,12,'2019-01-30 04:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,1,8,0,'2019-01-29 13:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,50,14,14,'2019-01-29 21:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,27,1,1,'2019-01-29 16:13:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,16,14,0,'2019-01-29 14:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,38,20,5,'2019-01-29 16:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,8,6,1,'2019-01-29 12:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,13,17,10,'2019-01-29 23:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,11,3,0,'2019-01-30 00:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,36,9,0,'2019-01-29 18:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,47,18,9,'2019-01-29 22:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,10,8,0,'2019-01-29 18:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,38,19,19,'2019-01-30 01:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,7,8,8,'2019-01-30 05:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,4,5,0,'2019-01-29 19:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,10,3,1,'2019-01-30 04:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,25,13,0,'2019-01-29 21:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,50,9,5,'2019-01-29 19:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,21,2,2,'2019-01-29 17:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,48,6,0,'2019-01-29 22:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,37,3,3,'2019-01-29 20:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,43,7,0,'2019-01-29 13:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,19,12,0,'2019-01-29 13:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,45,13,12,'2019-01-30 05:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,7,12,12,'2019-01-29 18:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,33,15,0,'2019-01-29 20:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,39,7,7,'2019-01-30 07:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,54,20,0,'2019-01-29 23:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,52,20,13,'2019-01-29 12:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,35,6,6,'2019-01-30 02:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,37,4,0,'2019-01-30 05:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,34,14,0,'2019-01-29 19:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,50,18,0,'2019-01-30 07:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,53,19,19,'2019-01-29 23:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,19,1,0,'2019-01-30 04:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,33,14,2,'2019-01-30 05:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,6,8,8,'2019-01-29 15:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,21,16,0,'2019-01-29 13:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,25,19,12,'2019-01-30 02:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,53,4,3,'2019-01-29 16:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,51,15,15,'2019-01-30 01:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,43,5,5,'2019-01-29 22:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,10,4,4,'2019-01-29 23:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,44,20,0,'2019-01-29 22:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,14,18,18,'2019-01-30 00:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,43,9,9,'2019-01-30 05:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,26,18,8,'2019-01-29 16:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,42,7,0,'2019-01-29 16:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,36,11,0,'2019-01-29 17:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,13,13,13,'2019-01-29 15:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,50,5,0,'2019-01-29 17:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,53,13,0,'2019-01-30 07:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,33,7,7,'2019-01-29 14:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,34,17,17,'2019-01-30 01:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,26,18,13,'2019-01-29 16:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,38,12,12,'2019-01-29 12:13:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,50,8,6,'2019-01-30 05:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,43,3,0,'2019-01-29 18:14:29');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,45,7,5,'2019-01-29 18:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,52,3,0,'2019-01-29 21:18:48');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,40,15,0,'2019-01-30 07:15:55');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,10,7,7,'2019-01-30 02:17:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,17,17,2,'2019-01-29 17:13:03');




INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,3,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,4,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,4,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,14,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,1,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,23,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,3,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,15,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,24,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,25,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,9,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,8,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,4,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,7,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,23,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,4,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,23,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,4,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,3,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,1,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,24,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,6,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,3,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,1,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,23,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,6,1);




INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'No','2019-01-29 18:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'Sto andando a fare la spesa','2019-01-29 19:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'Sì','2019-01-29 21:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'No','2019-01-30 01:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 02:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,21,'No','2019-01-29 18:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,21,'Sì','2019-01-29 21:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,5,'Sto andando a fare la spesa','2019-01-29 17:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 06:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,6,'Sto andando a fare la spesa','2019-01-29 06:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 07:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,24,'Sì','2019-01-29 16:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 22:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,6,'Sì','2019-01-29 13:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 09:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,4,'Sì','2019-01-29 22:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,9,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 16:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 18:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,24,'Sì','2019-01-29 04:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,5,'No','2019-01-29 12:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,14,'No','2019-01-29 13:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,14,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 14:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,14,'Sì','2019-01-30 02:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,4,'No','2019-01-29 06:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Sì','2019-01-29 13:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,9,'Sto andando a fare la spesa','2019-01-29 14:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Sto andando a fare la spesa','2019-01-29 22:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,9,'Sì','2019-01-29 10:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 18:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 09:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,6,'Sto andando a fare la spesa','2019-01-29 07:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,5,'Sto andando a fare la spesa','2019-01-29 20:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,23,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 00:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,6,'Sto andando a fare la spesa','2019-01-30 02:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,6,'No','2019-01-30 01:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,6,'No','2019-01-29 06:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,15,'Sto andando a fare la spesa','2019-01-29 11:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,25,'No','2019-01-29 20:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,15,'No','2019-01-29 20:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Sì','2019-01-29 20:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,15,'Sto andando a fare la spesa','2019-01-29 11:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,11,'No','2019-01-29 07:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,3,'Sto andando a fare la spesa','2019-01-29 11:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,5,'Sto andando a fare la spesa','2019-01-29 16:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,5,'No','2019-01-30 00:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 16:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Sto andando a fare la spesa','2019-01-29 11:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,24,'No','2019-01-29 12:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,24,'No','2019-01-29 06:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,13,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 07:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,6,'Sto andando a fare la spesa','2019-01-29 22:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,24,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 03:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'No','2019-01-29 08:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,25,'Sì','2019-01-29 08:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,25,'Sto andando a fare la spesa','2019-01-29 05:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,6,'Sì','2019-01-29 23:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,18,'Sto andando a fare la spesa','2019-01-29 11:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,11,'No','2019-01-29 15:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,5,'No','2019-01-29 12:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 23:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'No','2019-01-30 02:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 12:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,6,'No','2019-01-29 13:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,6,'Sto andando a fare la spesa','2019-01-29 07:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,25,'No','2019-01-29 13:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,6,'Sì','2019-01-29 04:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,21,'No','2019-01-29 18:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,25,'Sì','2019-01-30 00:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,9,'No','2019-01-29 18:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,5,'Sto andando a fare la spesa','2019-01-29 07:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 15:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,21,'No','2019-01-29 23:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,6,'Sì','2019-01-29 12:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,6,'No','2019-01-29 11:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,6,'No','2019-01-29 06:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,5,'Sì','2019-01-29 19:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,9,'No','2019-01-29 16:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,12,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 11:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,8,'No','2019-01-29 21:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,6,'Sto andando a fare la spesa','2019-01-29 03:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,8,'Sì','2019-01-29 17:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,19,'No','2019-01-29 15:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,19,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 16:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,16,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 00:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Sì','2019-01-29 16:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,23,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 15:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 10:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,20,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Sto andando a fare la spesa','2019-01-29 10:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,20,'No','2019-01-29 03:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,20,'No','2019-01-29 06:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,4,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,9,'No','2019-01-29 08:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'No','2019-01-29 21:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'No','2019-01-29 07:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'Sto andando a fare la spesa','2019-01-29 05:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'No','2019-01-29 13:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'Sì','2019-01-30 02:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'Sì','2019-01-30 00:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,5,'No','2019-01-29 18:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,14,'Sto andando a fare la spesa','2019-01-29 03:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,14,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 13:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,22,'Sì','2019-01-29 05:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,7,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 09:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,22,'Sì','2019-01-29 08:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 15:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,7,'Sì','2019-01-29 14:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 22:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,7,'Sto andando a fare la spesa','2019-01-29 03:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,9,'Sto andando a fare la spesa','2019-01-29 23:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,28,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 17:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,28,'Sì','2019-01-29 18:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,28,'Sto andando a fare la spesa','2019-01-30 01:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,3,'Sì','2019-01-29 04:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,1,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 05:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 10:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,1,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 07:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,3,'Sì','2019-01-29 05:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,3,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 20:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,3,'No','2019-01-29 22:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,6,'Sto andando a fare la spesa','2019-01-29 20:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,1,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 09:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,5,'No','2019-01-29 05:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,12,'Sto andando a fare la spesa','2019-01-29 23:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,21,'No','2019-01-30 00:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,12,'No','2019-01-29 05:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,12,'No','2019-01-29 13:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,21,'Sto andando a fare la spesa','2019-01-29 23:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,25,'No','2019-01-29 21:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,6,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 05:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,6,'Sì','2019-01-29 10:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,6,'Sto andando a fare la spesa','2019-01-29 07:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,25,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 21:14:29');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,5,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-30 00:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,6,'No','2019-01-29 09:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,25,'No','2019-01-30 02:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,10,'Sì','2019-01-29 04:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,6,'No','2019-01-30 02:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,13,'No','2019-01-29 10:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,3,'Sì','2019-01-29 06:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,3,'No','2019-01-29 10:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,26,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 08:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,26,'Sì','2019-01-29 11:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,20,'Sì','2019-01-30 00:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,25,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 08:18:48');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,27,'Sì','2019-01-29 11:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,5,'Sto andando a fare la spesa','2019-01-29 08:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,6,'Sto andando a fare la spesa','2019-01-29 16:20:14');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,27,'Sto andando a fare la spesa','2019-01-29 04:15:55');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,27,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 14:17:22');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,27,'Buongiornissimo kkafffèèè ?!?? :))','2019-01-29 13:20:14');




INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,43,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,35,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,28,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,24,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,49,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,40,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,33,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,41,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,25,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,37,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,36,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,10,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,43,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,33,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,41,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,33,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,37,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,37,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,40,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,30,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,28,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,37,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,40,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,36,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,36,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,42,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,33,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,34,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,47,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,31,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,36,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,36,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,31,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,15,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,46,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,29,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,36,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,42,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,44,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,47,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,48,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,37,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,37,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,42,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,21,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,44,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,37,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,45,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,43,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,32,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,33,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,19,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,10,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,15,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,48,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,19,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,40,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,37,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,36,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,25,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,43,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,14,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,19,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,36,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,49,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,11,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,24,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,24,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,37,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,48,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,29,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,45,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,43,2);




