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

INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrea97.pro@gmail.com', '$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS', 'Andrea', 'Matto', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrei.diaconu@studenti.unitn.it', '$2a$10$bek3pnCbDuA7YfLXHDpVi./CPITBTv.nPud1Q63WukdgtKsrr.NCe', 'Andrei', 'Kontorto', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrea.iossa@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'Andrea', 'Ioza', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('edoardo.meneghini@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'Edoardo', 'Meneghini', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('matteo.bini@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'Matteo', 'Bini', false);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('diego.stringari4@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Diego','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martina.aldi5@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martina','Aldi',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('salvatore.vitale6@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Salvatore','Vitale',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.morelli7@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Morelli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martino.castelli8@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martino','Castelli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('lucia.marchetti9@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Lucia','Marchetti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('vincenzo.stringari10@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Vincenzo','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.chiocchetti11@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Chiocchetti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.stringari12@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gabriele.russo13@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gabriele','Russo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('vincenzo.aldi14@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Vincenzo','Aldi',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.santoro15@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Santoro',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizio.castelli16@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizio','Castelli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('emma.conte17@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Emma','Conte',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('adam.russo18@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Adam','Russo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirko.malfer19@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirko','Malfer',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirco.vitale20@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirco','Vitale',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('ginevra.chiocchetti21@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Ginevra','Chiocchetti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('tommaso.trump22@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Tommaso','Trump',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('tommaso.valentini23@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Tommaso','Valentini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.bini24@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.larcher25@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Larcher',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirco.stringari26@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirco','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martino.stringari27@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martino','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.gatti28@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Gatti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('lucia.romeo29@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Lucia','Romeo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('andrea.olivieri30@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Andrea','Olivieri',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martina.lanci31@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martina','Lanci',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martino.gatti32@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martino','Gatti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('diego.lombardi33@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Diego','Lombardi',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('ginevra.molinari34@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Ginevra','Molinari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('riccardo.castelli35@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Riccardo','Castelli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('emma.stringari36@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Emma','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('andrea.stringari37@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Andrea','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirco.de angelis38@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirco','De Angelis',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('vincenzo.vitale39@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Vincenzo','Vitale',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('beatrice.bini40@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Beatrice','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('adam.ferrari41@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Adam','Ferrari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.toldo42@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('leonardo.coppola43@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Leonardo','Coppola',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.larcher44@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Larcher',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.ferrari45@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Ferrari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('sara.molinari46@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Sara','Molinari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirko.sartori47@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirko','Sartori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('diego.conte48@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Diego','Conte',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('adam.lombardi49@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Adam','Lombardi',FALSE);




INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Verdura','desc',2);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Carne','desc',4);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Pasta','desc',5);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Dessert','desc',7);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Surgelati','desc',8);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Condimenti','desc',30);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Videogiochi','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Calcio','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Ciclismo','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Camping','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Fitness','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Musica','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Bricolage','desc',35);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Pittura','desc',60);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Attrezzi','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Giardinaggio','desc',20);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Cucito','desc',35);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Telefonia','desc',800);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Fotocamere','desc',1500);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('TV','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Audio','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Smartwatches','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Scarpe','desc',200);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Pantaloni','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Felpe','desc',0);
INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) VALUES ('Magliette','desc',85);
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




INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spaghetti 500g','Gli spaghetti sono il risultato di una combinazione di grani duri eccellenti e trafile disegnate nei minimi dettagli. Hanno un gusto consistente e trattengono al meglio i sughi.',3,1,3.7508066602708343,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne rigate 500g','Una pasta gradevolmente ruvida e porosa, grazie alla trafilatura di bronzo. Particolarmente adatta ad assorbire i condimenti, è estremamente versatile in cucina. Ottima abbinata a sughi di carne, verdure e salse bianche. ',3,1,0.8937014729296111,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fusilli biologici 500g','Tipo di pasta corta originario dell’Italia meridionale, dalla caratteristica forma a spirale, i fusilli si abbinano a diversi tipi di sugo, dai più semplici a quelli più elaborati. Sono diffusi e prodotti in tutta Italia, in certi casi secondo la metodologia tradizionale a mano.',3,2,4.156252595262994,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tagliatelle alluovo 500g','Nelle Tagliatelle alluovo è racchiuso tutto il sapore della migliore tradizione gastronomica emiliana. Una sfoglia a regola darte che unisce semola di grano duro e uova fresche da galline allevate a terra, in soli 2 millimetri di spessore.',3,2,3.487879979778498,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tortelloni ai formaggi','Tortelloni farciti con una varietà di formaggi alto-atesini, dal sapore deciso e dal profumo caratteristico. Ogni tortellone viene farcito con formaggio e spezie (pepe, noci, origano, ...)',3,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gnocchetti alla tirolese','Gli gnocchetti tirolesi sono preparati con spinaci lessati, farina e uova. Sono caratterizzati dalla tipica forma a goccia e si prestano ad essere preparati da soli o con altri sughi e condimenti.',3,5,0.7753825803748549,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chicche di patate','Le chicche di patate sono preparate con pochi e semplici ingredienti: patate fresche cotte a vapore, farina e uova. Ideali per un piatto veloce da preparare e nutriente.',3,1,3.4955040329205564,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paccheri napoletani','I paccheri hanno la forma di maccheroni giganti e sono realizzati con trafila di bronzo e semola di grano duro. La superficie è ampia e rugosa, per mantenere alla perfezione il sugo. La forma a cilindro permette la farcitura interna.',3,1,1.5154350444896503,63);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pizzoccheri della valtellina','La particolarità dei pizzoccheri è la combinazione di ingredienti che ne fanno la pasta. Dal caratteristico colore scuro e con una tessitura grossolana, si esaltano nel condimento tradizionale, una combinazione di pezzi di patate, verza, formaggio Valtellina Casera, burro e salvia.',3,3,1.9706237334059173,43);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corallini 500g','I Corallini hanno l’aspetto essenziale ed elegante di minuscoli tubetti, cortissimi e di forma liscia. Abili nel trattenere il brodo o i passati, che si incanalano nel loro minuscolo spiraglio, rappresentano una raffinata alternativa nella scelta delle pastine.',3,1,1.632679794193137,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne lisce 500g','Un formato davvero speciale sotto il profilo della versatilità. Sono perfette per penne allarrabbiata, o al ragù alla bolognese.',3,3,1.734065900668219,29);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rigatoni 1kg','I rigatoni sono caratterizzati dalla rigatura sulla superficie esterna e dal diametro importante; trattengono perfettamente il condimento su tutta la superficie, esterna ed interna, restituendone ogni sfumatura.',3,2,2.8913559898914443,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucchine verdi','Hanno un sapore gustoso ed intenso: le zucchine verdi scure biologiche sono perfette per essere utilizzate sia da sole che con altri piatti, siano essei a base di verdure o carne. Perfino i loro fiori si usano in cucina con svariate preparazioni.',1,2,2.5928299981369163,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carote Almaverde Bio','Le carote biologiche almaverde bio, oltre ad essere incredibilmente versatili e fresche, fanno bene alla vista e durante la bella stagione sono indicate per aumentare labbronzatura.',1,1,1.5813091208780783,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patate a pasta gialla','La patata a pasta gialla biologica è forse il tubero più consumato nel mondo. Le patate sono originarie dellamerica centrale e meridionale. Importata in Europa dopo la scoperta dellAmerica, nel 500, si è diffusa in Irlanda, in Inghilterra, in Francia e in Italia.',1,4,4.086835399495129,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Finocchio tondo oro','Coltivato nelle fertili terre della Campania, il finocchio oro ha un delizioso sapore dolce e una croccantezza unica. Al palato sprigiona un sapore irresistibile ed è ricco di vitamina A, B e C e se consumato crudo è uneccellente fonte di potassio.',1,2,1.6591534725658474,86);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro datterino pachino','Succoso, dolce e profumato! Il pomodoro datterino è perfetto per dare un tocco gustoso alle insalate, ma anche per realizzare deliziose salse e condimenti. Coltivato sotto il caldo sole di Pachino, a Siracusa, è una vera eccellenza nostrana.',1,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro cuore di bue','Ricco di vitamine, sali minerali, acqua, fibre, il Pomodoro Cuore di Bue viene coltivato in varie zone dItalia. La terra fertile e le condizioni climatiche rendono possibile la coltivazione di un pomodoro dal sapore unico, dolce e succoso.',1,2,0.0636638579981963,11);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cetrioli Almaverde Bio','l cetriolo biologico è un frutto ricco di sostanze nutritive che apportano benefici per chi li assume. Ha proprietà lassative grazie alle sue fibre, favorisce la diuresi per la notevole quantità di acqua presente ed è un buon alleato per la pelle se usato come maschera viso.',1,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carciofo violetto di sicilia','I carciofi sono buoni, utilizzabili per creare molti piatti e possiedono benefici notevoli; la varietà violetta può inoltre conferire un tocco particolare alle ricette di tutti i giorni. Ha un sapore squisito e mantiene le caratteristiche salutari dei carciofi.',1,4,1.6611719608459752,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucca gialla delicata','La zucca Spaghetti o Spaghetti squash è una varietà di zucca unica: la sua polpa è composta di tanti filamenti edibili dalla forma di spaghetti. Con il suo basso contenuto di calorie è ideale per chi vuole tenersi in forma. ',1,9,0.0791474839984696,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cipolla dorata bio','Cipolla dorata biologica con numerosi benefici e proprietà antiossidanti ed antinfiammatorie. Ideale per preparare zuppe, torte salate o insalate, ma anche e soprattutto ottimi soffritti.',1,3,0.15512865598090841,54);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Peperoni rossi bio','I peperoni rossi biologici sono ideali per stuzzicare il palato, preparare gustosi e saporiti sughi da abbinare a pasta, carne o zuppe.',1,2,4.350115116532062,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zampina','E’ una salsiccia di qualità, realizzata con carni miste di bovino (compreso primo taglio). La carne, dopo essere stata disossata, viene macinata insieme al basilico in un tritacarne. Il composto ottenuto è unito al resto degli ingredienti e collocato in un’impastatrice, in modo da ottenere un prodotto uniforme e privo di granuli. Infine viene insaccato nelle budella naturali di ovicaprino.',2,4,4.096298364480312,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Battuta di Fassona','La battuta al coltello di fassona è uno degli antipasti classici della gastronomia tipica piemontese. La carne di bovino della pregiata razza Fassona viene semplicemente battuta cruda al coltello, in modo da sminuzzarla senza macinarla meccanicamente, lasciando la giusta consistenza alla carne. Si condisce con un filo dolio, un pizzico di sale, pepe e volendo qualche goccia di limone. Si può servire con qualche scaglia di Parmigiano Reggiano.',2,4,3.656187276994954,91);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arrosticini di fegato','Originale variante del classico arrosticino di pecora, per chi ama sperimentare combinazioni di sapori insolite e sfiziose. Piccoli bocconcini di freschissimo fegato ovino al 100% italiano, tagliati minuziosamente fino a ottenere porzioni da circa 40 g. Infilati con cura in pratici spiedini di bamboo, ogni singolo cubetto custodisce tutto il gusto intenso e deciso della carne ovina, valorizzato dalla dolcezza e dal carattere della cipolla di Tropea.',2,1,1.9232813713267927,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia di suino fresca','La preparazione della salsiccia di suino fresca inizia disossando il maiale e selezionando i tagli di carne scelti, che vengono poi macinati con una piastra di diametro 4,5mm. Si procede quindi a preparare l’impasto, con l’aggiunta di solo sale e pepe, che viene amalgamato e poi insaccato. La salsiccia viene quindi legata a mano e lasciata ad asciugare. Si presenta di colore rosa con grana medio-fina. Al palato è morbida e saporita, con gusto leggermente sapido.',2,2,1.6668663340970202,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bombette','Gustosa carne di coppa suina, tagliata a fettine sottili e arrotolata a involtino attorno a sfiziosi cubetti di formaggio (sì, proprio quello che durante la cottura diventerà cremoso e filante) e sale. Disponibile anche nella variante impanata, sotto forma di spiedino.',2,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia tipo Bra','La Salsiccia di Bra è una salciccia tipica piemontese, prodotta con carni magre di vitellone, macinata finemente e insaccata in budello naturale. La salsiccia non avendo bisogno di stagionatura, può essere consumata fresca durante tutto lanno. Spesso viene venduta attorcigliata, con la caratteristica forma di spirale. Un grande classico della tradizione culinaria piemontese, spesso viene consumata cotta alla griglia, ma l’ideale è gustarla cruda come antipasto.',2,1,0.43731429578362846,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Hamburger ai carciofi','Il gusto delicato e leggermente amaro dei carciofi conferisce una nota particolare alle pregiate schiacciatine di vitello. La tenera carne, macellata e resa ancora più morbida dall’aggiunta di pane e Grana Padano, si sposa alla perfezione con il gusto del carciofo, che la esalta senza coprirne il sapore.',2,2,1.8922796708073564,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coscia alla trevigiana','Le cosce di maiale sono prima disossate, poi speziate e legate a mano. Si procede quindi alla cottura al forno a bassa temperatura, solo con l’aggiunta di spezie naturali, in modo da conservare tutti gli aromi e la morbidezza delle carni. A cottura ultimata, la coscia al forno viene messa a raffreddare, tagliata a metà.  Il colore della carne è rosato, la consistenza è soda e il gusto intenso e molto saporito.',2,10,2.1361852840357076,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spezzatino disossato','Tenero, magro e saporito: lo spezzatino biologico senza osso dellazienda agricola Querceta non teme rivali in fatto di qualità, gusto e consistenza. Ricavato dalle parti muscolose di bovini allevati liberamente e con alimentazione biologica dallazienda, questo taglio è a dir poco perfetto sia per il brodo che per la cottura in umido, che rende la carne ancora più morbida e gustosa.',2,4,2.327952952495309,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuore di costata','Il cuore di costata di Querceta viene ricavato dai migliori tagli magri di carne bovina, accompagnata da una minima presenza di porzione grassa che, riuscendo a diluire parzialmente il contenuto connettivo, la rende più tenera e saporita.',2,2,2.597190682360977,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bragiolette','Tenere fettine di carne bovina accuratamente selezionata e farcite con saporito formaggio, prezzemolo e una punta di aglio per ravvivare ulteriormente il già ricco sapore.',2,3,3.391430686515257,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini Findus','I Bastoncini sono fatti con 100% filetti di merluzzo da pesca sostenibile e certificata MSC, sfilettati ancora freschi e surgelati a bordo per garantirti la massima qualità. Sono avvolti nel pangrattato, semplice e croccante, per un gusto inimitabile.',5,1,1.0797039464981262,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pisellini primavera','I Pisellini Primavera sono la parte migliore del raccolto perché vengono selezionati solo quelli più piccoli, teneri e dolci rispetto ai Piselli Novelli. Sono così piccoli, teneri e dolci da rendere ogni piatto più buono.',5,1,3.285377155151541,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sofficini','I sofficini godono di un ripieno vibrante e di un gusto mediterraneo, con pomodoro DOP e Mozzarella filante di altissima qualità, in unimpanatura croccante e gustosa.',5,2,3.9260474207471696,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Misto per soffritto','Questo delizioso misto di verdure accuratamente tagliate: carote, sedano e cipolle, è ideale per accompagnare qualsiasi piatto. La preparazione è velocissima.',5,2,0.05054839713742543,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spinaci cubello','In questa porzione di spinaci surgelati, le foglie della pianta sono adagiate delicatamente una sullaltra, per mantenersi più soffici e più integre. Inoltre, dal punto di vista nutrizionale, i cubelli di Spinaci Foglia forniscono una dose di calcio sufficiente a soddisfare il fabbisogno quotidiano.',5,2,2.354662842324272,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fiori di nasello','I Fiori di Nasello, così teneri e carnosi, sono la parte migliore dei filetti. Pescato nelle acque profonde dellOceano Pacifico, viene sfilettato ancora fresco e surgelato entro 3 ore così da preservarne al meglio sapore e consistenza.',5,1,2.2612804202035552,19);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Minestrone tradizionale','Con il minestrone tradizionale, sarà possibile gustare la bontà autentica di ingredienti IGP e DOP, con il gusto unico di verdure al 100% italiane, coltivate in terreni selezionati. Nel minestrone sono presenti patate, carote, cipolle, porri, zucche, spinaci e verze.',5,3,2.9343744642744154,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patatine fritte','Esistono di forma rotonda, ovale o allungata, a pasta bianca o gialla, addirittura viola. Vengono selezionate con attenzione per qualità, dimensione e caratteristiche organolettiche, così da offrire tutto il meglio delle patate offerte dalla terra.',5,2,1.2064493135329168,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cimette di broccoli','Il broccolo è una varietà di cavolo che presenta uninfiorescenza commestibile. La raccolta dei broccoli avviene entro i 4-6 mesi successivi alla semina, poi le cimette sono rapidamente surgelati per preservare le loro proprietà nutrizionali.',5,4,1.660257470492288,106);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polpette finocchietto','Deliziosi tortini di verdure subito pronti da gustare come antipasto, come contorno o come pratico piatto unico completato da uninsalata.',5,3,3.2451393286646715,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Torroncini duri','Un assortimento di torroncini originale e sfizioso, tra cui vale la pena menzionare quelli profumati dalle note agrumate dei bergamotti e dei limoni calabresi, per poi farsi tentare dai gusti più golosi come caffè e nutella.',4,3,4.473490874562071,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cantucci con cioccolato','Dolci toscani per eccellenza, da accompagnare con vini liquorosi come il Vin Santo, i cantucci offrono un ampio margine per sperimentare nuovi sapori. Fin dal primo morso si apprezza il perfetto equilibrio tra il gusto inconfondibile del cioccolato, esaltato da un lieve sentore di arancia, e limpasto tradizionale del cantuccio, per un risultato croccante e goloso.',4,2,0.76653726676019,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Dolcetti alla nocciola','Piccoli e fragranti, con il loro invitante aspetto a forma di rosellina, questi dolcetti alla nocciola sono una specialità dal sapore antico e sempre stuzzicante. Lavorati con nocciole piemontesi Tonda Gentile IGP, i biscottini Michelis sono l’ideale da servire con un buon tè aromatico e delicato. Ottimi anche per la prima colazione.',4,4,2.6827258413337396,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paste di meliga','Tipiche del Piemonte, le paste di Meliga del Monregalese sono dei frollini dalla storia antichissima. La qualità del prodotto è data dallabbinamento di zucchero, uova fresche, burro a chilometro zero e farine locali, per un biscotto semplice e genuino. Fondamentale è il mais Ottofile. La grana grossolana della farina che ne deriva è il segreto di questi biscotti friabili.',4,9,2.546492236571416,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Amaretti di sicilia','L’aspetto ricorda quello di un semplice biscotto secco ma le apparenze, che spesso ingannano, vengono subito smentite quando al primo morso la pasta comincerà a sciogliersi e rivelarsi in tutta la sua dolcezza. Gli Amaretti di Sicilia vengono presentati in eleganti confezioni regalo, una per ogni variante proposta: classica, al pistacchio di Sicilia, alla gianduia delle Langhe e al mandarino di Sicilia.',4,1,0.051063238475778094,48);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Celli pieni','Pochi ingredienti, semplici e genuini: il segreto della bontà dei celli ripieni è questo. Basta un piccolo morso per lasciarsi conquistare dal gusto intenso della scrucchijata, speciale confettura a base di uva di Montepulciano che non solo fa da ripieno, ma è il vero e proprio “cuore” di questo antico dolce della tradizione abruzzese.',4,7,2.0357510655919295,58);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cannoli siciliani','Il cannolo è il dolce siciliano per eccellenza, disponibile in formato mignon e grande. Proveniente dai pascoli del Parco dei Nebrodi e del Parco delle Madonie, la migliore ricotta viene selezionata e lavorata in più fasi per renderla leggera e vellutata, creando un irresistibile contrasto con la granella di pistacchio e la friabile pasta che la ospita.',4,3,2.9576364600064275,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crema gianduia','Senza grassi aggiunti, né aromi, ogni vasetto custodisce tutta l’essenza dei migliori ingredienti italiani, lavorati con cura e valorizzati da una piacevolissima consistenza. Un’ammaliante linea di creme dal gusto intenso e dolce, che coinvolgerà il palato in una sinfonia di sapori.',4,3,0.3521505761611299,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Plum cake','Del classico plum cake resta la morbidezza e la delicatezza, ma per tutto il resto, linterpretazione siciliana si differenzia dallo standard. Uva passa e rum sanno elevare il carattere timido di questo dolce in maniera netta e riuscita. La giusta componente alcolica accende di gusto luva e la frutta secca presente nellimpasto.',4,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pignolata','Probabilmente il dolce più caratteristico di tutta Messina, immancabile a carnevale ma preparato ed apprezzato tutto lanno. Tanti piccoli gnocchetti di impasto realizzato con farina, uova e alcol vengono fritti ed assemblati. La fase finale prevede una glassatura deliziosa: per metà al limone e per la restante metà al cioccolato.',4,25,3.668017915798801,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo Switch','Nintendo Switch, una console casalinga rivoluzionaria che non solo si connette al televisore di casa tramite la base e il cavo HDMI, ma si trasforma anche in un sistema da gioco portatile estraendola dalla base, grazie al suo schermo ad alta definizione.',7,15,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grand Theft Auto V','Il mondo a esplorazione libera più grande, dinamico e vario mai creato, Grand Theft Auto V fonde narrazione e giocabilità in modi sempre innovativi: i giocatori vestiranno di volta in volta i panni dei tre protagonisti, giocando una storia intricatissima in tutti i suoi aspetti.',7,1,4.58445885680357,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Toy story 2','Il conto alla rovescia per questavventura comincia su Playstation 1, nei panni di Buzz Lightyear, Woody e tutti i loro amici. Sarà una corsa contro il tempo per salvare la galassia dal malvagio imperatore Zurg.',7,25,3.807708435888737,92);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ratchet and Clank','Una fantastica avventura con Ratchet, un orfano Lombax solitario ed esuberante ed un Guerrabot difettoso scappato dalla fabbrica del perfido Presidente Drek, intenzionato ad uccidere i Ranger Galattici perché non intralcino i suoi piani. Questo lincipit dellavventura più cult che ci sia su Playstation.',7,1,3.9994111191728665,19);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo snes mini','Replica in miniatura del classico Super Nintendo Entertainment System. Include 21 videogiochi classici, tra cui Super Mario World, The Legend of Zelda, Super Metroid e Final Fantasy III. Sono inclusi 2 controller classici cablati, un cavo HDMI e un cavo di alimentazione.',7,2,0.14022278425706802,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Playstation 3 Slim','PlayStation 3 slim, a distanza di anni dal lancio del primo modello nel 2007, continua ad essere un sofisticato sistema di home entertainment, grazie al lettore incorporato di Blu-ray disc™ (BD) e alle uscite video che consentono il collegamento ad unampia gamma di schermi dai convenzionali televisori, fino ai più recenti schermi piatti in tecnologia full HD (1080i/1080p).',7,12,4.532154306473444,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xbox 360','Xbox 360 garantisce l’accesso al più vasto portafoglio di giochi disponibile ed un’incredibile offerta di intrattenimento, il tutto ad un prezzo conveniente e con un design fresco ed accattivante, senza rinunciare a performance eccellenti.',7,2,3.4302517885525385,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crash Bandicoot trilogy','Crash Bandicoot è tornato! Più forte e pronto a scatenarsi con N. Sane Trilogy game collection. Sarà possibile provare Crash Bandicoot come mai prima d’ora in HD. Ruota, salta, scatta e divertiti atttraverso le sfide e le avventure dei tre giochi da dove tutto è iniziato',7,1,1.8703931005612051,76);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pokemon rosso fuoco','In Pokemon Rosso Fuoco sarà possibile sperimentare le nuove funzionalità wireless di Gameboy Advance, impersonando Rosso, un ragazzino di Biancavilla, nel suo viaggio a Kanto. Il suo sogno? Diventare lallenatore più bravo di tutto il mondo!',7,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('God of War','Tra dei dellOlimpo e storie di vendette e intrighi di famiglia, Kratos vive nella terra delle divinità e dei mostri norreni. Qui dovrà combattere per la sopravvivenza ed insegnare a suo figlio a fare lo stesso e ad evitare di ripetere gli stessi errori fatali del Fantasma di Sparta.',7,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nastro parastinchi','Nastro adesivo in colorazione giallo neon, disponibile anche in altre colorazioni. 3,8cm x 10m. Ideale per legare calzettoni e parastinchi.',8,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Calzettoni Adidas','Calzettoni Adidas disponibili in numerose colorazioni, con polsini e caviglie con angoli elasticizzati a costine. Imbottiture anatomiche che sostengono e proteggono la caviglia.',8,2,0.750489172669434,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglietta Italia','Maglia FIGC, replica originale nazionale italiana. Realizzata con tecnologia Dry Cell Puma, che allontana lumidità dalla pelle per mantenere il corpo asciutto.',8,2,4.230554638534933,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borsone palestra','Borsa Brera / adatto per la scuola - palestra - allenamento - ideale per il tempo libero. Disponibile in diverse colorazioni e adatta a sportivi di qualsiasi tipo. Involucro protettivo incluso.',8,3,0.6635886945512071,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Nike Mercurial','La scarpa da calcio da uomo Nike Mercurial Superfly VI academy CR7 garantisce una perfetta sensazione di palla e con la sua vestibilità comoda e sicura garantisce unaccelerazione ottimale e un rapido cambio di direzione su diverse superfici.',8,3,3.314224946114818,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Porta da giardino','Porta da Calcio in miniatura, adatta a giardini. Realizzata in uPVC 2,4 x1,7 m; Diametro pali : 68mm. Sistema di bloccaggio ad incastro per maggiore flessibilità e stabilità, per essere montata in appena qualche minuto.',8,3,0.5558806108039138,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cinesini','Piccoli coni per allenare lagitlità, il coordinamento e la velocità. Molti campi di impiego nellallenamento per il calcio. Sono ben visibili, grazie ai colori appariscenti e contrastanti. Il materiale è flessibile e resistente.',8,3,1.0275864146442792,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set per arbitri','Carte arbitro da calcio: set di carte arbitro include cartellini rossi e gialli, matita, libro tascabile con carte di scopo punteggio del gioco allinterno e un fischietto allenatore di metallo con un cordino.',8,2,4.375336652911318,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglia personalizzata','La Maglia è nella versione neutra e viene personalizzata con Nome e Numero termoapplicati da personale esperto. Viene realizzata al 100% in poliestere. Non ha lo sponsor tecnico e le scritte sono stampate.',8,3,3.8330258746085013,62);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pallone Mondiali','Pallone ufficiale dei mondiali di calcio Fifa. Il pallone Telstar Mechta, il cui nome deriva dalla parola russa per sogno o ambizione, celebra la partecipazione ai mondiali di calcio FIFA 2018 e la competizione. Questo pallone viene fornito con lo stesso design monopanel del Telstar ufficiale 18. ',8,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zaino da alpinismo','Questa borsa è disponibile in colori attraenti. Ci sono molte tasche con cerniere in questa borsa per diversi oggetti che potrebbero essere necessari per un viaggio allaperto. È imbottito per il massimo comfort. Questa borsa è di 40 e 50/60/80 litri. Tessuto in nylon idrorepellente e antistrappo. Cinghie regolabili e lunghezza del torace.',10,3,1.5820722968689227,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo emergenza','Questo sacco a pelo di emergenza trattiene il 90% del calore corporeo irradiato in modo da preservare il calore vitale in circostanze fredde e difficili. È abbastanza grande da coprirti dalla testa ai piedi. Dai colori vivaci in arancione vivo, questo sacco a pelo può essere immediatamente visto da lontano, rendendolo un rifugio indispensabile in attesa delle squadre di soccorso. Questo articolo ti aiuta a rimanere adeguatamente isolato dallaria fredda in modo da poter dormire comodamente e calorosamente quando vai in campeggio in inverno. È impermeabile e resistente alla neve, quindi puoi indossarlo come impermeabile per proteggerti dalla pioggia e dalla neve. Se necessario, puoi anche stenderlo su un grande prato come tappetino da picnic.',10,16,0.6820264337734794,11);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo','Sacco a pelo lungo di 2 metri per 70 cm di larghezza, ampi, con la possibilità di piegare la borsa quando aperto come una trapunta. Facile da aprire e chiudere con una cerniera che può essere bloccata. La parte superiore è circolare per un maggiore comfort per lutilizzatore. Cerniera di alta qualità e la tasca interna utile per riporre piccoli oggetti. Zipper riduce la perdita di calore. Il tessuto esterno è impermeabile e umidità realizzato con materiali di alta qualità e pieni di fibre offrono comfort e calore. Campo di temperatura tra i 6 ei 21 gradi. Questo sacco a pelo vi terrà al caldo, indipendentemente dal luogo o periodo dellanno.',10,14,4.934389339480388,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo matrimoniale','Questo sacco a pelo di lusso è semplicemente fantastico. Si arrotola e si ripone facilmente in una borsa da trasporto, include una cerniera integrale con due tiretti ed è dotato di cinghie in velcro laterali. Alcuni dei nostri prodotti sono realizzati o rifiniti a mano. Il colore può variare leggermente e possono essere presenti piccole imperfezioni nelle parti metalliche dovute al processo di rifinitura a mano, che crediamo aggiunga carattere e autenticità al prodotto.',10,8,0.34508242692198765,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tenda 4 persone','Comode tasche nella tenda interna per accessori e un porta lampada per una lampada da campeggio o torcia completano il comfort. Tenda ventilata per un sonno indisturbato. L ingresso con zanzariera tiene alla larga le fastidiose zanzare. Le cuciture assicurano una grande resistenza allo strappo e, quindi, alla rottura.',10,10,4.972556196881345,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltello Magnum 8cm','Ottimo accessorio da avere sul campo, per essere pronti a qualsiasi tipo di wood carving o altra necessità. Le dimensioni ne richiedono, tuttavia, lutilizzo previo possesso di porto darmi. Il manico è in colore rosso lucido.',10,2,3.848616487284262,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini trekking','I bastoncini di fibra di carbonio resistente offrono un supporto più forte dei modelli dalluminio; il peso ultra-leggero (195 g/ciascuno) facilita le camminate riducendo la tensione sui polsi.',10,1,4.537633827843192,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lanterna da fronte','Torcia da testa Inova STS Headlamp Charcoal. Corpo in policarbonato nero resistente. Cinghia elastica in tessuto nero. LED bianco e rosso. Caratteristiche interfaccia Swipe-to-Shine che permette un accesso semplice alle molteplici modalita - il tutto con il tocco di un dito.',10,25,3.4514033732107063,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fornelletto a gas','Fornelletto da campo di facilissimo utilizzo: è sufficiente girare la manopola, ricaricare con una bomboletta di butano e sarà subito pronto a scaldare le pietanze che vi vengono poggiate. Ha uno stabile supporto in plastica dura e la potenza del bruciatore è di 1200 watt.',10,7,3.503452906107669,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borraccia con filtro','Rimuove il 99.99% di batteri a base d acqua,, e il 99.99% di iodio a base d acqua, protozoi parassiti senza sostanze chimiche, o batteriche. Ideale per viaggi, backpacking, campeggi e kit demergenza.',10,2,4.363084851391403,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rullo per allenamento','Bloccaggio fast fixing: è possibile agganciare e sganciare la bicicletta con un sola rapida operazione. 5 livelli di resistenza magnetica. Nuovo sistema di supporto regolabile dell’unità che consente un’idonea e costante pressione tra rullino dell’unità e pneumatico',9,1,4.200007944086765,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pedali Shimano','Pedale di tipo click spd, con peso di coppia 380G, con i migliori materiali targati Shimano. Utilizzo previsto: MTB, tuttavia è possibile utilizzarli anche per viaggiare su strada',9,3,3.8498844351317874,48);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Catena 114L Ultegra','Catena bici da corsa 10 velocità. Pesa 118g, argento, 114 maglie. Ideale per qualsiasi tipo di terreno e di utilizzo. Garantita la resistenza fino a 5000km di utilizzo, soddisfatti o rimborsati',9,4,2.8248354076570257,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Freni a pattino','Freni a pattino per cerchioni in alluminio. La confezione contiene 4 pezzi, quindi permettte di sostituire entrambi gli impianti di frenatura: quello anteriore e quello posteriore. Sono lunghi 70mm e universali.',9,4,3.301159164939987,16);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sella da corsa Uomo','Sella da corsa, talmente comoda che è stata progettata utilizzzando gli stessi materiali e blueprint delle selle da trekking o touring. Imbottitura in gel poliuretanico morbido, con un telaio color acciacio molto resistente.',9,3,2.423421994803061,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ruota Maxxis da strada','Ottima gomma per chi oltre allo sterrato fa anche asfalto, da usare sia con camera daria che tubless. La linea centrale di tacchetti offre un buon supporto in asfalto ed evita che la gomma si usuri troppo ai lati. Nello sterrato asciutto nessun problem, ottima tenuta in curva. Per chi ha problemi di forature sulla spalla esiste anche la versione EXO.',9,4,4.461629994925489,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rastrelliera da parete','Rastrellilera verticale, da parete, con supporto fino a cinque biciclette di dimensioni naturali. I ganci sono rivestiti in plastica per una massima protezione dai graffi. I fissaggi non sono inclusi.',9,7,1.141696195460652,97);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Barra per tandem','Consente di collegare qualsiasi bicicletta convenzionali per bambini a biciclette per adulti. Veloce e facile da montare, può essere attaccato senza attrezzi ed essere usato con le biciclette per bambini da 12 a 20 e con un supporto massimo per un peso di 32kg.',9,2,0.7472547098511306,58);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lucchetto antifurto','Lucchetto Onguard Brute a U, x4p quattro Bolt. Intrecciato con bubblok, con un cilindro particolare incluso. I materiali con cui è stato realizzato sono acciaio inossidabile temperato e doppio rivestimento in gomma dura.',9,2,3.5755560490786973,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Casco AeroLite rossonero','Doppio In-Mould costruzione fonde il guscio esterno in policarbonato con Caschi assorbenti del nucleo interno schiuma, dando un casco estremamente leggero e resistente.',9,3,4.07138449663368,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tappetino da yoga','180 x 61 cm tappeto per utilizzi molteplici. Realizzato in Gomma NBR espansa ad alta densità, lo spessore premium da 12 mm ammortizza confortevolmente la colonna vertebrale, fianchi, ginocchia e gomiti su pavimenti duri.',11,1,3.555435607275829,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitness tracker Xiaomi Mi Band 3','Display touch full OLED da 0,78. Durata della batteria fino a 20 giorni (110 mAh). 20 gr di peso. Impermeabile fino a 50 metri (5ATM), Bluetooth 4.2 BLE, compatibile con Android 4.4 / iOS 9.0 o versioni successive.',11,22,0.683413761220073,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corda da saltare','Gritin Corda per Saltare, Regolabile Speed Corda di Salto con la Maniglia di Schiuma di Memoria Molle e Cuscinetti a Sfera - Regolatore di Lunghezza della Corda di Ricambio(Nero)',11,4,4.217589308987641,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ciclette ultrasport cardio','Ultrasport F-Bike Design, Cyclette da Allenamento, Home Trainer, Fitness Bike Pieghevole con Sella in Gel, con Portabevande, Display LCD, Sensori delle Pulsazioni, Capacità di Carico 110kg',11,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fasce elastiche fitness','nsonder Elastiche Fitness Set di 4 Bande Elastiche e Fasce di Resistenza per Fitness Yoga Crossfit',11,14,3.093005292926485,71);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tesmed elettrostimolatore','Tesmed MAX 830, Elettrostimolatore Muscolare Professionale con 20 elettrodi: massima potenza, addominali, potenziamento muscolare, contratture e inestetismi',11,9,4.336964844070175,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fascia dimagrante addominale','Fascia Addominale Dimagrante per Uomo e Donna, Regolabile Cintura Addominale Snellente, Brucia Grassi e Fa Sudare, Sauna Dimagranti Addominali, Di Neoprene (Fascia Addominale Dimagrante di fascia 2)',11,2,2.612942083414811,32);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Palla da pilates','BODYMATE Palla da Ginnastica/Fitness Palla da Yoga per Allenamento Yoga & Pilates Core Compresa Pompa - Resistente Fino a 300kg, Disponibile nelle Dimensioni da 55, 65, 75, 85 cm',11,7,2.5932748092730384,102);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pedana di equilibrio','Emooqi Pedana di Equilibrio in Legno antiscivolo Balance Board per equilibrio e coordinazione Carico massimo circa 150 kg/ dimensione circa 39.5 cm',11,4,3.6659804612657454,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Piccoli manubri','Coppia di piccoli pesi, perfetti per lallenamento casalingo con centinaia di ripetizioni. Bel colore, materiale gradevole al tatto con ottima grippabilita (anche a mani sudate).',11,7,3.5495174132217455,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike React Element 55','Riprendendo le linee di design dai nostri modelli da running leggendari, come Internationalist, la scarpa Nike React Element 55 - Uomo accoglie la storia e la spinge verso il futuro. La schiuma Nike React assicura leggerezza e comfort, mentre i perni in gomma sulla suola e i dettagli rifrangenti offrono un look allavanguardia che vuole una reazione.',23,4,2.7373139181382267,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike Air Max 1','La scarpa Nike Air Max 1 - Uomo aggiorna il leggendario design con nuovi colori e materiali senza rinunciare alla stessa ammortizzazione leggera delloriginale.',23,15,4.743717145518711,91);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Air Jordan 1 Retro High OG','La scarpa Air Jordan 1 Retro High OG sfoggia uno stile ispirato alla tradizione, con materiali premium e ammortizzazione reattiva. Il colore mostrato in foto è Vintage Coral/Sail.',23,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike Benassi JDI SE','Grazie al suo design astratto, la slider Nike Benassi JDI SE Slide è perfetta per dare energia e vivacità al tuo look. Fascetta sintetica, fodera in jersey e intersuola in schiuma per una sensazione di morbidezza e un comfort ideale.',23,2,2.0009357395771463,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Air Jordan 1 Low','Air Jordan 1 Low: struttura premium, morbido comfort. Uno tra i modelli più iconici in assoluto della linea Nike. Uno dei simboli della storia delle scarpe da Basket.',23,3,4.724248353147292,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Adidas Stan Smith','Le classiche sneaker Stan Smith in una nuova versione che ripropone dettagli autentici, come la tomaia in pelle con 3 strisce traforate e finiture brillanti a contrasto. Le chiusure a strappo assicurano praticità e comfort',23,1,1.3087116633600349,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ciabatte Adidas Duramo','Perfette prima e dopo ogni allenamento, le ciabatte adidas Duramo sono un classico sportivo. Con un design monoblocco impeccabile, ad asciugatura rapida, queste semplici ciabatte per la doccia offrono un comfort allinsegna della praticità e prestazioni affidabili.',23,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Gazelle Adidas','Un inno allessenzialità che stupisce da oltre trentanni. Questo remake delle Gazelle rende omaggio al modello del 1991 riproponendo materiali, colori, texture e proporzioni della versione originale. La tomaia in pelle sfoggia 3 strisce a contrasto e un rinforzo sul tallone.',23,3,4.254552052307213,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('All Star Classic High Top','Le Chuck Taylor All Star sono delle sneaker classiche, che resistono allesame del tempo, a prescindere dalla stagione, dal luogo e dal look. In questo tono giallo pacato daranno la possibilità di sembrare pulcini, per quanto poco utile possa essere.',23,3,4.957163585995492,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Converse One Star Corduroy','Le Converse Custom One Star Corduroy Low Top sono un modello moderno, che non rinuncia allo stile classico ed equilibrato. Prende tuttavia uno spunto dal mondo degli skateboarders americani.',23,4,4.804520550702323,59);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Abbey','I Van Orton Design reinterpretano in chiave pop una delle copertine più celebri e citate della storia della musica e rendono omaggio alla band che ha ridefinito il concetto stesso di “pop”.',26,6,3.262373830818144,63);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Gran Tour','Un viaggio spensierato tra arte e design, la leggerezza di una gita fuori porta, una famiglia a cavallo di una vespa. Tutto dipinto in punta di pennello, perché ogni viaggio comincia con l’immaginazione.',26,7,0.30253244108148225,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Pink Floyd','“So, so you think you can tell heaven from hell?”. Questa t-shirt dei gemelli Van Orton Design è indossabile soltanto da chi riconosce la citazione originale, che coglierà anche il motivo della grafica rappresentante una stretta di mano particolarmente calda.',26,4,1.1578276953058708,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Go Fast','Come un pinguino, di pancia, sullo skate. Sì, lo sappiamo: i pinguini scivolano benissimo anche senza skate. Ma, vuoi mettere? Philip Giordano ci ricorda che tutto è possibile.',26,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Coca Cola','Doveva essere la copertina per un libro del filosofo Jean Baudrillard ma poi è diventata una maglietta. Forse non ci crederai, ma Matteo Berton ci ha assicurato che le bare a forma di Coca Cola esistono davvero!',26,13,4.548736966084373,23);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Equilibrio','Questo artwork di Jonathan Calugi nasce da una ricerca sulle connessioni e le percezioni. Un equilibrio di corpi e punti che ci dimostra come l’occhio umano, anche in presenza di elementi incompleti, riesca a ricostruire un’immagine nitida di ciò che sta osservando.',26,5,2.3583161123136898,86);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Serenade','Un vecchio giradischi, un vinile e quella canzone che ti ricorda di quella volta che avete ballato insieme per la prima volta. Il tutto in unincredibile e futurista illustrazione del maestro di graphic design Alessandro Giorgini.',26,1,4.9163269778605,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Colori e luce','Riccardo Guasco riesce a rendere poetico anche un fascio di strisce orizzontali; e regalare un sorriso. L’illustrazione fa parte di un progetto col quale Rik ha voluto reinterpretare a modo suo lo stile asettico della scuola astrattista.',26,4,2.0524635859802864,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Connessioni','Questo lavoro nasce per la serie limitata di carte da gioco Playing Arts. Jonathan ha scelto di illustrare il 2 di fiori con il suo inconfondibile tratto unico rappresentando sovrapposizioni e connessioni che si fondono e si confondono.',26,2,1.1059724022592377,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Pizza true love','“Pizza. T’amo senza sapere come, né quando, né dove. T’amo senza limiti né orgoglio: t’amo così, perché non so amarti altrimenti”. Per Mauro Gatti il vero amore sa di pizza.',26,3,1.8640747059517326,95);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Curved Bill','Il cappellino da jockey Vans Mayfield Curved Bill è un modello con logo Vans ricamato sulla visiera.',27,13,3.8533231602726836,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Vans x Marvel','Vans e Marvel si uniscono per celebrare gli iconici supereroi dellUniverso Marvel in una collezione straordinaria di abbigliamento, calzature e accessori. Il cappellino jockey Vans x Marvel è un modello retrofit regolabile a 6 pannelli con ricamo di Iron Man su tessuto.',27,4,0.218051759535971,43);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Berretto Core Basics','Il berretto Vans Core Basic è uno zuccotto con targhetta con logo Vans, in colorazione Port Royale. Taglia unica. Disponibile in 7 colorazioni diverse, due delle quali colorate a camouflage.',27,4,0.8320096456454562,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cappellino Davis 5','Il cappellino Vans Davis è un modello camper a 5 pannelli con etichetta Vans in ecopelle sul pannello anteriore e cinghia di regolazione sul retro. Disponibile in 4 colorazioni bicolore.',27,4,4.773209733132874,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Vans x Hulk','Vans e Marvel si uniscono per celebrare gli iconici supereroi dellUniverso Marvel in una collezione straordinaria di abbigliamento, calzature e accessori. Il cappellino jockey Vans x Marvel è un modello retrofit regolabile a 6 pannelli con ricamo di Hulk su tessuto.',27,1,0.005458330848632231,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Baseball Disney x Vans','Realizzato per celebrare lo spirito e levoluzione di Topolino, il cappellino da baseball Disney X Vans in 100% cotone è un modello a 5 pannelli con stampa rétro di Topolino serigrafata.',27,4,1.2196587139054849,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Baseball classic patch','Il cappellino da baseball Classic Patch è un modello a 5 pannelli in 80% acrilico e 20% lana con una visiera in 100% cotone e unapplicazione Vans Off The Wall sul pannello anteriore.',27,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Vans Visor Cuff','Il berretto Vans Visor Cuff presenta una stampa mimetica integrale, visiera ed etichetta Vans sul davanti. Pensato per gli skaters che non si vogliono fermare davanti ad un inverno rigido',27,3,3.166272999942792,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cappellino Camper 5','Il cappellino camper Vans Flap a 5 pannelli è realizzato in 100% tela di cotone cerata, presenta copriorecchie trapuntati e unapplicazione Vans in ecopelle a rilievo.',27,17,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Berretto Pom Off The Wall','Il berretto Off The Wall Pom è un modello in 93% acrilico, 6% nylon e 1% elastan con grafica OFF THE WALL in jacquard e pompon.',27,2,4.067085747176366,19);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chino Elasticizzati','I pantaloni chino in twill Sturdy Stretch sfoggiano unintramontabile combinazione tra stile classico e praticità necessaria per lo skateboard',24,3,4.778919196449211,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chino Authentic','Un modello realizzato per mantenere a lungo la forma e lelasticità, con tasche anteriori allamericana, tasche posteriori a filo con chiusura a bottone, unetichetta del brand intessuta e una comoda vestibilità slim leggermente affusolata.',24,2,4.528907809976236,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Cross Town','I pantaloni sportivi Vans Cross Town presentano nastri su entrambi i lati con il logo Off The Wall, un cordino regolabile con motivo a scacchi in vita e una tasca posteriore con letichetta Vans. Il modello è alto 1,86 m e indossa una taglia 32.',24,4,1.1333948617718848,48);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jean Vintage Blute Taper','Pensati per offrire comodità e resistenza nel tempo, i Vans V46 Taper sono jeans a vita media in denim con finitura grezza. Questo modello presenta 5 tasche, una patta con cerniera, una mostrina in vera pelle al livello della vita e una vestibilità affusolata che si restringe alla caviglia.',24,2,4.121464528004516,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jeans Inversion','Dalla vestibilità ampia, i jeans Vans Inversion sono un modello straight con striscia laterale stile smoking, due tasche laterali e due posteriori.',24,2,0.0695376848616458,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Summit','La collezione Design Assembly unisce un design innovativo a un tocco urbano per creare uno stile ricco di dettagli. I pantaloni Vans Summit sono un modello a vita alta corto alla caviglia, con tasche laterali e posteriori, passanti per cintura ed etichetta Vans sul retro.',24,1,2.6228870653455703,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Checkboard Authentic','La collezione Design Assembly unisce un design innovativo a un tocco urbano per creare uno stile ricco di dettagli. Comodi, caldi e oversize come labbigliamento maschile ma con un tocco di femminilità, i pantaloni a gamba larga Design Assembly Checkerboard presentano tasche allamericana e vita medio alta.',24,23,4.494654672287105,54);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Framework Salopette','La salopette Vans Framework è un modello carpenter con cuciture a punto triplo e diverse tasche, tra cui due oblique, una frontale sul petto e tre posteriori. Decorata da bottoni in metallo con logo.',24,1,0.2445400620648519,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jeans Skinny 9','I Vans Skinny 9 sono dei jeans skinny a vita alta con tagli sulle ginocchia, due tasche frontali e due posteriori.',24,2,2.5373311710104884,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloncini Tremain','Modello cargo dalla vestibilità comoda, i pantaloncini Tremain sono realizzati in 100% cotone dobby tinto in filo. Colorazione beige e con camouflage militare.',24,1,0.6190901393564696,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Girocollo Retro Tall','La felpa girocollo Vans Retro Tall Type è un modello a maniche lunghe con logo Vans sulla parte sinistra del petto e sul retro.',25,6,0.35594948142780747,82);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Versa Quarter Zip','Progettata da designer esperti e con collo a lupetto, la felpa Versa Quarter offre il massimo delle prestazioni senza rinunciare allo stile. Realizzata con maestria per resistere alle condizioni atmosferiche e allusura causata dallo skateboard',25,4,3.334493250538552,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa con cappuccio versa','La felpa in pile di qualità è dotata di una tasca a marsupio sul davanti, fodera del cappuccio con stampa a contrasto, maniche con motivo checkerboard serigrafato e un ricamo sul petto.',25,15,4.01993103898707,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa cappuccio cross town','La felpa Vans Cross Town è un modello a maniche lunghe con tasca frontale a marsupio e cappuccio dotato di cordino con motivo a scacchi. Presenta il logo Vans sul davanti e la grafica Off The Wall sulle cuciture.',25,1,4.874435587748181,43);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa classic con cappuccio','La felpa Vans Classic è un modello a maniche lunghe con cappuccio, zip, tasche frontali e logo Vans sul petto.',25,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa con cappuccio skate','La felpa con cappuccio Vans Skate è realizzata in pile e presenta una tasca a marsupio frontale e il logo Vans sulla parte sinistra del petto.',25,9,1.8892422887944815,104);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Tall Box Stripe','La felpa con cappuccio Tall Box Stripe è realizzata in 60% cotone e 40% poliestere e presenta una tasca a marsupio sul davanti, righe tinte in filo e ricamo del logo sul petto.',25,14,0.4992235023043945,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Distort','La felpa Vans Distort presenta una tasca a marsupio sul davanti, maniche lunghe, tramezzi laterali a coste e loghi Vans serigrafati su busto, cappuccio e fondo della manica.',25,1,1.0170696350078134,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Square Root','La felpa Vans Square Root è un modello con cappuccio, maniche lunghe e una tasca a marsupio sul davanti. È inoltre decorata con il logo Vans sulla parte sinistra del petto e dettaglio checkerboard lungo la manica sinistra.',25,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Classic Crew','La felpa Vans Classic è un modello a girocollo con logo Vans stampato sul petto. Disponibile in varie colorazioni, tutte in colori brillanti e stampe di altissima qualità.',25,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('GoPro hero7','Riprese incredibilmente stabili. Capacità di acquisizione intelligente. Robusta e impermeabile senza bisogno di custodia. Tutto questo è HERO7 Black: la GoPro più avanzata di sempre.',19,4,2.401065818171424,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sony DSC-RX100','Sony DSC-RX100 fotocamera digitale compatta, Cyber-shot, sensore CMOS Exmor R da 1 e 20.2 MP, obiettivo Zeiss Vario-Sonnar T, con zoom ottico 3.6x e nero.',19,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nikon D3500','Nikon D3500: fotografa, riprendi video, condividi, divertiti, stupisci. La nuova reflex digitale entry level da 24,2 Megapixel è la fotocamera perfetta per chi si avvicina al mondo della fotografia, in virtù del suo design confortevole e delle sue modalità di ripresa che ne rendono facilissimo luso.',19,12,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sony Alpha 7K','Con i suoi 24,3 megapixel, il sensore Exmor full-frame 35 mm della α7 offre prestazioni che non temono quelle delle migliori reflex digitali. Inoltre, grazie al processore Bionz X e alla messa a fuoco automatica ottima di Sony, lα7 offre un livello di dettaglio, sensibilità e qualità eccellente. Sei pronto per uno shooting fotografico da urlo.',19,1,2.759266055302948,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nikon Coolpix W100','La W100 è progettata per resistere agli urti da unaltezza massima di 1,8 m, impermeabile fino a 10 m, resistente al freddo fino a -10°C e alla polvere.',19,4,1.0841848417927424,50);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polaroid Snap','Dai ritratti ai selfie, questa potente fotocamera da 10 MP cattura ogni dettaglio e stampa in un istante, senza bisogno di pellicole o toner. Aggiungi una scheda microSD per salvare le tue foto e stamparle successivamente.',19,1,0.47892781303546683,91);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samoleus Fotocamera Giocattolo','La mini macchina fotografica digitale ha uno schermo di 1,5 pollici. È adatto per migliorare i bambini linteresse di scattare foto, sviluppare il loro cervello e farli amare le attività allaria aperta. Può anche essere usato come regalo perfetto per i bambini.',19,3,0.38909522937449204,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fujifilm X-A5','Fujifilm X-A5 Silver Fotocamera Digitale da 24 Mp e Obiettivo Fujinon XC15-45mm f3.5-5.6 OIS PZ, Sensore CMOS APS-C, Ottiche Intercambiabili, Argento/Nero',19,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Canon EOS M6','Allinterno del corpo compatto di EOS M6 troverai un ampio sensore CMOS da 24,2 megapixel che produce risultati eccellenti anche in condizioni di scarsa luminosità o ad alto contrasto',19,2,2.8475688529771412,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Olympus OM-1','Una delle migliori fotocamere a pellicola che siano storicamente esistite. Grazie allimpugnatura in cuoio nero e il corpo in acciaio riesce sempre ad essere un grande strumento fotografico, ma allo stesso tempo un grande oggetto di design',19,19,1.4002258992666528,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Apple iPhone XS','Phone X è uno smartphone diverso da tutti gli altri iPhone che abbiamo visto finora e lo splendido schermo OLED è solo uno dei fattori che contribuiscono a fargli ottenere punteggi elevatissimi.',18,4,3.771570516108177,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung S9','Samsung Galaxy S9 è uno degli smartphone Android più avanzati e completi che ci siano in circolazione. Dispone di un grande display da 5.8 pollici e di una risoluzione da 2960x1440 pixel che è fra le più elevate attualmente in circolazione.',18,1,3.504923363043062,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('OnePlus 6T','OnePlus 6T è veloce e fluido grazie al processore Qualcomm Snapdragon 847. OnePlus 6T ha un display 19.5:9 Optic AMOLED che regala un’esperienza immersiva. Uno dei migliori smartphone Android in circolazione.',18,21,0.8539849581986048,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nokia 3310','Uno dei telefoni storicamente più importanti della storia delluomo. Si narra che la leggenda della spada nella roccia sia nata da qui, così come lestinzione dei dinosauri sulla Terra.',18,3,0.8837793783431591,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Topcom Sologic T101','Questo telefono analogico con filo è molto facile da usare. Adatto a persone con problemi di vista grazie ai tasti di grandi dimensioni.',18,20,2.1176588072288283,16);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Google Pixel 3XL',' Questo smartphone è l’incarnazione di ciò che Google ritiene debba offrire uno smartphone: prestazioni avanzate del comparto fotografico, display ampio e di buona qualità, supporto nativo a tutte le feature dell’assistente virtuale e aggiornamenti costanti del sistema operativo. ',18,4,3.6930326793654675,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG G6','Questo smartphone è la rivoluzione in casa coreana, con design unibody, schermo inedito e addio alla modularità. Il risultato è un prodotto solido e capace di tenere testa a qualunque altra ammiraglia.',18,4,3.3727245794413196,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei P10 lite','Huawei P10 Lite è l’atto finale di una trilogia e l’inizio della seconda vita di Huawei. Dopo P8 e P9, il lancio del P10 segna un capitolo fondamentale per questa serie di smartphones, portando una serie di innovazioni dal punto di vista dello schermo, della fotocamera e della batteria.',18,3,2.691594132712508,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Panasonic Telefono Cordless','Panasonic KX-TG1611 offre funzioni come: la rubrica da 50 voci (nome e numero), la memoria di riselezione (fino a 10 numeri), la suoneria portatile selezionabile, la sveglia e lorologio, la risposta con qualsiasi tasto, e altro ancora',18,8,0.6694676535396571,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Motorola RAZR V3','Simbolo dei millennials, questo precursore degli smartphone, caratterizzato dalla forma a guscio tagliente, rimarrà sempre una pietra miliare nella telefonia e nella storia di Motorola.',18,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundLink Mini Bluetooth II','Il diffusore SoundLink Mini Bluetooth II offre un suono pieno, naturale e con bassi profondi che non ti aspetteresti da un dispositivo così piccolo. Inoltre, è dotato di microfono integrato per rispondere alle chiamate e facilita la connessione in wireless ovunque e in qualsiasi momento.',21,1,0.6871429691918396,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Wave SoundTouch IV','Il Wave music system SoundTouch® appartiene a unintera famiglia di prodotti wireless, da sistemi all-in-one a configurazioni home cinema. I sistemi interagiscono per riprodurre la stessa musica ovunque o musica diversa in stanze diverse. Con SoundTouch®, ascoltare e scoprire nuova musica è più semplice che mai.',21,1,3.1093710734128335,104);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundTouch 10','Ciascun diffusore SoundTouch 10 offre un suono ricco e profondo e consente di accedere in wireless alla tua musica preferita. Per cui puoi riprodurre musica diversa in due stanze differenti, o la stessa musica in entrambe le stanze. Inoltre, non potrebbe essere più facile da usare. Per riprodurre la tua musica in streaming, installa lapp gratuita SoundTouch sul tuo dispositivo.',21,4,0.9456362060836165,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Soundbar Bose 300','La soundbar SoundTouch 300 offre prestazioni, ampiezza sonora e bassi migliori rispetto a qualsiasi altra soundbar all-in-one di pari dimensioni. Le innovative tecnologie contenute in questa soundbar ti consentono di ottenere il meglio da tutto quello che guardi e ascolti. Driver personalizzati, tecnologie QuietPort e PhaseGuide. ',21,2,4.084345241247153,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('QuietComfort 20 Noise Canc','Le cuffie QuietComfort 20 Acoustic Noise Cancelling offrono un suono straordinario, ovunque tu sia. Attiva la funzione di riduzione del rumore per concentrarti sullascolto della tua musica e annullare il mondo circostante.',21,2,0.363487362971715,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuffie QuietComfort 35','Cuffie QuietComfort 35 II wireless: il meglio di Bose. Vantano una tecnologia di riduzione del rumore di prima qualità e accesso diretto ad Amazon Alexa e Google Assistant per un semplice controllo vocale ovunque. La tua musica. La tua voce. Controllo totale.',21,4,1.5907620713309967,63);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Multimedia Companion',' Il sistema Companion® 50 crea un ambiente acustico di grande impatto, degno di un sistema composto da cinque diffusori. Invece, grazie a Bose®, sono sufficienti due eleganti diffusori da scrivania e un modulo Acoustimass® occultabile.',21,4,4.656675834925398,102);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundLink Micro Bluetooth',' Il SoundLink Micro è un diffusore compatto ma potente, estremamente robusto e impermeabile. Inoltre, è dotato di un cinturino in silicone resistente agli strappi, per portarlo sempre con te ovunque. ',21,2,1.9869468015885428,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Home Speaker 500','Allinterno del Bose Home Speaker 500, due driver personalizzati puntano in direzioni opposte per far rimbalzare il suono dalle pareti. Il risultato? Un fronte sonoro più ampio di qualsiasi altro diffusore smart, così potente da riempire qualsiasi ambiente con un suono stereo straordinario.',21,16,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Bass Module 700','Bose Soundbar 700, è il miglior modulo bassi wireless che abbiamo mai ideato per i nostri sistemi home cinema. Infatti, offre le migliori prestazioni possibili con un subwoofer di queste dimensioni. Si connette in wireless alla soundbar e aggiunge ancora più profondità e impatto a tutti i contenuti, dagli effetti speciali dei film dazione alle playlist che risuonano in tutta la casa.',21,2,3.961398184449345,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG oled tv e8','Il TV LG OLED E8 porta il TV a un livello superiore grazie all’eccezionale qualità delle immagini e al design innovativo che si fondono armoniosamente. L’eleganza del vetro sposa la ricercatezza senza pari della tecnologia OLED per riprodurre immagini straordinarie che sembrano aprire la porta a nuovi mondi.',20,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG signature tv oled','TV LG SIGNATURE OLED W rispecchia l’essenza autentica del TV. Il design minimalista, il processore intelligente α9 e AI TV di LG completano la tua esperienza di visione.',20,4,3.469645937379723,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung QLED tv 8k','Il TV Samsung QLED 8K Q900R offre un realismo dalla profondità quasi infinita, con dettagli così definiti che ti sembrerà di poterli toccare, come se stessi vivendo ogni scena in prima persona. Questa risoluzione super-elevata è una novità assoluta per la qualità dell’immagine.',20,3,4.257589061759362,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung The Frame','Più di un semplice TV, The Frame è stato progettato per rendere ogni momento in casa qualcosa di magico. In più, questo televisore vanta una qualità dell’immagine eccellente, poiché si tratta di un incredibile 4K UHD. Scopri di più, ricopri la tua parete di arte ed eleganza.',20,2,3.257390486610591,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('TV LCD portatile zoshing','1.9 pollici TV widescreen portatile, Risoluzione: 800 x 480, Rapporto: 16: 9. Attraverso lantenna, ingresso USB, lettore di schede TF, ingresso AV e altre opzioni per fornire immagini chiare. Controllo remoto completo.',20,2,2.407890462837549,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Philips 55 Smart TV UHD 4K','Smart TV LED 4K ultra sottile con Ambilight su 3 lati e Pixel Plus Ultra HD Versione Ambilight: 3 lati Funzioni Ambilight: Ambilight+Hue integrato Ambilight Music Modalità gioco Modalità Lounge.',20,23,3.68253037323117,30);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung MU 6125','I TV UHD Samsung offrono un’esperienza visiva di qualità, con prestazioni Smart immediate e veloci, grazie a: risoluzione 4 volte superiore ai TV FHD, design Slim, da ogni lato, esperienza Smart powered by Tizen.',20,1,3.2680024730689494,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('HISense Tv Led','HISENSE H43AE6000 4K Ultra HD con tecnologia HDR e tecnologia Precision Colour, nuova piattaforma SMART VIDAA U e il sistema audio Crystal Clear. La tecnologia HDR estende la gamma di luci e colori migliorando così nettamente la qualità delle immagini, per neri profondi e bianchi brillanti e intensi anche in condizioni di forte contrasto. Potrai così finalmente vedere ogni immagine in ogni minimo dettaglio.',20,2,1.25923350418097,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grundig mod p45','Televisore tubo catodico da camera con doppia antenna ricezione originale e uscite scrd e tv. Modello top di gamma Grundig.',20,3,2.524397338437907,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Philips 6500 series','Smart TV LED ultra sottile 4K. Philips 6500 series Smart TV LED UHD 4K ultra sottile 43PUS6503/12, 109,2 cm (43\), 3840 x 2160 Pixel, LED, Smart TV, Wi-Fi, Nero',20,4,2.0240710453561164,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Razer Nabu Wear','Razer Nabu Watch, un orologio digitale smart che integra alcune funzioni smart, come monitor dell’attività fisica e notifiche via Bluetooth, grazie ad una batteria dedicata con quelle di un normale orologio digitale.',22,3,3.249010786660306,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Apple Watch Series 4','Ti presentiamo Apple Watch Series 4. Ridisegnato dentro e fuori per aiutarti a fare più movimento, tenere docchio la tua salute e restare in contatto con chi vuoi. Ora anche con connettività cellulare.',22,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung Gear S3 Frontier','Display touch 1.3” (360 x 360 pixel) AOD. Certificazione IP68. Memoria 4 GB. Processore Dual Core. Connettività: LTE, bluetooth 4.2, Wi-Fi b/g/n, NFC, MST, GPS/Glonass. Batteria 380 mAh. Sensori: accelerometro, giroscopio, barometro, cardiofrequenzimetro, luce ambiente',22,25,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei Band 2 Pro','HUAWEI Band 2 Pro. Modulo GPS indipendente. Monitora in tempo reale distanza e ritmo. Monitoraggio battito cardiaco.',22,1,3.9295547215638593,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xiaomi MI Band 2','Xiaomi Mi Band 2 è un dispositivo consigliato se volete un sistema spiccio per ricevere le notifiche e per tenere un conto sommario dei passi durante la giornata, della distanza percorsa sul tapis roulant della palestra, delle ore di riposo notturno.',22,1,4.649048704149852,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitbit Versa','Fitbit Versa, lo smartwatch che ti aiuta a conoscerti meglio per vivere una vita più sana. Raggiungi i tuoi obiettivi di forma e benessere con questo smartwatch leggero e resistente allacqua sempre al tuo polso per motivarti. Allenati con gli esercizi su schermo e semplifica la tua giornata con le notifiche, le risposte rapide, le app, la tua musica e unautonomia di oltre 4 giorni.',22,3,3.9162113663475417,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitbit Charge','Monitora il tuo battito cardiaco continuamente dal polso per allenarti meglio, tenere sotto controllo le calorie bruciate e avere un quadro più completo della tua salute, tutto senza una scomoda fascia toracica.',22,4,1.7071888092883647,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ticwatch E Shadow','TicWatch E Shadow Smartwatch con display OLED da 1,4 pollici, Android Wear 2.0, Orologio sportivo Alta qualità Compatibile con Android e iOS Adatto per la maggior parte dei tipi di smartphone',22,3,4.899129564786535,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei Watch 2','Lorologio ha un grado di protezione IP68, il che significa che non garantisce la protezione dallimmersione in altri liquidi oltre allacqua limpida, ad es. birra, caffè, acqua salata e soda, acqua della piscina o acqua delloceano.',22,1,2.3183139438631217,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung Gear Sport','Gear Sport è lo Sports Watch per tutti, da chi è a livello principiante a quello avanzato, per condurre uno stile di vita attivo e sviluppare sane abitudini alimentari. ',22,4,0.21868899620617555,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tappi di sughero','Sugheri naturali non trattati derivanti dalla corteccia della quercia da sughero portoghese. Tutti i tappi di sughero hanno una sua venatura, non sono stati né sbiancati né schiariti in modo da dare risalto al look naturale del prodotto creativo',13,3,3.469793195022024,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Manuale fai da te','Dai lavori in muratura allidraulica, dallelettricità alla falegnameria, dal bricolage in giardino alla manutenzione dellautomobile, tutto quello che bisogna sapere per eseguire alla perfezione, e in tutta sicurezza, gli interventi più diversi. ',13,3,1.723694224949276,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pistola per colla a caldo','Blusmart ugello della pistola di colla un anello termoisolante plastica, mezzi a grilletto costruito avendo il controllo termico intelligente. Sicurezza spegne e il LED indicatori di stato, richiamo efficace che lo stato di carica e lugello può essere meglio sostituito nelle condizioni.',13,2,4.890278663135314,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Feltro in fogli','Tronisky Feltro in Fogli, 40 Colori Feltro e Pannolenci Feltro Acrilico DIY Tessuto per Cucire Mestieri Stoffa di Cucito Bricolage Tessuto Patchwork 20*30cm',13,4,0.6708554779105103,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit strisce bricolage','Kit Composto Da 960 Strisce Di Carta Da 3/5 mm Kit Di Bricolage Artigianale Per Quilling Arte Per Filigrana Fai Da Té, Tavola, Stampo, Crimper e Pettine, Paper Width: 3mm',13,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set bricolage Mega','Rayher 69082000 Kit per lavoretti creativi, set bricolage, diversi materiali, Multicolore, 1200 pz. deale per creazioni con feltro, carta, piume, pompon, legno e tanto altro. Il set è completo per ogni appassionato di fai da te. Sono da acquistare a parte solo le forbici apposite.',13,13,2.0292012409555413,106);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pom Pom Maker','Questo kit di creazione di pompom ha 4 formati per varie esigenze di progetto e di dimensioni nella progettazione e nella realizzazione di palline di lanugine.',13,15,3.7178155274494937,26);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cubetti legno 100pz','Materiale: Legno. Dimensione: ca. 2,5 x 2,5 x 2,5 cm / 1 x 1 x 1 pollici (L * W * H). 100pz di cubi in legno bianco per bricolage DIY e progetti artistici',13,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Winomo Fette Legno 10pz','Colore di legno. Materiale: legno di palissandro. Diametro: circa 7-9 cm. spessore: circa 1cm. Con lucidatura fine su entrambi i lati. Questi dischi di legno naturali sono circondati con corteccia.',13,6,4.632713712815116,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Accessori craft per bambini','Craft Planet - Confezione di accessori per arti creative per bambini. Sacchetto di prodotti per lavori artigianali e artistici. Pratico e in plastica.',13,9,0.7341058922297994,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spatola da giardino','Worth Garden Cazzuola è fatta per semplificare notevolmente il lavoro di giardinaggio. È ideale per scavare nel terreno più duro e rompere le zolle di terra indurite. ',16,3,3.2982083111421057,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spruzzatore inniaffatore','Qualità, robustezza, funzionalità. Comoda anche la capacità di 2 lt (vasi di fiori su balcone)',16,3,2.564926158418064,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tubo flessibile a spruzzo','Tubo flessibile verde da 30 m, ideale per irrigare il giardino, lavare l’auto, pulire i mobili da giardino e svolgere altri lavoretti all’aria aperta.',16,17,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Guanti antitaglio','I nostri guanti anti taglio non solo sono perfetti per luso in cucina, ma vanno bene anche per attività come la manipolazione o lavorazione di vetro, ferro e acciaio, per la meccanica, la meccatronica e molte altre. Questi guanti proteggeranno le tue mani da molti pericoli sul lavoro!',16,2,4.166562809401855,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grembiule da giardino','Grembiule di durevole attrezzo di giardino verde oliva e kaki con tasche multifunzione, tra cui uno per il tuo cellulare. Dimensioni 48 x 58 cm',16,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltivatore AeroGarden','Lorto tutto lanno; coltiva erbe aromatiche fresche, verdure, insalate, fiori e altro nel tuo orto da interni intelligente',16,11,1.0533145045900139,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacchi per rifiuti 3pz','Materiale: robusto e resistente tessuto in polipropilene (PP) Spessore 150g/m² *** Idrorepellente, delicato per la pelle, non inquinano la falda freatica.',16,15,3.4272802925913526,45);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Inceneritore da giardino','Dimensioni: 44 cm di lunghezza, 44 cm di larghezza e 64 cm di altezza. Si monta con facilità e senza bisogno di utensili.',16,3,3.6797227249847877,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit ortaggi insoliti','Tutto loccorrente in una confezione per coltivare 5 ortaggi stravaganti. Carote viola, cavoletto di Bruxelles rosso, pomodori striati, zucchine gialle e bietola a coste multicolore',16,2,1.4516293443942618,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cesoie Potatura Giardinaggio','GRÜNTEK Cesoie Potatura Giardinaggio GRIZZLY a Incudine 470mm Troncarami a cricchetto. Due in uno: cesoie per il giardino e per potatura',16,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tavolozza per artisti','Autentica tavolozza fatta a mano di alta qualità artigianale in compensato impiallacciato stagionato, per mescolare olio o acrilico. Progettata per essere tenuta sul avambraccio con il pollice nel foro, le dita si appoggiano nella cavità che arriva fino al foro per il pollice e allestremità che curva intorno al gomito.',14,2,2.109735097783455,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set accessori dipinto','Royal & Langnickel - Set di accessori per dipingere con cavalletto, perfetto per gli artisti appassionati e gli studenti, adatto dai principianti ai professionisti e ideale per viaggiare',14,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit pittura cavalletto','Un kit per artisti professionisti e hobbisti. Include 1 cavalletto, 1 tela da 20x30cm, 12 colori acrilici da 12ml, 2 pennelli, 2 spatole e 1 tavolozza',14,3,4.919915614795319,35);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cavalletto in piedi','Malaga è il cavalletto per pittura da campagna telescopico e salvaspazio: 80 x 96 x 180 cm',14,2,1.9591350501706217,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arteza tubetti di colore','Confezione da 24 pezzi in tubetti singoli, organizzati in una pratica scatola che ti aiuterà a tenerli sempre in ordine e facilmente accessibili quando ne hai bisogno. Creati per lutilizzo su tela, ottengono ottimi risultati anche su superfici diverse come il legno',14,3,2.808050825427597,71);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set colori acrilici','Set convenzienza di colori acrilici 120ml. Kit da 10 tubetti di colore acrilico serie Crylic di Artina - colori brillanti e alta densità di pigmenti colore per un risultato professisonale - per uso artistico',14,3,3.5119403689503836,54);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set di pennelli assortiti','Set assortito di  – appositamente studiato per la massima versatilità e facilità d’uso, questo set di pennelli è perfetto per i colori acrilici, ma può essere usato anche per gli acquerelli e i colori a olio.',14,2,0.8764865709842917,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Manuale di pittura','Un manifesto e un manuale insostituibile e da sfogliare, leggere, studiare ogni giorno per migliorare nel mondo della pittura e della colorazione.',14,6,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spatoline e raschietti','Set di cinque spatole per tavolozze con pittura ad olio. Materiale: spatole in acciaio INOX con manico in legno.',14,3,0.7412433576471322,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gesso acrilico 1L','Appretto bianco per la preparazione di supporti per dipingere. viscosità e concentrazione di bianco di titanio lo rendono particolarmente coprente. applicare su superfici pulite e non grasse. essicca rapidamente e presenta una superficie leggermente mat, che migliora lancoraggio degli strati di pittura acrilica e a olio.',14,4,1.9896518193456325,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cacciavite Torx a punta quadrata','Wiha Classic cacciavite si può usare al giorno in unampia gamma di applicazioni.È universale, antimacchia e ha una superficie e un manico facile da pulire',15,20,4.063501942312248,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set di cacciaviti ad angolo','DOTAZIONE: T5 | T6 | T7 | T8 | T9 | T10 | T15 | T20 | T25 | T27 | T30 | T40 | T50. TORX - loriginale. Il marchio TORX è sinonimo di qualità e servizio clienti come lo specialista interno per chiave ad esagono incassato e viti',15,5,2.6977560334746142,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('RevolutionAIR Compressore','Portatile e leggero. Adatto per gonfiare e per operazioni di soffiaggio. Ideale per soffiare, pulire, gonfiare, dipingere',15,2,2.3110744471230102,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pinze regolabili per tubi e dadi','WORKPRO Pinze Regolabili resistenti e durevoli con gli esami di tempo e pratica, lunghezza da 250mm e 200mm con l’apertura pratica massimo al 70mm e 60mm assicurando la presa solida e il serraggio forte',15,21,2.655047876929678,26);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chiavi a cricchetto','La valigetta del set da 130 pezzi di chiavi a bussola del marchio Brüder Mannesmann Werkzeuge è il partner ideale per molteplici lavori di avvitamento su macchina, moto, bicicletta e per ogni ambito della casa.',15,4,0.368310683397608,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Martello demolitore','Il martello tassellatore TH-RH 1600 è l’assistente degli appassionati di fai-da-te per lavori di foratura, apertura di fori e smantellamento. Con quattro funzioni: tassellatura, foratura e scalpellatura con e senza fissaggio dello scalpello',15,1,2.9544227711566173,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Avvitatore elettrico tacklife','acklife SDH13DC Cacciavite elettrico Senza Fili, un design ergonomico, leggero e pratico, conveniente da trasportare.',15,3,4.429305896115868,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Smerigliatrice angolare','Carcassa motore con dimensioni ridotte, circonferenza di soli 180mm. Coppia conica ottenuta per fresatura dal pieno. Motore con resistenza al calore maggiorata e di alte prestazioni',15,20,2.299640686019905,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sega a batteria','Bosch Microsega NanoBlade EasyCut 12 tagliare non è mai stato così semplice. Un compatto e maneggevole utensile a batteria per eseguire tagli con facilità e senza vibrazioni, dentro e fuori casa',15,14,0.2638134205619769,58);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pinza spelafili','Ideale per spellare filo da 10-24 AWG (0,2-6mm2). Con una manopola girevole micro-regolabile in rame, puoi regolare il tappo per tagliare la lunghezza desiderata del filo centrale. Inoltre, lo spelafili non danneggia i singoli fili',15,3,3.6517023515724034,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cerniere invisibili per cucito','18cm per nascondere cerniere in nylon trasparente per il cucito. Il colore del prodotto è casuale e cambia da confezione a confezione.',17,2,3.5940079769012057,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Macchina per cucire elettrica','Macchina da cucire robusta, compatta e portatile ideale per professionisti. L’innovativo display LCD permette di visualizzare la velocità standard del punto selezionato',17,3,0.9103209822483815,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set 10 filati in poliestere','Cuciture perfette: con questo set da 10 tipi di filo nei colori bianco, nero, beige, blu, marrone, arancione, giallo, grigio, verde e rosso, otterrete risultati ottimali, sia cucendo a mano che con la macchina da cucire',17,2,4.115297329856515,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Forbici sarto e cucito','Forbici per sartoria, tagliatutto: per cucito e lavoro. In acciaio temperato, con lama nichelata - Ultra resistenti. Lunghezza totale 20cm',17,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scatola da cucito','Portagioie, kit da cucito, bottoni... 36 x 22 x 17,5 cm (36 x 22 x 27 con manico). Dispone di 5 scomparti separati: 4 in alto e 1 più grande nella parte inferiore.',17,1,0.6756741994492022,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gesso da sarto','Matita meccanica in plastica. 6 gessetti francesi da 3,8mm per disegnare su tessuto. 22cm e colori assortiti, 1 Confezioni',17,3,0.9177844879693153,76);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Manuale di sartoria','Manuale di satoria per principianti di edizioe Il Castello. Tratta di cucito, ricamo, tessitoria e tantissime altre cose interessanti, che insegneranno a diventare esperti nel mondo della moda e del cucito.',17,4,3.3577237827974695,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit cucito da casa','Il pacchetto include: 12 x filo da cucito, 16 x, 4 x bottoni, ditale, metro a nastro, spille di sicurezza, forbici, ago, filo Cutter, perla e infila. Materiali di alta qualità: Kit perfetto per Expert fogne o principianti',17,1,2.204599076978014,87);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Infilago elettrico','Un ottimo strumento per aiutare a filo più facilmente la macchina da cucire ago. Adatto per cucire a mano o a macchina.Uno strumento utile per il vecchio che ha paziente facendo cucire.',17,4,3.044917110202139,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Aghi 6pz per perline','Cruna dellago misura: questo insieme di aghi occhio ha 3 lunghezze, 4,5 cm/ 1,8 pollici, 5,5 cm/ 2,2 pollici e da 7,6 cm/ 3 pollici, lunghezze differenti possono soddisfare le diverse esigenze',17,3,0,0);




INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 1','desc',1,9);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 2','desc',1,22);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 3','desc',1,12);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 4','desc',1,22);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 5','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 6','desc',1,20);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 7','desc',1,29);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 8','desc',1,20);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 9','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 10','desc',1,23);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 11','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 12','desc',1,15);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 13','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 14','desc',1,11);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 15','desc',1,30);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 16','desc',1,10);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 17','desc',1,19);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 18','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 19','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 20','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 21','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 22','desc',1,21);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 23','desc',1,27);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 24','desc',1,13);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 25','desc',1,27);




INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,53,1,1,'2019-01-31 16:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,51,4,3,'2019-01-31 19:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,5,18,0,'2019-02-01 06:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,39,7,7,'2019-01-31 17:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,40,15,15,'2019-01-31 15:27:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,10,5,0,'2019-01-31 19:15:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,24,9,0,'2019-02-01 04:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,5,1,0,'2019-01-31 16:19:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,19,17,14,'2019-02-01 06:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,54,19,19,'2019-01-31 22:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,39,13,7,'2019-02-01 00:24:13');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,29,7,7,'2019-02-01 02:31:25');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,41,16,2,'2019-02-01 09:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,53,1,1,'2019-02-01 07:22:46');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,38,17,17,'2019-02-01 03:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,19,8,0,'2019-01-31 19:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,30,16,16,'2019-01-31 19:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,32,15,15,'2019-02-01 06:28:32');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,11,12,12,'2019-01-31 18:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,36,9,9,'2019-02-01 05:06:56');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,54,10,10,'2019-01-31 16:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,45,12,0,'2019-02-01 09:15:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,53,5,0,'2019-01-31 20:24:13');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,50,9,7,'2019-02-01 08:19:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,25,10,2,'2019-01-31 19:22:46');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,1,10,0,'2019-02-01 05:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,37,6,0,'2019-02-01 08:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,16,14,14,'2019-01-31 20:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,20,4,1,'2019-01-31 22:31:25');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,48,6,0,'2019-01-31 17:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,13,8,8,'2019-02-01 05:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,52,10,0,'2019-02-01 07:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,10,8,8,'2019-01-31 19:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,3,14,0,'2019-01-31 23:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,13,6,1,'2019-02-01 07:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,19,3,3,'2019-01-31 23:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,44,17,17,'2019-02-01 09:12:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,7,8,0,'2019-02-01 06:06:56');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,15,4,1,'2019-01-31 17:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,8,2,0,'2019-01-31 20:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,43,1,1,'2019-01-31 18:24:13');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,22,7,0,'2019-01-31 19:17:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,25,12,0,'2019-01-31 21:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,18,2,0,'2019-02-01 00:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,3,3,3,'2019-02-01 03:12:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,32,16,16,'2019-02-01 00:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,41,20,20,'2019-01-31 18:28:32');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,44,17,0,'2019-01-31 21:05:30');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,46,17,0,'2019-02-01 03:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,43,13,11,'2019-02-01 06:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,47,19,0,'2019-02-01 07:14:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,15,2,0,'2019-02-01 04:28:32');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,44,8,8,'2019-01-31 15:22:46');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,45,19,0,'2019-01-31 17:15:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,17,1,1,'2019-01-31 18:27:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,1,9,0,'2019-02-01 01:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,9,15,0,'2019-02-01 05:31:25');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,50,19,19,'2019-01-31 23:14:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,43,5,5,'2019-01-31 18:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,48,2,1,'2019-01-31 23:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,26,17,17,'2019-02-01 07:24:13');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,36,20,20,'2019-01-31 15:14:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,31,17,17,'2019-01-31 22:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,51,5,0,'2019-02-01 01:05:30');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,8,8,2,'2019-02-01 04:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,40,5,5,'2019-02-01 06:28:32');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,44,19,7,'2019-02-01 06:12:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,44,5,3,'2019-02-01 02:28:32');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,31,12,12,'2019-02-01 01:24:13');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,30,14,14,'2019-01-31 23:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,11,17,10,'2019-01-31 16:12:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,42,19,0,'2019-01-31 18:05:30');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,40,5,0,'2019-02-01 02:31:25');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,46,13,13,'2019-02-01 02:06:56');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,20,3,0,'2019-01-31 21:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,12,1,0,'2019-02-01 07:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,39,7,7,'2019-02-01 07:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,51,19,19,'2019-02-01 09:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,10,15,15,'2019-02-01 02:17:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,7,12,10,'2019-01-31 15:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,52,17,0,'2019-02-01 06:06:56');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,10,20,14,'2019-02-01 10:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,26,17,0,'2019-02-01 10:27:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,18,11,11,'2019-02-01 10:14:08');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,44,15,15,'2019-01-31 15:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,5,11,0,'2019-01-31 15:15:34');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,27,18,0,'2019-02-01 09:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,7,20,0,'2019-02-01 01:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,32,12,12,'2019-01-31 23:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,3,5,3,'2019-01-31 20:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,23,19,6,'2019-02-01 00:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,27,20,0,'2019-01-31 19:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,4,2,2,'2019-01-31 22:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,7,20,20,'2019-01-31 22:22:46');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,17,14,14,'2019-01-31 18:28:32');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,36,12,8,'2019-02-01 06:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,9,17,17,'2019-02-01 04:12:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,45,6,6,'2019-01-31 15:05:30');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,47,11,8,'2019-02-01 03:17:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,13,4,0,'2019-02-01 06:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,5,10,8,'2019-02-01 04:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,9,11,11,'2019-02-01 08:17:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,8,6,0,'2019-02-01 06:06:56');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,15,13,10,'2019-02-01 01:09:49');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,27,12,5,'2019-01-31 15:29:58');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,2,4,2,'2019-02-01 10:27:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,21,14,14,'2019-02-01 10:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,24,13,0,'2019-01-31 23:17:01');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,50,14,0,'2019-02-01 05:08:22');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,25,9,0,'2019-01-31 20:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,12,15,15,'2019-02-01 00:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,16,16,4,'2019-02-01 10:24:13');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,45,10,0,'2019-01-31 18:18:27');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,8,1,0,'2019-02-01 04:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,49,3,3,'2019-02-01 01:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,2,8,8,'2019-01-31 23:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,52,13,10,'2019-02-01 02:04:03');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,40,9,9,'2019-01-31 23:27:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,1,5,0,'2019-01-31 15:27:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,14,3,0,'2019-01-31 23:11:15');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,21,6,4,'2019-02-01 07:05:30');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,22,11,0,'2019-02-01 06:19:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,44,6,2,'2019-01-31 22:05:30');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,33,6,0,'2019-01-31 19:21:20');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,14,14,14,'2019-01-31 20:25:39');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,52,13,0,'2019-02-01 07:22:46');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,29,17,0,'2019-01-31 18:27:06');




INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,7,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,25,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,15,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,8,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,29,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,26,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,23,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,16,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,24,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,7,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,29,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,17,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,7,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (10,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,23,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,26,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,12,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,15,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (15,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,22,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (16,29,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,28,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,15,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,28,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,9,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,21,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,16,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,24,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,28,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,15,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,18,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,29,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,28,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,21,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,10,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,9,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,17,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,21,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,22,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,5,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,16,0);




INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,12,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 22:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,12,'Non me lo ricordavo!','2019-01-31 15:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,25,'Un po di pasta...','2019-01-31 16:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,9,'Ragazzi la festa è domani!!  😀 😁 😂','2019-01-31 23:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,12,'Non vedo lora arrivi la grigliata','2019-02-01 04:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,12,'Ragazzi la festa è domani!!  😀 😁 😂','2019-01-31 21:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,7,'Vorrei comprare 😀 😁 😂 anche un martello demolitore','2019-01-31 10:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,9,'Sono intollerante al lattosio, cè altro?','2019-02-01 04:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,7,'Spero tu abbia 😀 😁 😂 a mente cosa ci serve','2019-01-31 06:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,12,'Non dovrebbe servirci altro 😀 😁 😂','2019-01-31 16:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,14,'Ne abbiamo abbastanza?','2019-01-31 07:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,22,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 13:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,14,'Solo cose 😀 😁 😂 biologiche','2019-01-31 08:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,22,'Naturalmente 😀 😁 😂','2019-01-31 21:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,29,'😀 😁 😂','2019-01-31 09:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,26,'Ragazzi la festa è domani!!  😀 😁 😂','2019-01-31 09:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,29,'Non ricordo esattamente la lista','2019-02-01 02:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,27,'Grazie per avermelo ricordato','2019-02-01 05:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,27,'Hai 😀 😁 😂 bisogno di altro?','2019-01-31 12:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,17,'No','2019-02-01 04:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,22,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 10:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,22,'No','2019-02-01 01:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,22,'Decisamente! 😀 😁 😂','2019-01-31 12:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,17,'Ci serve qualcosa per il pranzo al sacco','2019-02-01 01:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,17,'Decisamente! 😀 😁 😂','2019-01-31 21:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Speriamo basti tutto questo','2019-01-31 17:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Cosa ci serve?','2019-02-01 03:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Non cè bisogno daltro','2019-01-31 14:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Non ricordo esattamente la lista','2019-01-31 12:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Ci serve qualcosa per il pranzo al sacco','2019-02-01 00:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Hai 😀 😁 😂 bisogno di altro?','2019-01-31 17:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,21,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 20:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,19,'Cosa ci serve?','2019-01-31 18:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,19,'Non dovrebbe servirci altro 😀 😁 😂','2019-01-31 15:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,19,'Non cè bisogno daltro','2019-01-31 12:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,27,'Naturalmente 😀 😁 😂','2019-01-31 12:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,19,'Ragazzi la festa è domani!!  😀 😁 😂','2019-02-01 00:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,19,'😀 😁 😂 Domani facciamo il picnic, quindi cosa prendiamo?','2019-02-01 01:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,16,'Grazie per avermelo ricordato','2019-02-01 03:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Non me lo ricordavo!','2019-01-31 14:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,24,'Cè bisogno di altro?','2019-01-31 21:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,27,'Non me lo ricordavo!','2019-01-31 18:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,20,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 14:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'😀 😁 😂 Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 11:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,20,'Sono intollerante al lattosio, cè altro?','2019-01-31 09:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'😀 😁 😂 Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 21:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,20,'Hai 😀 😁 😂 bisogno di altro?','2019-01-31 07:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,20,'Cè bisogno di altro?','2019-02-01 00:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 11:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Sto andando a fare la spesa, manca qualcosa?','2019-01-31 18:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Non saprei...','2019-02-01 02:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,6,'Hai 😀 😁 😂 bisogno di altro?','2019-02-01 03:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,29,'Prendine il doppio','2019-01-31 06:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Prendine il doppio','2019-01-31 19:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,13,'Non me lo ricordavo!','2019-01-31 17:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,23,'Non cè bisogno daltro','2019-01-31 12:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,13,'Cosa ci serve?','2019-01-31 13:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,7,'Non ricordo esattamente la lista','2019-01-31 22:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,13,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 22:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Non lavevo considerato, in effetti','2019-01-31 17:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 18:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Solo cose 😀 😁 😂 biologiche','2019-01-31 16:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Anche qualche 😀 😁 😂 mela magari','2019-01-31 12:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Naturalmente 😀 😁 😂','2019-01-31 07:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Non penso ci serva altro','2019-01-31 07:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Cosa ci serve?','2019-01-31 08:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Spero tu abbia 😀 😁 😂 a mente cosa ci serve','2019-01-31 22:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Hai 😀 😁 😂 bisogno di altro?','2019-01-31 23:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Sì','2019-01-31 13:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Cè bisogno di altro?','2019-02-01 02:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,15,'Decisamente! 😀 😁 😂','2019-02-01 04:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,21,'Sono intollerante al lattosio, cè altro?','2019-02-01 02:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,21,'Devo pensare anche alle intolleranze','2019-01-31 09:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,12,'Ragazzi la festa è domani!!  😀 😁 😂','2019-01-31 22:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,15,'Cosa ci serve?','2019-01-31 17:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,5,'Non me lo ricordavo!','2019-01-31 22:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,5,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 15:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,15,'Non me lo ricordavo!','2019-01-31 10:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Non lavevo considerato, in effetti','2019-01-31 21:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Ci serve qualcosa per il pranzo al sacco','2019-02-01 03:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,5,'Solo cose 😀 😁 😂 biologiche','2019-02-01 00:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,20,'Non cè bisogno daltro','2019-02-01 05:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,21,'Naturalmente 😀 😁 😂','2019-02-01 03:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,5,'Prendiamo anche un po di cose per il bricolage?','2019-02-01 02:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Hai 😀 😁 😂 bisogno di altro?','2019-02-01 03:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Un po di pasta...','2019-02-01 05:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Prendine il doppio','2019-02-01 00:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Sono intollerante al lattosio, cè altro?','2019-01-31 20:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-02-01 03:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Sì','2019-01-31 23:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Sì','2019-01-31 10:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,11,'Non dovrebbe servirci altro 😀 😁 😂','2019-01-31 18:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,30,'Sono intollerante al lattosio, cè altro?','2019-02-01 05:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,17,'Decisamente! 😀 😁 😂','2019-01-31 14:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,13,'Naturalmente 😀 😁 😂','2019-01-31 23:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'Grazie per avermelo ricordato','2019-02-01 00:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,9,'Naturalmente 😀 😁 😂','2019-02-01 05:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,22,'Non penso ci serva altro','2019-01-31 08:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,9,'Cosa ci serve?','2019-02-01 01:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,28,'My names Jeff 😀 😁 😂 😀 😁 😂','2019-02-01 04:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,27,'Non saprei...','2019-01-31 14:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,18,'Grazie per avermelo ricordato','2019-01-31 13:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,28,'Ne abbiamo abbastanza?','2019-01-31 12:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,16,'Non lavevo considerato, in effetti','2019-01-31 09:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,16,'Non penso ci serva altro','2019-01-31 12:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,15,'Sono intollerante al lattosio, cè altro?','2019-02-01 00:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,5,'Cè bisogno di altro?','2019-02-01 01:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,16,'Non cè bisogno daltro','2019-01-31 13:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,12,'Non penso ci serva altro','2019-02-01 05:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,12,'Non saprei...','2019-01-31 11:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,5,'Cosa ci serve?','2019-01-31 09:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'😀 😁 😂 Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 21:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'Non cè bisogno daltro','2019-01-31 11:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,5,'Non penso ci serva altro','2019-01-31 07:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'😀 😁 😂','2019-01-31 14:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,11,'Hai 😀 😁 😂 bisogno di altro?','2019-01-31 20:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,22,'Prendine il doppio','2019-01-31 12:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,29,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 17:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,29,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 23:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,5,'Un po di pasta...','2019-01-31 13:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,29,'Non ricordo esattamente la lista','2019-01-31 20:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,29,'😀 😁 😂','2019-01-31 21:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,29,'😀 😁 😂 Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 12:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,29,'Ne abbiamo abbastanza?','2019-01-31 22:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,29,'Sto andando a fare la spesa, manca qualcosa?','2019-02-01 04:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,29,'Vorrei comprare 😀 😁 😂 anche un martello demolitore','2019-01-31 07:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,27,'Hai 😀 😁 😂 bisogno di altro?','2019-02-01 05:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,29,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 20:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,21,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 16:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,29,'Anche qualche 😀 😁 😂 mela magari','2019-01-31 19:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,29,'No','2019-01-31 23:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,13,'Non penso ci serva altro','2019-01-31 19:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,27,'Non penso ci serva altro','2019-01-31 13:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,29,'😀 😁 😂','2019-01-31 19:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,27,'Spero tu abbia 😀 😁 😂 a mente cosa ci serve','2019-01-31 15:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,27,'Non cè bisogno daltro','2019-02-01 01:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,14,'Speriamo basti tutto questo','2019-01-31 13:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,14,'Non cè bisogno daltro','2019-01-31 21:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,14,'Speriamo basti tutto questo','2019-01-31 21:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,27,'Hai 😀 😁 😂 bisogno di altro?','2019-02-01 05:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,29,'Non dovrebbe servirci altro 😀 😁 😂','2019-01-31 08:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,9,'Non lavevo considerato, in effetti','2019-01-31 12:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,11,'Sono intollerante al lattosio, cè altro?','2019-01-31 11:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,11,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 16:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,9,'Non ho voglia 😀 😁 😂 di cioccolato, tu?','2019-01-31 16:28:30');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,9,'Sto andando a fare la spesa, manca qualcosa?','2019-01-31 06:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,9,'Non penso ci serva altro','2019-02-01 03:29:56');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,5,'Devo pensare anche alle intolleranze','2019-01-31 14:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,20,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 21:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,5,'No','2019-01-31 16:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,20,'Sto andando a fare la spesa, manca qualcosa?','2019-01-31 21:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,5,'Solo cose 😀 😁 😂 biologiche','2019-01-31 21:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,18,'Non cè bisogno daltro','2019-01-31 18:31:23');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,22,'Prendine il doppio','2019-02-01 01:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,22,'Un po di pasta...','2019-01-31 20:27:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,22,'Grazie per avermelo ricordato','2019-01-31 13:32:49');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,16,'Grazie per avermelo ricordato','2019-02-01 02:28:30');




INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,13,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,13,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,27,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,11,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,14,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,20,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,11,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,26,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,20,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(6,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,6,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,22,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,11,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,8,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,18,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,10,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,16,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,13,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,11,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,7,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,4,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,27,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,27,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,13,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,25,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,4,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,20,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,4,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,8,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,19,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,11,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,13,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,21,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,23,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,6,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,21,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,20,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,25,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,8,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,24,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(23,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,6,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,4,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,27,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,22,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,26,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,12,2);




