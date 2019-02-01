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
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.poli4@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Poli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('dora.galli5@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Dora','Galli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('francesco.toldo6@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Francesco','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martino.santoro7@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martino','Santoro',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('andrea.castelli8@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Andrea','Castelli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('greta.gatti9@aol.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Greta','Gatti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('greta.molinari10@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Greta','Molinari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizio.amadori11@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizio','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('alessandro.lanci12@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Alessandro','Lanci',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('sara.larcher13@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Sara','Larcher',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.santoro14@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Santoro',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirco.marchetti15@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirco','Marchetti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirko.chiocchetti16@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirko','Chiocchetti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirco.russo17@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirco','Russo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martina.gatti18@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martina','Gatti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('sofia.santoro19@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Sofia','Santoro',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.galli20@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Galli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('leonardo.marchetti21@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Leonardo','Marchetti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('adam.toldo22@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Adam','Toldo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('alessandro.ferrari23@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Alessandro','Ferrari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('francesco.mazza24@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Francesco','Mazza',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('aurora.romeo25@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Aurora','Romeo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gabriele.conte26@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gabriele','Conte',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('sara.cattaneo27@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Sara','Cattaneo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('erika.coppola28@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Erika','Coppola',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('greta.de silva29@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Greta','De Silva',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('fabrizio.coppola30@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Fabrizio','Coppola',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('sofia.valente31@dnet.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Sofia','Valente',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.gatti32@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Gatti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('mirco.cattaneo33@liberomail.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Mirco','Cattaneo',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('tommaso.serra34@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Tommaso','Serra',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('riccardo.amadori35@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Riccardo','Amadori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('sofia.crotti36@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Sofia','Crotti',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martino.parisi37@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martino','Parisi',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('gabriele.galli38@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Gabriele','Galli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('francesco.valentini39@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Francesco','Valentini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('leonardo.morelli40@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Leonardo','Morelli',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('francesco.de silva41@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Francesco','De Silva',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('lucia.stringari42@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Lucia','Stringari',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('giovanni.bini43@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Giovanni','Bini',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('riccardo.conte44@cloudflare.net','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Riccardo','Conte',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('martino.vitale45@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Martino','Vitale',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('salvatore.lombardi46@yahoo.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Salvatore','Lombardi',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('remo.sartori47@vevomusic.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Remo','Sartori',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('salvatore.aldi48@outlook.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Salvatore','Aldi',FALSE);
INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) VALUES ('matteo.poli49@gmail.com','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','Matteo','Poli',FALSE);




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




INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spaghetti 500g','Gli spaghetti sono il risultato di una combinazione di grani duri eccellenti e trafile disegnate nei minimi dettagli. Hanno un gusto consistente e trattengono al meglio i sughi.',3,3,3.1418413538258783,20);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne rigate 500g','Una pasta gradevolmente ruvida e porosa, grazie alla trafilatura di bronzo. Particolarmente adatta ad assorbire i condimenti, è estremamente versatile in cucina. Ottima abbinata a sughi di carne, verdure e salse bianche. ',3,2,3.1976098549762,59);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fusilli biologici 500g','Tipo di pasta corta originario dell’Italia meridionale, dalla caratteristica forma a spirale, i fusilli si abbinano a diversi tipi di sugo, dai più semplici a quelli più elaborati. Sono diffusi e prodotti in tutta Italia, in certi casi secondo la metodologia tradizionale a mano.',3,1,1.4542048656261974,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tagliatelle alluovo 500g','Nelle Tagliatelle alluovo è racchiuso tutto il sapore della migliore tradizione gastronomica emiliana. Una sfoglia a regola darte che unisce semola di grano duro e uova fresche da galline allevate a terra, in soli 2 millimetri di spessore.',3,3,2.4644010886337098,70);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tortelloni ai formaggi','Tortelloni farciti con una varietà di formaggi alto-atesini, dal sapore deciso e dal profumo caratteristico. Ogni tortellone viene farcito con formaggio e spezie (pepe, noci, origano, ...)',3,3,3.6834711789345853,68);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gnocchetti alla tirolese','Gli gnocchetti tirolesi sono preparati con spinaci lessati, farina e uova. Sono caratterizzati dalla tipica forma a goccia e si prestano ad essere preparati da soli o con altri sughi e condimenti.',3,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chicche di patate','Le chicche di patate sono preparate con pochi e semplici ingredienti: patate fresche cotte a vapore, farina e uova. Ideali per un piatto veloce da preparare e nutriente.',3,2,3.4529897459899015,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paccheri napoletani','I paccheri hanno la forma di maccheroni giganti e sono realizzati con trafila di bronzo e semola di grano duro. La superficie è ampia e rugosa, per mantenere alla perfezione il sugo. La forma a cilindro permette la farcitura interna.',3,22,4.0632646404654995,34);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pizzoccheri della valtellina','La particolarità dei pizzoccheri è la combinazione di ingredienti che ne fanno la pasta. Dal caratteristico colore scuro e con una tessitura grossolana, si esaltano nel condimento tradizionale, una combinazione di pezzi di patate, verza, formaggio Valtellina Casera, burro e salvia.',3,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corallini 500g','I Corallini hanno l’aspetto essenziale ed elegante di minuscoli tubetti, cortissimi e di forma liscia. Abili nel trattenere il brodo o i passati, che si incanalano nel loro minuscolo spiraglio, rappresentano una raffinata alternativa nella scelta delle pastine.',3,2,0.10780527272504337,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Penne lisce 500g','Un formato davvero speciale sotto il profilo della versatilità. Sono perfette per penne allarrabbiata, o al ragù alla bolognese.',3,1,1.4734652108244994,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rigatoni 1kg','I rigatoni sono caratterizzati dalla rigatura sulla superficie esterna e dal diametro importante; trattengono perfettamente il condimento su tutta la superficie, esterna ed interna, restituendone ogni sfumatura.',3,9,1.9074312380704739,42);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucchine verdi','Hanno un sapore gustoso ed intenso: le zucchine verdi scure biologiche sono perfette per essere utilizzate sia da sole che con altri piatti, siano essei a base di verdure o carne. Perfino i loro fiori si usano in cucina con svariate preparazioni.',1,2,2.329696630068512,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carote Almaverde Bio','Le carote biologiche almaverde bio, oltre ad essere incredibilmente versatili e fresche, fanno bene alla vista e durante la bella stagione sono indicate per aumentare labbronzatura.',1,3,3.7227107635730827,10);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patate a pasta gialla','La patata a pasta gialla biologica è forse il tubero più consumato nel mondo. Le patate sono originarie dellamerica centrale e meridionale. Importata in Europa dopo la scoperta dellAmerica, nel 500, si è diffusa in Irlanda, in Inghilterra, in Francia e in Italia.',1,1,0.5313924381320145,97);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Finocchio tondo oro','Coltivato nelle fertili terre della Campania, il finocchio oro ha un delizioso sapore dolce e una croccantezza unica. Al palato sprigiona un sapore irresistibile ed è ricco di vitamina A, B e C e se consumato crudo è uneccellente fonte di potassio.',1,1,3.771756284906227,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro datterino pachino','Succoso, dolce e profumato! Il pomodoro datterino è perfetto per dare un tocco gustoso alle insalate, ma anche per realizzare deliziose salse e condimenti. Coltivato sotto il caldo sole di Pachino, a Siracusa, è una vera eccellenza nostrana.',1,4,4.230612596871419,51);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pomodoro cuore di bue','Ricco di vitamine, sali minerali, acqua, fibre, il Pomodoro Cuore di Bue viene coltivato in varie zone dItalia. La terra fertile e le condizioni climatiche rendono possibile la coltivazione di un pomodoro dal sapore unico, dolce e succoso.',1,4,2.8698228458102637,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cetrioli Almaverde Bio','l cetriolo biologico è un frutto ricco di sostanze nutritive che apportano benefici per chi li assume. Ha proprietà lassative grazie alle sue fibre, favorisce la diuresi per la notevole quantità di acqua presente ed è un buon alleato per la pelle se usato come maschera viso.',1,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Carciofo violetto di sicilia','I carciofi sono buoni, utilizzabili per creare molti piatti e possiedono benefici notevoli; la varietà violetta può inoltre conferire un tocco particolare alle ricette di tutti i giorni. Ha un sapore squisito e mantiene le caratteristiche salutari dei carciofi.',1,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zucca gialla delicata','La zucca Spaghetti o Spaghetti squash è una varietà di zucca unica: la sua polpa è composta di tanti filamenti edibili dalla forma di spaghetti. Con il suo basso contenuto di calorie è ideale per chi vuole tenersi in forma. ',1,4,2.71949817595032,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cipolla dorata bio','Cipolla dorata biologica con numerosi benefici e proprietà antiossidanti ed antinfiammatorie. Ideale per preparare zuppe, torte salate o insalate, ma anche e soprattutto ottimi soffritti.',1,3,1.6656171227421745,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Peperoni rossi bio','I peperoni rossi biologici sono ideali per stuzzicare il palato, preparare gustosi e saporiti sughi da abbinare a pasta, carne o zuppe.',1,4,0.7445176220747662,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zampina','E’ una salsiccia di qualità, realizzata con carni miste di bovino (compreso primo taglio). La carne, dopo essere stata disossata, viene macinata insieme al basilico in un tritacarne. Il composto ottenuto è unito al resto degli ingredienti e collocato in un’impastatrice, in modo da ottenere un prodotto uniforme e privo di granuli. Infine viene insaccato nelle budella naturali di ovicaprino.',2,2,3.980654875421037,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Battuta di Fassona','La battuta al coltello di fassona è uno degli antipasti classici della gastronomia tipica piemontese. La carne di bovino della pregiata razza Fassona viene semplicemente battuta cruda al coltello, in modo da sminuzzarla senza macinarla meccanicamente, lasciando la giusta consistenza alla carne. Si condisce con un filo dolio, un pizzico di sale, pepe e volendo qualche goccia di limone. Si può servire con qualche scaglia di Parmigiano Reggiano.',2,4,2.6622994991072635,49);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arrosticini di fegato','Originale variante del classico arrosticino di pecora, per chi ama sperimentare combinazioni di sapori insolite e sfiziose. Piccoli bocconcini di freschissimo fegato ovino al 100% italiano, tagliati minuziosamente fino a ottenere porzioni da circa 40 g. Infilati con cura in pratici spiedini di bamboo, ogni singolo cubetto custodisce tutto il gusto intenso e deciso della carne ovina, valorizzato dalla dolcezza e dal carattere della cipolla di Tropea.',2,2,4.5995988798246845,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia di suino fresca','La preparazione della salsiccia di suino fresca inizia disossando il maiale e selezionando i tagli di carne scelti, che vengono poi macinati con una piastra di diametro 4,5mm. Si procede quindi a preparare l’impasto, con l’aggiunta di solo sale e pepe, che viene amalgamato e poi insaccato. La salsiccia viene quindi legata a mano e lasciata ad asciugare. Si presenta di colore rosa con grana medio-fina. Al palato è morbida e saporita, con gusto leggermente sapido.',2,4,3.1251485616553265,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bombette','Gustosa carne di coppa suina, tagliata a fettine sottili e arrotolata a involtino attorno a sfiziosi cubetti di formaggio (sì, proprio quello che durante la cottura diventerà cremoso e filante) e sale. Disponibile anche nella variante impanata, sotto forma di spiedino.',2,1,1.9059672198437927,71);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Salsiccia tipo Bra','La Salsiccia di Bra è una salciccia tipica piemontese, prodotta con carni magre di vitellone, macinata finemente e insaccata in budello naturale. La salsiccia non avendo bisogno di stagionatura, può essere consumata fresca durante tutto lanno. Spesso viene venduta attorcigliata, con la caratteristica forma di spirale. Un grande classico della tradizione culinaria piemontese, spesso viene consumata cotta alla griglia, ma l’ideale è gustarla cruda come antipasto.',2,14,1.2577987688918002,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Hamburger ai carciofi','Il gusto delicato e leggermente amaro dei carciofi conferisce una nota particolare alle pregiate schiacciatine di vitello. La tenera carne, macellata e resa ancora più morbida dall’aggiunta di pane e Grana Padano, si sposa alla perfezione con il gusto del carciofo, che la esalta senza coprirne il sapore.',2,3,4.57255828017027,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coscia alla trevigiana','Le cosce di maiale sono prima disossate, poi speziate e legate a mano. Si procede quindi alla cottura al forno a bassa temperatura, solo con l’aggiunta di spezie naturali, in modo da conservare tutti gli aromi e la morbidezza delle carni. A cottura ultimata, la coscia al forno viene messa a raffreddare, tagliata a metà.  Il colore della carne è rosato, la consistenza è soda e il gusto intenso e molto saporito.',2,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spezzatino disossato','Tenero, magro e saporito: lo spezzatino biologico senza osso dellazienda agricola Querceta non teme rivali in fatto di qualità, gusto e consistenza. Ricavato dalle parti muscolose di bovini allevati liberamente e con alimentazione biologica dallazienda, questo taglio è a dir poco perfetto sia per il brodo che per la cottura in umido, che rende la carne ancora più morbida e gustosa.',2,4,4.271141522023897,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuore di costata','Il cuore di costata di Querceta viene ricavato dai migliori tagli magri di carne bovina, accompagnata da una minima presenza di porzione grassa che, riuscendo a diluire parzialmente il contenuto connettivo, la rende più tenera e saporita.',2,2,0.19064467677786912,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bragiolette','Tenere fettine di carne bovina accuratamente selezionata e farcite con saporito formaggio, prezzemolo e una punta di aglio per ravvivare ulteriormente il già ricco sapore.',2,11,1.0373202316568175,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini Findus','I Bastoncini sono fatti con 100% filetti di merluzzo da pesca sostenibile e certificata MSC, sfilettati ancora freschi e surgelati a bordo per garantirti la massima qualità. Sono avvolti nel pangrattato, semplice e croccante, per un gusto inimitabile.',5,9,2.6499322557484337,27);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pisellini primavera','I Pisellini Primavera sono la parte migliore del raccolto perché vengono selezionati solo quelli più piccoli, teneri e dolci rispetto ai Piselli Novelli. Sono così piccoli, teneri e dolci da rendere ogni piatto più buono.',5,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sofficini','I sofficini godono di un ripieno vibrante e di un gusto mediterraneo, con pomodoro DOP e Mozzarella filante di altissima qualità, in unimpanatura croccante e gustosa.',5,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Misto per soffritto','Questo delizioso misto di verdure accuratamente tagliate: carote, sedano e cipolle, è ideale per accompagnare qualsiasi piatto. La preparazione è velocissima.',5,1,2.7061939965540738,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spinaci cubello','In questa porzione di spinaci surgelati, le foglie della pianta sono adagiate delicatamente una sullaltra, per mantenersi più soffici e più integre. Inoltre, dal punto di vista nutrizionale, i cubelli di Spinaci Foglia forniscono una dose di calcio sufficiente a soddisfare il fabbisogno quotidiano.',5,3,1.5574757513532467,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fiori di nasello','I Fiori di Nasello, così teneri e carnosi, sono la parte migliore dei filetti. Pescato nelle acque profonde dellOceano Pacifico, viene sfilettato ancora fresco e surgelato entro 3 ore così da preservarne al meglio sapore e consistenza.',5,20,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Minestrone tradizionale','Con il minestrone tradizionale, sarà possibile gustare la bontà autentica di ingredienti IGP e DOP, con il gusto unico di verdure al 100% italiane, coltivate in terreni selezionati. Nel minestrone sono presenti patate, carote, cipolle, porri, zucche, spinaci e verze.',5,4,2.662280227066378,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Patatine fritte','Esistono di forma rotonda, ovale o allungata, a pasta bianca o gialla, addirittura viola. Vengono selezionate con attenzione per qualità, dimensione e caratteristiche organolettiche, così da offrire tutto il meglio delle patate offerte dalla terra.',5,4,3.0355374892296383,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cimette di broccoli','Il broccolo è una varietà di cavolo che presenta uninfiorescenza commestibile. La raccolta dei broccoli avviene entro i 4-6 mesi successivi alla semina, poi le cimette sono rapidamente surgelati per preservare le loro proprietà nutrizionali.',5,2,3.1062952944958724,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polpette finocchietto','Deliziosi tortini di verdure subito pronti da gustare come antipasto, come contorno o come pratico piatto unico completato da uninsalata.',5,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Torroncini duri','Un assortimento di torroncini originale e sfizioso, tra cui vale la pena menzionare quelli profumati dalle note agrumate dei bergamotti e dei limoni calabresi, per poi farsi tentare dai gusti più golosi come caffè e nutella.',4,9,1.0028985080339992,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cantucci con cioccolato','Dolci toscani per eccellenza, da accompagnare con vini liquorosi come il Vin Santo, i cantucci offrono un ampio margine per sperimentare nuovi sapori. Fin dal primo morso si apprezza il perfetto equilibrio tra il gusto inconfondibile del cioccolato, esaltato da un lieve sentore di arancia, e limpasto tradizionale del cantuccio, per un risultato croccante e goloso.',4,1,0.9422077071907742,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Dolcetti alla nocciola','Piccoli e fragranti, con il loro invitante aspetto a forma di rosellina, questi dolcetti alla nocciola sono una specialità dal sapore antico e sempre stuzzicante. Lavorati con nocciole piemontesi Tonda Gentile IGP, i biscottini Michelis sono l’ideale da servire con un buon tè aromatico e delicato. Ottimi anche per la prima colazione.',4,3,2.564093610214636,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Paste di meliga','Tipiche del Piemonte, le paste di Meliga del Monregalese sono dei frollini dalla storia antichissima. La qualità del prodotto è data dallabbinamento di zucchero, uova fresche, burro a chilometro zero e farine locali, per un biscotto semplice e genuino. Fondamentale è il mais Ottofile. La grana grossolana della farina che ne deriva è il segreto di questi biscotti friabili.',4,2,1.6581561981550075,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Amaretti di sicilia','L’aspetto ricorda quello di un semplice biscotto secco ma le apparenze, che spesso ingannano, vengono subito smentite quando al primo morso la pasta comincerà a sciogliersi e rivelarsi in tutta la sua dolcezza. Gli Amaretti di Sicilia vengono presentati in eleganti confezioni regalo, una per ogni variante proposta: classica, al pistacchio di Sicilia, alla gianduia delle Langhe e al mandarino di Sicilia.',4,1,0.8079601856149232,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Celli pieni','Pochi ingredienti, semplici e genuini: il segreto della bontà dei celli ripieni è questo. Basta un piccolo morso per lasciarsi conquistare dal gusto intenso della scrucchijata, speciale confettura a base di uva di Montepulciano che non solo fa da ripieno, ma è il vero e proprio “cuore” di questo antico dolce della tradizione abruzzese.',4,2,3.424701810890358,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cannoli siciliani','Il cannolo è il dolce siciliano per eccellenza, disponibile in formato mignon e grande. Proveniente dai pascoli del Parco dei Nebrodi e del Parco delle Madonie, la migliore ricotta viene selezionata e lavorata in più fasi per renderla leggera e vellutata, creando un irresistibile contrasto con la granella di pistacchio e la friabile pasta che la ospita.',4,3,4.741508205521317,106);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crema gianduia','Senza grassi aggiunti, né aromi, ogni vasetto custodisce tutta l’essenza dei migliori ingredienti italiani, lavorati con cura e valorizzati da una piacevolissima consistenza. Un’ammaliante linea di creme dal gusto intenso e dolce, che coinvolgerà il palato in una sinfonia di sapori.',4,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Plum cake','Del classico plum cake resta la morbidezza e la delicatezza, ma per tutto il resto, linterpretazione siciliana si differenzia dallo standard. Uva passa e rum sanno elevare il carattere timido di questo dolce in maniera netta e riuscita. La giusta componente alcolica accende di gusto luva e la frutta secca presente nellimpasto.',4,3,2.0879542877056556,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pignolata','Probabilmente il dolce più caratteristico di tutta Messina, immancabile a carnevale ma preparato ed apprezzato tutto lanno. Tanti piccoli gnocchetti di impasto realizzato con farina, uova e alcol vengono fritti ed assemblati. La fase finale prevede una glassatura deliziosa: per metà al limone e per la restante metà al cioccolato.',4,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo Switch','Nintendo Switch, una console casalinga rivoluzionaria che non solo si connette al televisore di casa tramite la base e il cavo HDMI, ma si trasforma anche in un sistema da gioco portatile estraendola dalla base, grazie al suo schermo ad alta definizione.',7,2,2.5024816554463314,66);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grand Theft Auto V','Il mondo a esplorazione libera più grande, dinamico e vario mai creato, Grand Theft Auto V fonde narrazione e giocabilità in modi sempre innovativi: i giocatori vestiranno di volta in volta i panni dei tre protagonisti, giocando una storia intricatissima in tutti i suoi aspetti.',7,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Toy story 2','Il conto alla rovescia per questavventura comincia su Playstation 1, nei panni di Buzz Lightyear, Woody e tutti i loro amici. Sarà una corsa contro il tempo per salvare la galassia dal malvagio imperatore Zurg.',7,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ratchet and Clank','Una fantastica avventura con Ratchet, un orfano Lombax solitario ed esuberante ed un Guerrabot difettoso scappato dalla fabbrica del perfido Presidente Drek, intenzionato ad uccidere i Ranger Galattici perché non intralcino i suoi piani. Questo lincipit dellavventura più cult che ci sia su Playstation.',7,3,3.4529328139691,40);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nintendo snes mini','Replica in miniatura del classico Super Nintendo Entertainment System. Include 21 videogiochi classici, tra cui Super Mario World, The Legend of Zelda, Super Metroid e Final Fantasy III. Sono inclusi 2 controller classici cablati, un cavo HDMI e un cavo di alimentazione.',7,8,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Playstation 3 Slim','PlayStation 3 slim, a distanza di anni dal lancio del primo modello nel 2007, continua ad essere un sofisticato sistema di home entertainment, grazie al lettore incorporato di Blu-ray disc™ (BD) e alle uscite video che consentono il collegamento ad unampia gamma di schermi dai convenzionali televisori, fino ai più recenti schermi piatti in tecnologia full HD (1080i/1080p).',7,3,3.441296262982526,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xbox 360','Xbox 360 garantisce l’accesso al più vasto portafoglio di giochi disponibile ed un’incredibile offerta di intrattenimento, il tutto ad un prezzo conveniente e con un design fresco ed accattivante, senza rinunciare a performance eccellenti.',7,4,1.23416708942933,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Crash Bandicoot trilogy','Crash Bandicoot è tornato! Più forte e pronto a scatenarsi con N. Sane Trilogy game collection. Sarà possibile provare Crash Bandicoot come mai prima d’ora in HD. Ruota, salta, scatta e divertiti atttraverso le sfide e le avventure dei tre giochi da dove tutto è iniziato',7,5,0.46672092763095696,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pokemon rosso fuoco','In Pokemon Rosso Fuoco sarà possibile sperimentare le nuove funzionalità wireless di Gameboy Advance, impersonando Rosso, un ragazzino di Biancavilla, nel suo viaggio a Kanto. Il suo sogno? Diventare lallenatore più bravo di tutto il mondo!',7,4,3.8118709216696143,83);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('God of War','Tra dei dellOlimpo e storie di vendette e intrighi di famiglia, Kratos vive nella terra delle divinità e dei mostri norreni. Qui dovrà combattere per la sopravvivenza ed insegnare a suo figlio a fare lo stesso e ad evitare di ripetere gli stessi errori fatali del Fantasma di Sparta.',7,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nastro parastinchi','Nastro adesivo in colorazione giallo neon, disponibile anche in altre colorazioni. 3,8cm x 10m. Ideale per legare calzettoni e parastinchi.',8,1,0.28341268286625865,19);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Calzettoni Adidas','Calzettoni Adidas disponibili in numerose colorazioni, con polsini e caviglie con angoli elasticizzati a costine. Imbottiture anatomiche che sostengono e proteggono la caviglia.',8,4,3.071570871394865,99);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglietta Italia','Maglia FIGC, replica originale nazionale italiana. Realizzata con tecnologia Dry Cell Puma, che allontana lumidità dalla pelle per mantenere il corpo asciutto.',8,1,0.08773777695394003,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borsone palestra','Borsa Brera / adatto per la scuola - palestra - allenamento - ideale per il tempo libero. Disponibile in diverse colorazioni e adatta a sportivi di qualsiasi tipo. Involucro protettivo incluso.',8,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Nike Mercurial','La scarpa da calcio da uomo Nike Mercurial Superfly VI academy CR7 garantisce una perfetta sensazione di palla e con la sua vestibilità comoda e sicura garantisce unaccelerazione ottimale e un rapido cambio di direzione su diverse superfici.',8,4,2.7952144409020043,29);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Porta da giardino','Porta da Calcio in miniatura, adatta a giardini. Realizzata in uPVC 2,4 x1,7 m; Diametro pali : 68mm. Sistema di bloccaggio ad incastro per maggiore flessibilità e stabilità, per essere montata in appena qualche minuto.',8,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cinesini','Piccoli coni per allenare lagitlità, il coordinamento e la velocità. Molti campi di impiego nellallenamento per il calcio. Sono ben visibili, grazie ai colori appariscenti e contrastanti. Il materiale è flessibile e resistente.',8,5,4.418048886042279,70);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set per arbitri','Carte arbitro da calcio: set di carte arbitro include cartellini rossi e gialli, matita, libro tascabile con carte di scopo punteggio del gioco allinterno e un fischietto allenatore di metallo con un cordino.',8,3,2.808893530298402,73);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Maglia personalizzata','La Maglia è nella versione neutra e viene personalizzata con Nome e Numero termoapplicati da personale esperto. Viene realizzata al 100% in poliestere. Non ha lo sponsor tecnico e le scritte sono stampate.',8,3,3.9409776808770234,26);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pallone Mondiali','Pallone ufficiale dei mondiali di calcio Fifa. Il pallone Telstar Mechta, il cui nome deriva dalla parola russa per sogno o ambizione, celebra la partecipazione ai mondiali di calcio FIFA 2018 e la competizione. Questo pallone viene fornito con lo stesso design monopanel del Telstar ufficiale 18. ',8,2,3.0533381490150924,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Zaino da alpinismo','Questa borsa è disponibile in colori attraenti. Ci sono molte tasche con cerniere in questa borsa per diversi oggetti che potrebbero essere necessari per un viaggio allaperto. È imbottito per il massimo comfort. Questa borsa è di 40 e 50/60/80 litri. Tessuto in nylon idrorepellente e antistrappo. Cinghie regolabili e lunghezza del torace.',10,3,3.4854738765300644,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo emergenza','Questo sacco a pelo di emergenza trattiene il 90% del calore corporeo irradiato in modo da preservare il calore vitale in circostanze fredde e difficili. È abbastanza grande da coprirti dalla testa ai piedi. Dai colori vivaci in arancione vivo, questo sacco a pelo può essere immediatamente visto da lontano, rendendolo un rifugio indispensabile in attesa delle squadre di soccorso. Questo articolo ti aiuta a rimanere adeguatamente isolato dallaria fredda in modo da poter dormire comodamente e calorosamente quando vai in campeggio in inverno. È impermeabile e resistente alla neve, quindi puoi indossarlo come impermeabile per proteggerti dalla pioggia e dalla neve. Se necessario, puoi anche stenderlo su un grande prato come tappetino da picnic.',10,14,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo','Sacco a pelo lungo di 2 metri per 70 cm di larghezza, ampi, con la possibilità di piegare la borsa quando aperto come una trapunta. Facile da aprire e chiudere con una cerniera che può essere bloccata. La parte superiore è circolare per un maggiore comfort per lutilizzatore. Cerniera di alta qualità e la tasca interna utile per riporre piccoli oggetti. Zipper riduce la perdita di calore. Il tessuto esterno è impermeabile e umidità realizzato con materiali di alta qualità e pieni di fibre offrono comfort e calore. Campo di temperatura tra i 6 ei 21 gradi. Questo sacco a pelo vi terrà al caldo, indipendentemente dal luogo o periodo dellanno.',10,3,0.26616730775565256,97);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacco a pelo matrimoniale','Questo sacco a pelo di lusso è semplicemente fantastico. Si arrotola e si ripone facilmente in una borsa da trasporto, include una cerniera integrale con due tiretti ed è dotato di cinghie in velcro laterali. Alcuni dei nostri prodotti sono realizzati o rifiniti a mano. Il colore può variare leggermente e possono essere presenti piccole imperfezioni nelle parti metalliche dovute al processo di rifinitura a mano, che crediamo aggiunga carattere e autenticità al prodotto.',10,17,3.3162545955833767,95);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tenda 4 persone','Comode tasche nella tenda interna per accessori e un porta lampada per una lampada da campeggio o torcia completano il comfort. Tenda ventilata per un sonno indisturbato. L ingresso con zanzariera tiene alla larga le fastidiose zanzare. Le cuciture assicurano una grande resistenza allo strappo e, quindi, alla rottura.',10,4,4.50501975123662,75);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltello Magnum 8cm','Ottimo accessorio da avere sul campo, per essere pronti a qualsiasi tipo di wood carving o altra necessità. Le dimensioni ne richiedono, tuttavia, lutilizzo previo possesso di porto darmi. Il manico è in colore rosso lucido.',10,2,4.077467375150116,24);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bastoncini trekking','I bastoncini di fibra di carbonio resistente offrono un supporto più forte dei modelli dalluminio; il peso ultra-leggero (195 g/ciascuno) facilita le camminate riducendo la tensione sui polsi.',10,3,1.3280167797736864,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lanterna da fronte','Torcia da testa Inova STS Headlamp Charcoal. Corpo in policarbonato nero resistente. Cinghia elastica in tessuto nero. LED bianco e rosso. Caratteristiche interfaccia Swipe-to-Shine che permette un accesso semplice alle molteplici modalita - il tutto con il tocco di un dito.',10,4,1.1911757836705683,39);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fornelletto a gas','Fornelletto da campo di facilissimo utilizzo: è sufficiente girare la manopola, ricaricare con una bomboletta di butano e sarà subito pronto a scaldare le pietanze che vi vengono poggiate. Ha uno stabile supporto in plastica dura e la potenza del bruciatore è di 1200 watt.',10,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Borraccia con filtro','Rimuove il 99.99% di batteri a base d acqua,, e il 99.99% di iodio a base d acqua, protozoi parassiti senza sostanze chimiche, o batteriche. Ideale per viaggi, backpacking, campeggi e kit demergenza.',10,3,2.316953364224296,69);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rullo per allenamento','Bloccaggio fast fixing: è possibile agganciare e sganciare la bicicletta con un sola rapida operazione. 5 livelli di resistenza magnetica. Nuovo sistema di supporto regolabile dell’unità che consente un’idonea e costante pressione tra rullino dell’unità e pneumatico',9,2,3.6402159093653887,23);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pedali Shimano','Pedale di tipo click spd, con peso di coppia 380G, con i migliori materiali targati Shimano. Utilizzo previsto: MTB, tuttavia è possibile utilizzarli anche per viaggiare su strada',9,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Catena 114L Ultegra','Catena bici da corsa 10 velocità. Pesa 118g, argento, 114 maglie. Ideale per qualsiasi tipo di terreno e di utilizzo. Garantita la resistenza fino a 5000km di utilizzo, soddisfatti o rimborsati',9,2,1.4725637641398925,21);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Freni a pattino','Freni a pattino per cerchioni in alluminio. La confezione contiene 4 pezzi, quindi permettte di sostituire entrambi gli impianti di frenatura: quello anteriore e quello posteriore. Sono lunghi 70mm e universali.',9,4,3.0802900013316803,92);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sella da corsa Uomo','Sella da corsa, talmente comoda che è stata progettata utilizzzando gli stessi materiali e blueprint delle selle da trekking o touring. Imbottitura in gel poliuretanico morbido, con un telaio color acciacio molto resistente.',9,2,0.7756123716503505,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ruota Maxxis da strada','Ottima gomma per chi oltre allo sterrato fa anche asfalto, da usare sia con camera daria che tubless. La linea centrale di tacchetti offre un buon supporto in asfalto ed evita che la gomma si usuri troppo ai lati. Nello sterrato asciutto nessun problem, ottima tenuta in curva. Per chi ha problemi di forature sulla spalla esiste anche la versione EXO.',9,4,1.064012798532017,97);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Rastrelliera da parete','Rastrellilera verticale, da parete, con supporto fino a cinque biciclette di dimensioni naturali. I ganci sono rivestiti in plastica per una massima protezione dai graffi. I fissaggi non sono inclusi.',9,2,4.272427416667995,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Barra per tandem','Consente di collegare qualsiasi bicicletta convenzionali per bambini a biciclette per adulti. Veloce e facile da montare, può essere attaccato senza attrezzi ed essere usato con le biciclette per bambini da 12 a 20 e con un supporto massimo per un peso di 32kg.',9,4,2.572795661010141,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Lucchetto antifurto','Lucchetto Onguard Brute a U, x4p quattro Bolt. Intrecciato con bubblok, con un cilindro particolare incluso. I materiali con cui è stato realizzato sono acciaio inossidabile temperato e doppio rivestimento in gomma dura.',9,1,2.2101050150165236,51);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Casco AeroLite rossonero','Doppio In-Mould costruzione fonde il guscio esterno in policarbonato con Caschi assorbenti del nucleo interno schiuma, dando un casco estremamente leggero e resistente.',9,4,3.5804961961318984,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tappetino da yoga','180 x 61 cm tappeto per utilizzi molteplici. Realizzato in Gomma NBR espansa ad alta densità, lo spessore premium da 12 mm ammortizza confortevolmente la colonna vertebrale, fianchi, ginocchia e gomiti su pavimenti duri.',11,2,2.5820687430834433,98);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitness tracker Xiaomi Mi Band 3','Display touch full OLED da 0,78. Durata della batteria fino a 20 giorni (110 mAh). 20 gr di peso. Impermeabile fino a 50 metri (5ATM), Bluetooth 4.2 BLE, compatibile con Android 4.4 / iOS 9.0 o versioni successive.',11,4,2.473724236018371,82);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Corda da saltare','Gritin Corda per Saltare, Regolabile Speed Corda di Salto con la Maniglia di Schiuma di Memoria Molle e Cuscinetti a Sfera - Regolatore di Lunghezza della Corda di Ricambio(Nero)',11,2,4.037404067286582,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ciclette ultrasport cardio','Ultrasport F-Bike Design, Cyclette da Allenamento, Home Trainer, Fitness Bike Pieghevole con Sella in Gel, con Portabevande, Display LCD, Sensori delle Pulsazioni, Capacità di Carico 110kg',11,1,1.6522556162814983,59);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fasce elastiche fitness','nsonder Elastiche Fitness Set di 4 Bande Elastiche e Fasce di Resistenza per Fitness Yoga Crossfit',11,1,3.929141640187109,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tesmed elettrostimolatore','Tesmed MAX 830, Elettrostimolatore Muscolare Professionale con 20 elettrodi: massima potenza, addominali, potenziamento muscolare, contratture e inestetismi',11,15,0.03211218932340776,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fascia dimagrante addominale','Fascia Addominale Dimagrante per Uomo e Donna, Regolabile Cintura Addominale Snellente, Brucia Grassi e Fa Sudare, Sauna Dimagranti Addominali, Di Neoprene (Fascia Addominale Dimagrante di fascia 2)',11,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Palla da pilates','BODYMATE Palla da Ginnastica/Fitness Palla da Yoga per Allenamento Yoga & Pilates Core Compresa Pompa - Resistente Fino a 300kg, Disponibile nelle Dimensioni da 55, 65, 75, 85 cm',11,3,0.4965916649792912,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pedana di equilibrio','Emooqi Pedana di Equilibrio in Legno antiscivolo Balance Board per equilibrio e coordinazione Carico massimo circa 150 kg/ dimensione circa 39.5 cm',11,3,0.2508614622935157,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Piccoli manubri','Coppia di piccoli pesi, perfetti per lallenamento casalingo con centinaia di ripetizioni. Bel colore, materiale gradevole al tatto con ottima grippabilita (anche a mani sudate).',11,3,1.5650054352305243,43);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike React Element 55','Riprendendo le linee di design dai nostri modelli da running leggendari, come Internationalist, la scarpa Nike React Element 55 - Uomo accoglie la storia e la spinge verso il futuro. La schiuma Nike React assicura leggerezza e comfort, mentre i perni in gomma sulla suola e i dettagli rifrangenti offrono un look allavanguardia che vuole una reazione.',23,3,3.3177474422209574,51);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike Air Max 1','La scarpa Nike Air Max 1 - Uomo aggiorna il leggendario design con nuovi colori e materiali senza rinunciare alla stessa ammortizzazione leggera delloriginale.',23,3,3.830597083409779,89);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Air Jordan 1 Retro High OG','La scarpa Air Jordan 1 Retro High OG sfoggia uno stile ispirato alla tradizione, con materiali premium e ammortizzazione reattiva. Il colore mostrato in foto è Vintage Coral/Sail.',23,1,4.833882788857672,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nike Benassi JDI SE','Grazie al suo design astratto, la slider Nike Benassi JDI SE Slide è perfetta per dare energia e vivacità al tuo look. Fascetta sintetica, fodera in jersey e intersuola in schiuma per una sensazione di morbidezza e un comfort ideale.',23,3,2.603477980555111,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Air Jordan 1 Low','Air Jordan 1 Low: struttura premium, morbido comfort. Uno tra i modelli più iconici in assoluto della linea Nike. Uno dei simboli della storia delle scarpe da Basket.',23,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Adidas Stan Smith','Le classiche sneaker Stan Smith in una nuova versione che ripropone dettagli autentici, come la tomaia in pelle con 3 strisce traforate e finiture brillanti a contrasto. Le chiusure a strappo assicurano praticità e comfort',23,1,0.16898315480984194,109);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ciabatte Adidas Duramo','Perfette prima e dopo ogni allenamento, le ciabatte adidas Duramo sono un classico sportivo. Con un design monoblocco impeccabile, ad asciugatura rapida, queste semplici ciabatte per la doccia offrono un comfort allinsegna della praticità e prestazioni affidabili.',23,1,3.1916448065709813,95);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scarpe Gazelle Adidas','Un inno allessenzialità che stupisce da oltre trentanni. Questo remake delle Gazelle rende omaggio al modello del 1991 riproponendo materiali, colori, texture e proporzioni della versione originale. La tomaia in pelle sfoggia 3 strisce a contrasto e un rinforzo sul tallone.',23,13,2.490733958256366,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('All Star Classic High Top','Le Chuck Taylor All Star sono delle sneaker classiche, che resistono allesame del tempo, a prescindere dalla stagione, dal luogo e dal look. In questo tono giallo pacato daranno la possibilità di sembrare pulcini, per quanto poco utile possa essere.',23,3,4.699854437303595,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Converse One Star Corduroy','Le Converse Custom One Star Corduroy Low Top sono un modello moderno, che non rinuncia allo stile classico ed equilibrato. Prende tuttavia uno spunto dal mondo degli skateboarders americani.',23,1,4.495215255328489,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Abbey','I Van Orton Design reinterpretano in chiave pop una delle copertine più celebri e citate della storia della musica e rendono omaggio alla band che ha ridefinito il concetto stesso di “pop”.',26,4,4.176479520658161,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Gran Tour','Un viaggio spensierato tra arte e design, la leggerezza di una gita fuori porta, una famiglia a cavallo di una vespa. Tutto dipinto in punta di pennello, perché ogni viaggio comincia con l’immaginazione.',26,3,0.5431119030692699,107);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Pink Floyd','“So, so you think you can tell heaven from hell?”. Questa t-shirt dei gemelli Van Orton Design è indossabile soltanto da chi riconosce la citazione originale, che coglierà anche il motivo della grafica rappresentante una stretta di mano particolarmente calda.',26,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Go Fast','Come un pinguino, di pancia, sullo skate. Sì, lo sappiamo: i pinguini scivolano benissimo anche senza skate. Ma, vuoi mettere? Philip Giordano ci ricorda che tutto è possibile.',26,1,3.084789696064788,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Coca Cola','Doveva essere la copertina per un libro del filosofo Jean Baudrillard ma poi è diventata una maglietta. Forse non ci crederai, ma Matteo Berton ci ha assicurato che le bare a forma di Coca Cola esistono davvero!',26,3,0.36448610650860136,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Equilibrio','Questo artwork di Jonathan Calugi nasce da una ricerca sulle connessioni e le percezioni. Un equilibrio di corpi e punti che ci dimostra come l’occhio umano, anche in presenza di elementi incompleti, riesca a ricostruire un’immagine nitida di ciò che sta osservando.',26,4,4.472215232257916,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Serenade','Un vecchio giradischi, un vinile e quella canzone che ti ricorda di quella volta che avete ballato insieme per la prima volta. Il tutto in unincredibile e futurista illustrazione del maestro di graphic design Alessandro Giorgini.',26,2,1.1313247748480637,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Colori e luce','Riccardo Guasco riesce a rendere poetico anche un fascio di strisce orizzontali; e regalare un sorriso. L’illustrazione fa parte di un progetto col quale Rik ha voluto reinterpretare a modo suo lo stile asettico della scuola astrattista.',26,2,4.1822580391986905,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Connessioni','Questo lavoro nasce per la serie limitata di carte da gioco Playing Arts. Jonathan ha scelto di illustrare il 2 di fiori con il suo inconfondibile tratto unico rappresentando sovrapposizioni e connessioni che si fondono e si confondono.',26,3,0.8242609605231932,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tshirt Pizza true love','“Pizza. T’amo senza sapere come, né quando, né dove. T’amo senza limiti né orgoglio: t’amo così, perché non so amarti altrimenti”. Per Mauro Gatti il vero amore sa di pizza.',26,8,3.8331835409880535,11);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Curved Bill','Il cappellino da jockey Vans Mayfield Curved Bill è un modello con logo Vans ricamato sulla visiera.',27,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Vans x Marvel','Vans e Marvel si uniscono per celebrare gli iconici supereroi dellUniverso Marvel in una collezione straordinaria di abbigliamento, calzature e accessori. Il cappellino jockey Vans x Marvel è un modello retrofit regolabile a 6 pannelli con ricamo di Iron Man su tessuto.',27,20,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Berretto Core Basics','Il berretto Vans Core Basic è uno zuccotto con targhetta con logo Vans, in colorazione Port Royale. Taglia unica. Disponibile in 7 colorazioni diverse, due delle quali colorate a camouflage.',27,16,3.9689093974222702,38);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cappellino Davis 5','Il cappellino Vans Davis è un modello camper a 5 pannelli con etichetta Vans in ecopelle sul pannello anteriore e cinghia di regolazione sul retro. Disponibile in 4 colorazioni bicolore.',27,1,3.429270662715452,108);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jockey Vans x Hulk','Vans e Marvel si uniscono per celebrare gli iconici supereroi dellUniverso Marvel in una collezione straordinaria di abbigliamento, calzature e accessori. Il cappellino jockey Vans x Marvel è un modello retrofit regolabile a 6 pannelli con ricamo di Hulk su tessuto.',27,4,4.066747796851754,23);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Baseball Disney x Vans','Realizzato per celebrare lo spirito e levoluzione di Topolino, il cappellino da baseball Disney X Vans in 100% cotone è un modello a 5 pannelli con stampa rétro di Topolino serigrafata.',27,2,3.0341577675237463,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Baseball classic patch','Il cappellino da baseball Classic Patch è un modello a 5 pannelli in 80% acrilico e 20% lana con una visiera in 100% cotone e unapplicazione Vans Off The Wall sul pannello anteriore.',27,4,1.2343107587042923,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Vans Visor Cuff','Il berretto Vans Visor Cuff presenta una stampa mimetica integrale, visiera ed etichetta Vans sul davanti. Pensato per gli skaters che non si vogliono fermare davanti ad un inverno rigido',27,3,3.380445774249395,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cappellino Camper 5','Il cappellino camper Vans Flap a 5 pannelli è realizzato in 100% tela di cotone cerata, presenta copriorecchie trapuntati e unapplicazione Vans in ecopelle a rilievo.',27,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Berretto Pom Off The Wall','Il berretto Off The Wall Pom è un modello in 93% acrilico, 6% nylon e 1% elastan con grafica OFF THE WALL in jacquard e pompon.',27,2,0.095043077636221,50);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chino Elasticizzati','I pantaloni chino in twill Sturdy Stretch sfoggiano unintramontabile combinazione tra stile classico e praticità necessaria per lo skateboard',24,1,0.44280932589582434,12);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chino Authentic','Un modello realizzato per mantenere a lungo la forma e lelasticità, con tasche anteriori allamericana, tasche posteriori a filo con chiusura a bottone, unetichetta del brand intessuta e una comoda vestibilità slim leggermente affusolata.',24,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Cross Town','I pantaloni sportivi Vans Cross Town presentano nastri su entrambi i lati con il logo Off The Wall, un cordino regolabile con motivo a scacchi in vita e una tasca posteriore con letichetta Vans. Il modello è alto 1,86 m e indossa una taglia 32.',24,1,3.4930540906254293,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jean Vintage Blute Taper','Pensati per offrire comodità e resistenza nel tempo, i Vans V46 Taper sono jeans a vita media in denim con finitura grezza. Questo modello presenta 5 tasche, una patta con cerniera, una mostrina in vera pelle al livello della vita e una vestibilità affusolata che si restringe alla caviglia.',24,3,3.1076408191296725,82);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jeans Inversion','Dalla vestibilità ampia, i jeans Vans Inversion sono un modello straight con striscia laterale stile smoking, due tasche laterali e due posteriori.',24,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Summit','La collezione Design Assembly unisce un design innovativo a un tocco urbano per creare uno stile ricco di dettagli. I pantaloni Vans Summit sono un modello a vita alta corto alla caviglia, con tasche laterali e posteriori, passanti per cintura ed etichetta Vans sul retro.',24,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloni Checkboard Authentic','La collezione Design Assembly unisce un design innovativo a un tocco urbano per creare uno stile ricco di dettagli. Comodi, caldi e oversize come labbigliamento maschile ma con un tocco di femminilità, i pantaloni a gamba larga Design Assembly Checkerboard presentano tasche allamericana e vita medio alta.',24,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Framework Salopette','La salopette Vans Framework è un modello carpenter con cuciture a punto triplo e diverse tasche, tra cui due oblique, una frontale sul petto e tre posteriori. Decorata da bottoni in metallo con logo.',24,1,1.0345643326580056,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Jeans Skinny 9','I Vans Skinny 9 sono dei jeans skinny a vita alta con tagli sulle ginocchia, due tasche frontali e due posteriori.',24,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pantaloncini Tremain','Modello cargo dalla vestibilità comoda, i pantaloncini Tremain sono realizzati in 100% cotone dobby tinto in filo. Colorazione beige e con camouflage militare.',24,9,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Girocollo Retro Tall','La felpa girocollo Vans Retro Tall Type è un modello a maniche lunghe con logo Vans sulla parte sinistra del petto e sul retro.',25,1,1.36289236907712,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Versa Quarter Zip','Progettata da designer esperti e con collo a lupetto, la felpa Versa Quarter offre il massimo delle prestazioni senza rinunciare allo stile. Realizzata con maestria per resistere alle condizioni atmosferiche e allusura causata dallo skateboard',25,3,1.102508017487538,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa con cappuccio versa','La felpa in pile di qualità è dotata di una tasca a marsupio sul davanti, fodera del cappuccio con stampa a contrasto, maniche con motivo checkerboard serigrafato e un ricamo sul petto.',25,3,1.9176844425090378,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa cappuccio cross town','La felpa Vans Cross Town è un modello a maniche lunghe con tasca frontale a marsupio e cappuccio dotato di cordino con motivo a scacchi. Presenta il logo Vans sul davanti e la grafica Off The Wall sulle cuciture.',25,3,4.529865726659404,81);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa classic con cappuccio','La felpa Vans Classic è un modello a maniche lunghe con cappuccio, zip, tasche frontali e logo Vans sul petto.',25,3,4.35012046954307,29);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa con cappuccio skate','La felpa con cappuccio Vans Skate è realizzata in pile e presenta una tasca a marsupio frontale e il logo Vans sulla parte sinistra del petto.',25,4,4.763398887532393,89);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Tall Box Stripe','La felpa con cappuccio Tall Box Stripe è realizzata in 60% cotone e 40% poliestere e presenta una tasca a marsupio sul davanti, righe tinte in filo e ricamo del logo sul petto.',25,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Distort','La felpa Vans Distort presenta una tasca a marsupio sul davanti, maniche lunghe, tramezzi laterali a coste e loghi Vans serigrafati su busto, cappuccio e fondo della manica.',25,4,3.1848952250234785,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Square Root','La felpa Vans Square Root è un modello con cappuccio, maniche lunghe e una tasca a marsupio sul davanti. È inoltre decorata con il logo Vans sulla parte sinistra del petto e dettaglio checkerboard lungo la manica sinistra.',25,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Felpa Classic Crew','La felpa Vans Classic è un modello a girocollo con logo Vans stampato sul petto. Disponibile in varie colorazioni, tutte in colori brillanti e stampe di altissima qualità.',25,3,3.3387917485346574,44);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('GoPro hero7','Riprese incredibilmente stabili. Capacità di acquisizione intelligente. Robusta e impermeabile senza bisogno di custodia. Tutto questo è HERO7 Black: la GoPro più avanzata di sempre.',19,3,2.439737104131341,28);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sony DSC-RX100','Sony DSC-RX100 fotocamera digitale compatta, Cyber-shot, sensore CMOS Exmor R da 1 e 20.2 MP, obiettivo Zeiss Vario-Sonnar T, con zoom ottico 3.6x e nero.',19,1,0.693324300619057,102);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nikon D3500','Nikon D3500: fotografa, riprendi video, condividi, divertiti, stupisci. La nuova reflex digitale entry level da 24,2 Megapixel è la fotocamera perfetta per chi si avvicina al mondo della fotografia, in virtù del suo design confortevole e delle sue modalità di ripresa che ne rendono facilissimo luso.',19,4,0.5874055446833171,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sony Alpha 7K','Con i suoi 24,3 megapixel, il sensore Exmor full-frame 35 mm della α7 offre prestazioni che non temono quelle delle migliori reflex digitali. Inoltre, grazie al processore Bionz X e alla messa a fuoco automatica ottima di Sony, lα7 offre un livello di dettaglio, sensibilità e qualità eccellente. Sei pronto per uno shooting fotografico da urlo.',19,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nikon Coolpix W100','La W100 è progettata per resistere agli urti da unaltezza massima di 1,8 m, impermeabile fino a 10 m, resistente al freddo fino a -10°C e alla polvere.',19,3,0.6242088394256096,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Polaroid Snap','Dai ritratti ai selfie, questa potente fotocamera da 10 MP cattura ogni dettaglio e stampa in un istante, senza bisogno di pellicole o toner. Aggiungi una scheda microSD per salvare le tue foto e stamparle successivamente.',19,2,4.646115421912324,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samoleus Fotocamera Giocattolo','La mini macchina fotografica digitale ha uno schermo di 1,5 pollici. È adatto per migliorare i bambini linteresse di scattare foto, sviluppare il loro cervello e farli amare le attività allaria aperta. Può anche essere usato come regalo perfetto per i bambini.',19,1,2.2686911393093965,101);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fujifilm X-A5','Fujifilm X-A5 Silver Fotocamera Digitale da 24 Mp e Obiettivo Fujinon XC15-45mm f3.5-5.6 OIS PZ, Sensore CMOS APS-C, Ottiche Intercambiabili, Argento/Nero',19,1,1.243912735987004,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Canon EOS M6','Allinterno del corpo compatto di EOS M6 troverai un ampio sensore CMOS da 24,2 megapixel che produce risultati eccellenti anche in condizioni di scarsa luminosità o ad alto contrasto',19,2,2.5204474399967625,92);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Olympus OM-1','Una delle migliori fotocamere a pellicola che siano storicamente esistite. Grazie allimpugnatura in cuoio nero e il corpo in acciaio riesce sempre ad essere un grande strumento fotografico, ma allo stesso tempo un grande oggetto di design',19,15,2.2821929193326698,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Apple iPhone XS','Phone X è uno smartphone diverso da tutti gli altri iPhone che abbiamo visto finora e lo splendido schermo OLED è solo uno dei fattori che contribuiscono a fargli ottenere punteggi elevatissimi.',18,1,2.3335497753443257,90);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung S9','Samsung Galaxy S9 è uno degli smartphone Android più avanzati e completi che ci siano in circolazione. Dispone di un grande display da 5.8 pollici e di una risoluzione da 2960x1440 pixel che è fra le più elevate attualmente in circolazione.',18,2,3.2878667673937487,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('OnePlus 6T','OnePlus 6T è veloce e fluido grazie al processore Qualcomm Snapdragon 847. OnePlus 6T ha un display 19.5:9 Optic AMOLED che regala un’esperienza immersiva. Uno dei migliori smartphone Android in circolazione.',18,6,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Nokia 3310','Uno dei telefoni storicamente più importanti della storia delluomo. Si narra che la leggenda della spada nella roccia sia nata da qui, così come lestinzione dei dinosauri sulla Terra.',18,21,3.5016464136199854,106);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Topcom Sologic T101','Questo telefono analogico con filo è molto facile da usare. Adatto a persone con problemi di vista grazie ai tasti di grandi dimensioni.',18,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Google Pixel 3XL',' Questo smartphone è l’incarnazione di ciò che Google ritiene debba offrire uno smartphone: prestazioni avanzate del comparto fotografico, display ampio e di buona qualità, supporto nativo a tutte le feature dell’assistente virtuale e aggiornamenti costanti del sistema operativo. ',18,4,2.3043931901866745,88);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG G6','Questo smartphone è la rivoluzione in casa coreana, con design unibody, schermo inedito e addio alla modularità. Il risultato è un prodotto solido e capace di tenere testa a qualunque altra ammiraglia.',18,3,4.719023497757443,105);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei P10 lite','Huawei P10 Lite è l’atto finale di una trilogia e l’inizio della seconda vita di Huawei. Dopo P8 e P9, il lancio del P10 segna un capitolo fondamentale per questa serie di smartphones, portando una serie di innovazioni dal punto di vista dello schermo, della fotocamera e della batteria.',18,2,0.6000220176089921,60);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Panasonic Telefono Cordless','Panasonic KX-TG1611 offre funzioni come: la rubrica da 50 voci (nome e numero), la memoria di riselezione (fino a 10 numeri), la suoneria portatile selezionabile, la sveglia e lorologio, la risposta con qualsiasi tasto, e altro ancora',18,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Motorola RAZR V3','Simbolo dei millennials, questo precursore degli smartphone, caratterizzato dalla forma a guscio tagliente, rimarrà sempre una pietra miliare nella telefonia e nella storia di Motorola.',18,4,4.6759722226907465,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundLink Mini Bluetooth II','Il diffusore SoundLink Mini Bluetooth II offre un suono pieno, naturale e con bassi profondi che non ti aspetteresti da un dispositivo così piccolo. Inoltre, è dotato di microfono integrato per rispondere alle chiamate e facilita la connessione in wireless ovunque e in qualsiasi momento.',21,17,4.792928401298401,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Wave SoundTouch IV','Il Wave music system SoundTouch® appartiene a unintera famiglia di prodotti wireless, da sistemi all-in-one a configurazioni home cinema. I sistemi interagiscono per riprodurre la stessa musica ovunque o musica diversa in stanze diverse. Con SoundTouch®, ascoltare e scoprire nuova musica è più semplice che mai.',21,4,3.761111697846081,40);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundTouch 10','Ciascun diffusore SoundTouch 10 offre un suono ricco e profondo e consente di accedere in wireless alla tua musica preferita. Per cui puoi riprodurre musica diversa in due stanze differenti, o la stessa musica in entrambe le stanze. Inoltre, non potrebbe essere più facile da usare. Per riprodurre la tua musica in streaming, installa lapp gratuita SoundTouch sul tuo dispositivo.',21,4,1.169639440990865,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Soundbar Bose 300','La soundbar SoundTouch 300 offre prestazioni, ampiezza sonora e bassi migliori rispetto a qualsiasi altra soundbar all-in-one di pari dimensioni. Le innovative tecnologie contenute in questa soundbar ti consentono di ottenere il meglio da tutto quello che guardi e ascolti. Driver personalizzati, tecnologie QuietPort e PhaseGuide. ',21,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('QuietComfort 20 Noise Canc','Le cuffie QuietComfort 20 Acoustic Noise Cancelling offrono un suono straordinario, ovunque tu sia. Attiva la funzione di riduzione del rumore per concentrarti sullascolto della tua musica e annullare il mondo circostante.',21,3,2.4633731945495105,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cuffie QuietComfort 35','Cuffie QuietComfort 35 II wireless: il meglio di Bose. Vantano una tecnologia di riduzione del rumore di prima qualità e accesso diretto ad Amazon Alexa e Google Assistant per un semplice controllo vocale ovunque. La tua musica. La tua voce. Controllo totale.',21,1,2.1718057864692977,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Multimedia Companion',' Il sistema Companion® 50 crea un ambiente acustico di grande impatto, degno di un sistema composto da cinque diffusori. Invece, grazie a Bose®, sono sufficienti due eleganti diffusori da scrivania e un modulo Acoustimass® occultabile.',21,17,1.694707758775078,11);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('SoundLink Micro Bluetooth',' Il SoundLink Micro è un diffusore compatto ma potente, estremamente robusto e impermeabile. Inoltre, è dotato di un cinturino in silicone resistente agli strappi, per portarlo sempre con te ovunque. ',21,4,2.4211285418099813,18);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Home Speaker 500','Allinterno del Bose Home Speaker 500, due driver personalizzati puntano in direzioni opposte per far rimbalzare il suono dalle pareti. Il risultato? Un fronte sonoro più ampio di qualsiasi altro diffusore smart, così potente da riempire qualsiasi ambiente con un suono stereo straordinario.',21,4,3.6618694739153956,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Bose Bass Module 700','Bose Soundbar 700, è il miglior modulo bassi wireless che abbiamo mai ideato per i nostri sistemi home cinema. Infatti, offre le migliori prestazioni possibili con un subwoofer di queste dimensioni. Si connette in wireless alla soundbar e aggiunge ancora più profondità e impatto a tutti i contenuti, dagli effetti speciali dei film dazione alle playlist che risuonano in tutta la casa.',21,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG oled tv e8','Il TV LG OLED E8 porta il TV a un livello superiore grazie all’eccezionale qualità delle immagini e al design innovativo che si fondono armoniosamente. L’eleganza del vetro sposa la ricercatezza senza pari della tecnologia OLED per riprodurre immagini straordinarie che sembrano aprire la porta a nuovi mondi.',20,2,1.647990772061254,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('LG signature tv oled','TV LG SIGNATURE OLED W rispecchia l’essenza autentica del TV. Il design minimalista, il processore intelligente α9 e AI TV di LG completano la tua esperienza di visione.',20,3,0.4041187098096011,76);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung QLED tv 8k','Il TV Samsung QLED 8K Q900R offre un realismo dalla profondità quasi infinita, con dettagli così definiti che ti sembrerà di poterli toccare, come se stessi vivendo ogni scena in prima persona. Questa risoluzione super-elevata è una novità assoluta per la qualità dell’immagine.',20,3,2.6585464516192134,13);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung The Frame','Più di un semplice TV, The Frame è stato progettato per rendere ogni momento in casa qualcosa di magico. In più, questo televisore vanta una qualità dell’immagine eccellente, poiché si tratta di un incredibile 4K UHD. Scopri di più, ricopri la tua parete di arte ed eleganza.',20,4,0.5076807021759344,93);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('TV LCD portatile zoshing','1.9 pollici TV widescreen portatile, Risoluzione: 800 x 480, Rapporto: 16: 9. Attraverso lantenna, ingresso USB, lettore di schede TF, ingresso AV e altre opzioni per fornire immagini chiare. Controllo remoto completo.',20,3,4.478989111761562,47);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Philips 55 Smart TV UHD 4K','Smart TV LED 4K ultra sottile con Ambilight su 3 lati e Pixel Plus Ultra HD Versione Ambilight: 3 lati Funzioni Ambilight: Ambilight+Hue integrato Ambilight Music Modalità gioco Modalità Lounge.',20,22,2.4768082108473655,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung MU 6125','I TV UHD Samsung offrono un’esperienza visiva di qualità, con prestazioni Smart immediate e veloci, grazie a: risoluzione 4 volte superiore ai TV FHD, design Slim, da ogni lato, esperienza Smart powered by Tizen.',20,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('HISense Tv Led','HISENSE H43AE6000 4K Ultra HD con tecnologia HDR e tecnologia Precision Colour, nuova piattaforma SMART VIDAA U e il sistema audio Crystal Clear. La tecnologia HDR estende la gamma di luci e colori migliorando così nettamente la qualità delle immagini, per neri profondi e bianchi brillanti e intensi anche in condizioni di forte contrasto. Potrai così finalmente vedere ogni immagine in ogni minimo dettaglio.',20,4,1.3264255495437727,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grundig mod p45','Televisore tubo catodico da camera con doppia antenna ricezione originale e uscite scrd e tv. Modello top di gamma Grundig.',20,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Philips 6500 series','Smart TV LED ultra sottile 4K. Philips 6500 series Smart TV LED UHD 4K ultra sottile 43PUS6503/12, 109,2 cm (43\), 3840 x 2160 Pixel, LED, Smart TV, Wi-Fi, Nero',20,3,3.7605828064726285,53);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Razer Nabu Wear','Razer Nabu Watch, un orologio digitale smart che integra alcune funzioni smart, come monitor dell’attività fisica e notifiche via Bluetooth, grazie ad una batteria dedicata con quelle di un normale orologio digitale.',22,2,2.074088057521749,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Apple Watch Series 4','Ti presentiamo Apple Watch Series 4. Ridisegnato dentro e fuori per aiutarti a fare più movimento, tenere docchio la tua salute e restare in contatto con chi vuoi. Ora anche con connettività cellulare.',22,1,3.122440395304583,42);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung Gear S3 Frontier','Display touch 1.3” (360 x 360 pixel) AOD. Certificazione IP68. Memoria 4 GB. Processore Dual Core. Connettività: LTE, bluetooth 4.2, Wi-Fi b/g/n, NFC, MST, GPS/Glonass. Batteria 380 mAh. Sensori: accelerometro, giroscopio, barometro, cardiofrequenzimetro, luce ambiente',22,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei Band 2 Pro','HUAWEI Band 2 Pro. Modulo GPS indipendente. Monitora in tempo reale distanza e ritmo. Monitoraggio battito cardiaco.',22,4,2.0621269782169396,36);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Xiaomi MI Band 2','Xiaomi Mi Band 2 è un dispositivo consigliato se volete un sistema spiccio per ricevere le notifiche e per tenere un conto sommario dei passi durante la giornata, della distanza percorsa sul tapis roulant della palestra, delle ore di riposo notturno.',22,2,0.21076075738212352,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitbit Versa','Fitbit Versa, lo smartwatch che ti aiuta a conoscerti meglio per vivere una vita più sana. Raggiungi i tuoi obiettivi di forma e benessere con questo smartwatch leggero e resistente allacqua sempre al tuo polso per motivarti. Allenati con gli esercizi su schermo e semplifica la tua giornata con le notifiche, le risposte rapide, le app, la tua musica e unautonomia di oltre 4 giorni.',22,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Fitbit Charge','Monitora il tuo battito cardiaco continuamente dal polso per allenarti meglio, tenere sotto controllo le calorie bruciate e avere un quadro più completo della tua salute, tutto senza una scomoda fascia toracica.',22,1,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Ticwatch E Shadow','TicWatch E Shadow Smartwatch con display OLED da 1,4 pollici, Android Wear 2.0, Orologio sportivo Alta qualità Compatibile con Android e iOS Adatto per la maggior parte dei tipi di smartphone',22,2,0.6239697188057625,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Huawei Watch 2','Lorologio ha un grado di protezione IP68, il che significa che non garantisce la protezione dallimmersione in altri liquidi oltre allacqua limpida, ad es. birra, caffè, acqua salata e soda, acqua della piscina o acqua delloceano.',22,2,0.09032091629483596,55);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Samsung Gear Sport','Gear Sport è lo Sports Watch per tutti, da chi è a livello principiante a quello avanzato, per condurre uno stile di vita attivo e sviluppare sane abitudini alimentari. ',22,3,4.671686356788171,52);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tappi di sughero','Sugheri naturali non trattati derivanti dalla corteccia della quercia da sughero portoghese. Tutti i tappi di sughero hanno una sua venatura, non sono stati né sbiancati né schiariti in modo da dare risalto al look naturale del prodotto creativo',13,2,0.8683612899317872,37);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Manuale fai da te','Dai lavori in muratura allidraulica, dallelettricità alla falegnameria, dal bricolage in giardino alla manutenzione dellautomobile, tutto quello che bisogna sapere per eseguire alla perfezione, e in tutta sicurezza, gli interventi più diversi. ',13,1,2.4990847848841313,56);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pistola per colla a caldo','Blusmart ugello della pistola di colla un anello termoisolante plastica, mezzi a grilletto costruito avendo il controllo termico intelligente. Sicurezza spegne e il LED indicatori di stato, richiamo efficace che lo stato di carica e lugello può essere meglio sostituito nelle condizioni.',13,19,0.16613891022642546,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Feltro in fogli','Tronisky Feltro in Fogli, 40 Colori Feltro e Pannolenci Feltro Acrilico DIY Tessuto per Cucire Mestieri Stoffa di Cucito Bricolage Tessuto Patchwork 20*30cm',13,4,2.9141031719667443,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit strisce bricolage','Kit Composto Da 960 Strisce Di Carta Da 3/5 mm Kit Di Bricolage Artigianale Per Quilling Arte Per Filigrana Fai Da Té, Tavola, Stampo, Crimper e Pettine, Paper Width: 3mm',13,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set bricolage Mega','Rayher 69082000 Kit per lavoretti creativi, set bricolage, diversi materiali, Multicolore, 1200 pz. deale per creazioni con feltro, carta, piume, pompon, legno e tanto altro. Il set è completo per ogni appassionato di fai da te. Sono da acquistare a parte solo le forbici apposite.',13,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pom Pom Maker','Questo kit di creazione di pompom ha 4 formati per varie esigenze di progetto e di dimensioni nella progettazione e nella realizzazione di palline di lanugine.',13,3,0.5794426063578695,27);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cubetti legno 100pz','Materiale: Legno. Dimensione: ca. 2,5 x 2,5 x 2,5 cm / 1 x 1 x 1 pollici (L * W * H). 100pz di cubi in legno bianco per bricolage DIY e progetti artistici',13,4,3.977198260531891,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Winomo Fette Legno 10pz','Colore di legno. Materiale: legno di palissandro. Diametro: circa 7-9 cm. spessore: circa 1cm. Con lucidatura fine su entrambi i lati. Questi dischi di legno naturali sono circondati con corteccia.',13,1,1.4066826471450589,22);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Accessori craft per bambini','Craft Planet - Confezione di accessori per arti creative per bambini. Sacchetto di prodotti per lavori artigianali e artistici. Pratico e in plastica.',13,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spatola da giardino','Worth Garden Cazzuola è fatta per semplificare notevolmente il lavoro di giardinaggio. È ideale per scavare nel terreno più duro e rompere le zolle di terra indurite. ',16,1,2.498425085364958,33);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spruzzatore inniaffatore','Qualità, robustezza, funzionalità. Comoda anche la capacità di 2 lt (vasi di fiori su balcone)',16,1,4.99784187358875,102);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tubo flessibile a spruzzo','Tubo flessibile verde da 30 m, ideale per irrigare il giardino, lavare l’auto, pulire i mobili da giardino e svolgere altri lavoretti all’aria aperta.',16,4,2.5716503771944965,57);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Guanti antitaglio','I nostri guanti anti taglio non solo sono perfetti per luso in cucina, ma vanno bene anche per attività come la manipolazione o lavorazione di vetro, ferro e acciaio, per la meccanica, la meccatronica e molte altre. Questi guanti proteggeranno le tue mani da molti pericoli sul lavoro!',16,23,3.209635262207733,61);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Grembiule da giardino','Grembiule di durevole attrezzo di giardino verde oliva e kaki con tasche multifunzione, tra cui uno per il tuo cellulare. Dimensioni 48 x 58 cm',16,2,1.837355530295729,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Coltivatore AeroGarden','Lorto tutto lanno; coltiva erbe aromatiche fresche, verdure, insalate, fiori e altro nel tuo orto da interni intelligente',16,3,1.4102563239744692,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sacchi per rifiuti 3pz','Materiale: robusto e resistente tessuto in polipropilene (PP) Spessore 150g/m² *** Idrorepellente, delicato per la pelle, non inquinano la falda freatica.',16,1,2.7462010874879517,25);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Inceneritore da giardino','Dimensioni: 44 cm di lunghezza, 44 cm di larghezza e 64 cm di altezza. Si monta con facilità e senza bisogno di utensili.',16,4,0.8328553116304038,96);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit ortaggi insoliti','Tutto loccorrente in una confezione per coltivare 5 ortaggi stravaganti. Carote viola, cavoletto di Bruxelles rosso, pomodori striati, zucchine gialle e bietola a coste multicolore',16,3,1.3613800734454307,31);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cesoie Potatura Giardinaggio','GRÜNTEK Cesoie Potatura Giardinaggio GRIZZLY a Incudine 470mm Troncarami a cricchetto. Due in uno: cesoie per il giardino e per potatura',16,1,1.1618751205225797,67);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Tavolozza per artisti','Autentica tavolozza fatta a mano di alta qualità artigianale in compensato impiallacciato stagionato, per mescolare olio o acrilico. Progettata per essere tenuta sul avambraccio con il pollice nel foro, le dita si appoggiano nella cavità che arriva fino al foro per il pollice e allestremità che curva intorno al gomito.',14,2,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set accessori dipinto','Royal & Langnickel - Set di accessori per dipingere con cavalletto, perfetto per gli artisti appassionati e gli studenti, adatto dai principianti ai professionisti e ideale per viaggiare',14,4,2.1220016634792382,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit pittura cavalletto','Un kit per artisti professionisti e hobbisti. Include 1 cavalletto, 1 tela da 20x30cm, 12 colori acrilici da 12ml, 2 pennelli, 2 spatole e 1 tavolozza',14,2,2.2728984981280065,16);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cavalletto in piedi','Malaga è il cavalletto per pittura da campagna telescopico e salvaspazio: 80 x 96 x 180 cm',14,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Arteza tubetti di colore','Confezione da 24 pezzi in tubetti singoli, organizzati in una pratica scatola che ti aiuterà a tenerli sempre in ordine e facilmente accessibili quando ne hai bisogno. Creati per lutilizzo su tela, ottengono ottimi risultati anche su superfici diverse come il legno',14,1,4.116164457760344,78);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set colori acrilici','Set convenzienza di colori acrilici 120ml. Kit da 10 tubetti di colore acrilico serie Crylic di Artina - colori brillanti e alta densità di pigmenti colore per un risultato professisonale - per uso artistico',14,3,0.7604595894338206,84);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set di pennelli assortiti','Set assortito di  – appositamente studiato per la massima versatilità e facilità d’uso, questo set di pennelli è perfetto per i colori acrilici, ma può essere usato anche per gli acquerelli e i colori a olio.',14,4,0.1439109953588824,41);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Manuale di pittura','Un manifesto e un manuale insostituibile e da sfogliare, leggere, studiare ogni giorno per migliorare nel mondo della pittura e della colorazione.',14,4,2.8736243630801415,94);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Spatoline e raschietti','Set di cinque spatole per tavolozze con pittura ad olio. Materiale: spatole in acciaio INOX con manico in legno.',14,1,3.4766425664050473,14);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gesso acrilico 1L','Appretto bianco per la preparazione di supporti per dipingere. viscosità e concentrazione di bianco di titanio lo rendono particolarmente coprente. applicare su superfici pulite e non grasse. essicca rapidamente e presenta una superficie leggermente mat, che migliora lancoraggio degli strati di pittura acrilica e a olio.',14,16,3.578159604231784,102);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cacciavite Torx a punta quadrata','Wiha Classic cacciavite si può usare al giorno in unampia gamma di applicazioni.È universale, antimacchia e ha una superficie e un manico facile da pulire',15,4,4.397812032526774,23);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set di cacciaviti ad angolo','DOTAZIONE: T5 | T6 | T7 | T8 | T9 | T10 | T15 | T20 | T25 | T27 | T30 | T40 | T50. TORX - loriginale. Il marchio TORX è sinonimo di qualità e servizio clienti come lo specialista interno per chiave ad esagono incassato e viti',15,4,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('RevolutionAIR Compressore','Portatile e leggero. Adatto per gonfiare e per operazioni di soffiaggio. Ideale per soffiare, pulire, gonfiare, dipingere',15,10,1.9866122742535008,72);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pinze regolabili per tubi e dadi','WORKPRO Pinze Regolabili resistenti e durevoli con gli esami di tempo e pratica, lunghezza da 250mm e 200mm con l’apertura pratica massimo al 70mm e 60mm assicurando la presa solida e il serraggio forte',15,2,1.5129143427378988,103);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Chiavi a cricchetto','La valigetta del set da 130 pezzi di chiavi a bussola del marchio Brüder Mannesmann Werkzeuge è il partner ideale per molteplici lavori di avvitamento su macchina, moto, bicicletta e per ogni ambito della casa.',15,2,3.6697758975148007,35);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Martello demolitore','Il martello tassellatore TH-RH 1600 è l’assistente degli appassionati di fai-da-te per lavori di foratura, apertura di fori e smantellamento. Con quattro funzioni: tassellatura, foratura e scalpellatura con e senza fissaggio dello scalpello',15,3,0,0);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Avvitatore elettrico tacklife','acklife SDH13DC Cacciavite elettrico Senza Fili, un design ergonomico, leggero e pratico, conveniente da trasportare.',15,4,2.9233866145784146,15);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Smerigliatrice angolare','Carcassa motore con dimensioni ridotte, circonferenza di soli 180mm. Coppia conica ottenuta per fresatura dal pieno. Motore con resistenza al calore maggiorata e di alte prestazioni',15,3,0.059630314805321216,79);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Sega a batteria','Bosch Microsega NanoBlade EasyCut 12 tagliare non è mai stato così semplice. Un compatto e maneggevole utensile a batteria per eseguire tagli con facilità e senza vibrazioni, dentro e fuori casa',15,1,3.947599330306917,89);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Pinza spelafili','Ideale per spellare filo da 10-24 AWG (0,2-6mm2). Con una manopola girevole micro-regolabile in rame, puoi regolare il tappo per tagliare la lunghezza desiderata del filo centrale. Inoltre, lo spelafili non danneggia i singoli fili',15,11,4.466933122600772,100);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Cerniere invisibili per cucito','18cm per nascondere cerniere in nylon trasparente per il cucito. Il colore del prodotto è casuale e cambia da confezione a confezione.',17,6,3.9269726248366297,63);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Macchina per cucire elettrica','Macchina da cucire robusta, compatta e portatile ideale per professionisti. L’innovativo display LCD permette di visualizzare la velocità standard del punto selezionato',17,4,1.0043356818176274,17);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Set 10 filati in poliestere','Cuciture perfette: con questo set da 10 tipi di filo nei colori bianco, nero, beige, blu, marrone, arancione, giallo, grigio, verde e rosso, otterrete risultati ottimali, sia cucendo a mano che con la macchina da cucire',17,2,3.0456834047382584,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Forbici sarto e cucito','Forbici per sartoria, tagliatutto: per cucito e lavoro. In acciaio temperato, con lama nichelata - Ultra resistenti. Lunghezza totale 20cm',17,3,3.5434037718490896,74);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Scatola da cucito','Portagioie, kit da cucito, bottoni... 36 x 22 x 17,5 cm (36 x 22 x 27 con manico). Dispone di 5 scomparti separati: 4 in alto e 1 più grande nella parte inferiore.',17,13,2.1068236514335004,46);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Gesso da sarto','Matita meccanica in plastica. 6 gessetti francesi da 3,8mm per disegnare su tessuto. 22cm e colori assortiti, 1 Confezioni',17,2,4.482001004664943,65);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Manuale di sartoria','Manuale di satoria per principianti di edizioe Il Castello. Tratta di cucito, ricamo, tessitoria e tantissime altre cose interessanti, che insegneranno a diventare esperti nel mondo della moda e del cucito.',17,25,0.5332621281586636,64);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Kit cucito da casa','Il pacchetto include: 12 x filo da cucito, 16 x, 4 x bottoni, ditale, metro a nastro, spille di sicurezza, forbici, ago, filo Cutter, perla e infila. Materiali di alta qualità: Kit perfetto per Expert fogne o principianti',17,2,2.4998187440929334,85);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Infilago elettrico','Un ottimo strumento per aiutare a filo più facilmente la macchina da cucire ago. Adatto per cucire a mano o a macchina.Uno strumento utile per il vecchio che ha paziente facendo cucire.',17,2,4.702110758758855,82);
INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR, RATING, NUM_VOTES) VALUES ('Aghi 6pz per perline','Cruna dellago misura: questo insieme di aghi occhio ha 3 lunghezze, 4,5 cm/ 1,8 pollici, 5,5 cm/ 2,2 pollici e da 7,6 cm/ 3 pollici, lunghezze differenti possono soddisfare le diverse esigenze',17,1,1.3036103627449547,80);




INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 1','desc',1,15);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 2','desc',1,25);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 3','desc',1,8);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 4','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 5','desc',1,30);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 6','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 7','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 8','desc',1,15);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 9','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 10','desc',1,27);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 11','desc',1,10);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 12','desc',1,15);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 13','desc',1,14);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 14','desc',1,30);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 15','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 16','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 17','desc',1,6);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 18','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 19','desc',1,24);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 20','desc',1,7);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 21','desc',1,17);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 22','desc',1,5);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 23','desc',1,14);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 24','desc',1,25);
INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) VALUES ('List 25','desc',1,19);




INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,12,16,0,'2019-01-31 19:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,30,3,0,'2019-01-31 18:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,2,11,0,'2019-01-31 14:07:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,6,10,6,'2019-02-01 00:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,49,7,7,'2019-02-01 01:00:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (1,46,17,17,'2019-02-01 00:07:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,3,18,6,'2019-02-01 03:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,43,8,7,'2019-01-31 19:02:09');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,18,3,2,'2019-02-01 02:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (2,24,5,0,'2019-01-31 23:26:38');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,15,8,4,'2019-01-31 21:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,47,14,0,'2019-01-31 23:15:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,40,9,0,'2019-02-01 01:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,17,2,2,'2019-02-01 06:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (3,35,5,0,'2019-02-01 01:07:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,13,15,4,'2019-02-01 01:13:40');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,14,19,19,'2019-02-01 04:02:09');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,21,4,1,'2019-02-01 01:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,19,10,3,'2019-02-01 05:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,29,16,16,'2019-01-31 18:00:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (4,41,12,7,'2019-01-31 19:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,22,2,0,'2019-01-31 18:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,37,10,5,'2019-01-31 20:16:33');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,36,20,0,'2019-01-31 18:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,48,5,5,'2019-02-01 01:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (5,42,9,0,'2019-01-31 12:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,31,3,1,'2019-02-01 01:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,25,8,0,'2019-02-01 04:10:47');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,28,16,0,'2019-02-01 00:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,48,18,17,'2019-02-01 02:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,41,1,1,'2019-02-01 02:13:40');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (6,20,20,13,'2019-02-01 05:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,42,5,0,'2019-01-31 23:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,38,7,0,'2019-01-31 23:07:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,51,4,4,'2019-02-01 04:26:38');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (7,30,18,8,'2019-02-01 05:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,18,10,0,'2019-01-31 18:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,24,17,17,'2019-01-31 14:03:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,48,16,5,'2019-01-31 22:03:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (8,5,16,2,'2019-01-31 21:15:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,1,13,13,'2019-01-31 20:03:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,8,8,0,'2019-02-01 00:26:38');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,21,11,9,'2019-02-01 01:13:40');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,47,20,15,'2019-01-31 14:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (9,23,11,11,'2019-01-31 19:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,49,17,17,'2019-01-31 19:15:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,23,4,0,'2019-01-31 14:03:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,31,12,0,'2019-01-31 22:16:33');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,17,3,1,'2019-01-31 23:06:28');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (10,44,3,0,'2019-01-31 18:25:11');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,32,18,0,'2019-01-31 23:10:47');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,46,14,14,'2019-02-01 03:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,45,16,16,'2019-01-31 15:16:33');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,43,3,3,'2019-01-31 16:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,23,8,8,'2019-02-01 07:15:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (11,24,10,10,'2019-01-31 15:13:40');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,38,10,1,'2019-01-31 23:26:38');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,14,18,18,'2019-01-31 19:19:26');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,22,13,13,'2019-02-01 02:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,37,15,15,'2019-01-31 20:26:38');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (12,34,15,15,'2019-02-01 07:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,9,9,6,'2019-01-31 15:02:09');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,12,19,0,'2019-01-31 23:07:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,7,5,5,'2019-01-31 21:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,1,9,5,'2019-01-31 11:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (13,8,6,0,'2019-01-31 13:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,10,18,17,'2019-01-31 16:25:11');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,52,9,9,'2019-02-01 02:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,38,12,9,'2019-02-01 03:02:09');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (14,1,16,0,'2019-01-31 15:00:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,25,5,0,'2019-02-01 04:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,18,12,11,'2019-02-01 02:06:28');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,5,11,0,'2019-02-01 06:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,6,6,0,'2019-02-01 03:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (15,22,7,0,'2019-02-01 04:10:47');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,48,14,0,'2019-01-31 15:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,12,16,16,'2019-02-01 01:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,27,9,7,'2019-01-31 22:16:33');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,42,12,0,'2019-02-01 02:06:28');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (16,26,4,2,'2019-02-01 00:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,6,11,0,'2019-01-31 17:07:54');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,7,13,12,'2019-01-31 20:13:40');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,27,1,0,'2019-01-31 19:03:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (17,52,12,12,'2019-02-01 01:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,42,19,0,'2019-02-01 01:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,14,11,0,'2019-02-01 01:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,54,5,5,'2019-01-31 18:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (18,39,4,3,'2019-01-31 18:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,23,19,19,'2019-02-01 02:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,35,11,11,'2019-02-01 00:06:28');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,54,11,7,'2019-01-31 21:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,48,17,0,'2019-01-31 21:23:45');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,20,6,0,'2019-01-31 18:19:26');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (19,51,8,2,'2019-01-31 15:25:11');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,35,6,6,'2019-02-01 02:00:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,12,17,0,'2019-02-01 06:02:09');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,14,20,20,'2019-01-31 18:16:33');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (20,45,3,0,'2019-01-31 23:06:28');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,31,17,1,'2019-02-01 05:19:26');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,26,5,0,'2019-02-01 07:00:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,30,1,1,'2019-01-31 13:02:09');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (21,7,5,0,'2019-02-01 00:13:40');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,27,19,19,'2019-01-31 19:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,43,5,0,'2019-02-01 01:03:35');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,40,3,2,'2019-01-31 18:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,37,18,0,'2019-02-01 03:06:28');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,49,5,0,'2019-01-31 12:00:42');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (22,46,20,0,'2019-01-31 13:17:59');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,54,13,11,'2019-02-01 03:09:21');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,24,3,3,'2019-02-01 04:25:11');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,29,15,15,'2019-02-01 02:26:38');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,26,16,16,'2019-02-01 04:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (23,44,17,14,'2019-02-01 01:05:02');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,40,7,7,'2019-01-31 22:15:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,20,3,0,'2019-01-31 22:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,22,4,2,'2019-01-31 19:59:16');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,52,19,0,'2019-02-01 04:12:14');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (24,4,14,0,'2019-02-01 00:20:52');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,31,6,0,'2019-02-01 00:15:06');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,52,20,0,'2019-01-31 19:25:11');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,9,15,8,'2019-02-01 04:10:47');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,11,13,0,'2019-01-31 18:22:18');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,32,3,1,'2019-01-31 20:20:52');
INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,TOTAL,PURCHASED,LAST_PURCHASE) VALUES (25,24,15,0,'2019-02-01 02:05:02');




INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (1,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (2,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,15,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,22,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (3,20,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,9,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (4,10,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,6,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,27,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,29,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,25,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,24,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (5,19,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,22,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,11,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,6,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,8,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (6,13,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,17,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,28,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,26,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (7,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (8,13,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,28,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (9,15,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,23,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,19,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,11,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,21,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,17,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (11,13,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,19,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (12,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (13,27,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (14,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,16,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,10,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (17,14,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,11,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,17,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,23,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (18,21,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,8,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,7,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,12,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,16,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,21,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,5,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (19,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,27,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,16,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,29,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,18,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,15,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (20,10,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (21,25,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (22,13,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,29,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (23,22,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,20,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,5,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,15,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,8,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,18,0);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,9,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,10,2);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,12,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (24,14,1);
INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) VALUES (25,10,1);




INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'Cè bisogno di altro?','2019-01-31 10:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'Non penso ci serva altro','2019-01-31 22:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,15,'No','2019-01-31 07:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,5,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 17:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,15,'Speriamo basti tutto questo','2019-01-31 10:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (1,15,'Sì','2019-01-31 19:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,18,'Vorrei comprare anche un martello demolitore','2019-01-31 18:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,5,'My names Jeff','2019-01-31 16:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (2,5,'My names Jeff','2019-01-31 09:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,10,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 12:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,8,'Non cè bisogno daltro','2019-01-31 09:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,10,'Sì','2019-01-31 03:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (3,17,'Vorrei comprare anche un martello demolitore','2019-02-01 02:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,6,'Non vedo lora arrivi la grigliata','2019-01-31 08:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,6,'Hai bisogno di altro?','2019-01-31 15:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,24,'No','2019-01-31 19:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,19,'Sì','2019-02-01 01:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,10,'Decisamente!','2019-01-31 18:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,9,'Anche qualche mela magari','2019-01-31 04:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,6,'Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 23:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,10,'Sono intollerante al lattosio, cè altro?','2019-01-31 18:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (4,6,'Non vedo lora arrivi la grigliata','2019-01-31 13:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,30,'Grazie per avermelo ricordato','2019-01-31 19:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,22,'No','2019-01-31 09:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,22,'Non ho voglia di cioccolato, tu?','2019-01-31 11:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (5,14,'Non vedo lora arrivi la grigliata','2019-01-31 04:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,14,'Ne abbiamo abbastanza?','2019-01-31 11:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,12,'Ragazzi la festa è domani!!','2019-01-31 23:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,11,'Ne abbiamo abbastanza?','2019-01-31 04:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,12,'Non ho voglia di cioccolato, tu?','2019-01-31 08:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (6,22,'Non ho voglia di cioccolato, tu?','2019-01-31 22:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,27,'Non saprei...','2019-01-31 11:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,26,'My names Jeff','2019-01-31 08:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,27,'Non ricordo esattamente la lista','2019-01-31 03:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,10,'Non ho voglia di cioccolato, tu?','2019-01-31 09:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Non lavevo considerato, in effetti','2019-01-31 21:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,5,'Un po di pasta...','2019-01-31 08:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,28,'','2019-01-31 23:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,21,'Solo cose biologiche','2019-01-31 05:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,26,'Speriamo basti tutto questo','2019-01-31 14:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,10,'Non penso ci serva altro','2019-01-31 17:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (7,27,'Ne abbiamo abbastanza?','2019-01-31 08:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,13,'Vorrei comprare anche un martello demolitore','2019-01-31 05:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,15,'Non penso ci serva altro','2019-01-31 18:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,21,'Sto andando a fare la spesa, manca qualcosa?','2019-01-31 09:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (8,15,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 03:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,5,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 14:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (9,15,'Solo cose biologiche','2019-01-31 11:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'Non ricordo esattamente la lista','2019-02-01 00:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'Cosa ci serve?','2019-01-31 23:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'Non saprei...','2019-01-31 08:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'','2019-01-31 23:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'Prendine il doppio','2019-01-31 10:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'Anche qualche mela magari','2019-01-31 17:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (10,27,'Cosa ci serve?','2019-02-01 01:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,21,'Prendine il doppio','2019-02-01 01:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,13,'Non ricordo esattamente la lista','2019-01-31 04:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,14,'Non ricordo esattamente la lista','2019-01-31 04:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,17,'Sono intollerante al lattosio, cè altro?','2019-01-31 19:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,19,'Non penso ci serva altro','2019-01-31 16:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,14,'Naturalmente','2019-02-01 00:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (11,19,'Naturalmente','2019-01-31 22:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,15,'','2019-01-31 04:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,19,'Solo cose biologiche','2019-01-31 06:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,19,'Devo pensare anche alle intolleranze','2019-01-31 21:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,18,'Non saprei...','2019-01-31 22:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (12,15,'Non me lo ricordavo!','2019-01-31 21:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,27,'','2019-01-31 05:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Non lavevo considerato, in effetti','2019-01-31 21:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Non vedo lora arrivi la grigliata','2019-01-31 14:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Sto andando a fare la spesa, manca qualcosa?','2019-01-31 16:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Speriamo basti tutto questo','2019-02-01 00:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Non lavevo considerato, in effetti','2019-01-31 05:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,14,'Cè bisogno di altro?','2019-01-31 23:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,27,'My names Jeff','2019-02-01 00:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,27,'Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 19:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (13,27,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 03:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,30,'Ci serve qualcosa per il pranzo al sacco','2019-01-31 23:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,18,'Speriamo basti tutto questo','2019-01-31 17:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,18,'Non cè bisogno daltro','2019-01-31 21:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,18,'','2019-01-31 04:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,21,'Sto andando a fare la spesa, manca qualcosa?','2019-01-31 14:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,30,'Non ricordo esattamente la lista','2019-01-31 23:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,21,'Ne abbiamo abbastanza?','2019-01-31 17:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,18,'Non vedo lora arrivi la grigliata','2019-01-31 12:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,30,'Non ho voglia di cioccolato, tu?','2019-01-31 09:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,18,'Prendine il doppio','2019-01-31 08:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (14,18,'Cè bisogno di altro?','2019-01-31 05:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Prendine il doppio','2019-01-31 08:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Prendine il doppio','2019-02-01 02:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Sono intollerante al lattosio, cè altro?','2019-01-31 03:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (15,5,'Sì','2019-01-31 18:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Non me lo ricordavo!','2019-01-31 22:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 09:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Grazie per avermelo ricordato','2019-02-01 00:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Un po di pasta...','2019-01-31 04:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Non me lo ricordavo!','2019-01-31 08:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Non ricordo esattamente la lista','2019-01-31 11:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 18:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Devo pensare anche alle intolleranze','2019-01-31 14:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'Hai bisogno di altro?','2019-01-31 05:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (16,5,'','2019-01-31 04:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,6,'My names Jeff','2019-01-31 18:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,10,'Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 06:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,14,'Hai bisogno di altro?','2019-01-31 22:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,10,'Prendine il doppio','2019-02-01 02:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,16,'Hai bisogno di altro?','2019-01-31 05:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,14,'Hai bisogno di altro?','2019-01-31 10:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,10,'Solo cose biologiche','2019-01-31 14:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (17,14,'Non cè bisogno daltro','2019-01-31 10:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,29,'Non me lo ricordavo!','2019-01-31 13:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,11,'Ne abbiamo abbastanza?','2019-01-31 03:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,11,'Sono intollerante al lattosio, cè altro?','2019-01-31 21:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,23,'Non vedo lora arrivi la grigliata','2019-01-31 13:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,23,'No','2019-01-31 15:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (18,8,'Non dovrebbe servirci altro','2019-01-31 12:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,5,'Non ho voglia di cioccolato, tu?','2019-01-31 15:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,21,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 19:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,16,'Un po di pasta...','2019-01-31 04:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,7,'Sì','2019-01-31 16:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,8,'Non vedo lora arrivi la grigliata','2019-01-31 17:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,27,'Un po di pasta...','2019-01-31 12:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (19,21,'Non cè bisogno daltro','2019-01-31 11:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,15,'Non saprei...','2019-01-31 22:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,29,'Non dovrebbe servirci altro','2019-01-31 08:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,18,'Prendine il doppio','2019-01-31 19:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,10,'Non ricordo esattamente la lista','2019-01-31 12:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,10,'Sì','2019-01-31 18:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,16,'Un po di pasta...','2019-01-31 15:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,15,'Non me lo ricordavo!','2019-01-31 10:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (20,29,'Non ricordo esattamente la lista','2019-01-31 04:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,17,'Domani facciamo il picnic, quindi cosa prendiamo?','2019-01-31 12:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (21,17,'Grazie per avermelo ricordato','2019-01-31 14:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Non ricordo esattamente la lista','2019-01-31 15:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,13,'Non saprei...','2019-01-31 19:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Non lavevo considerato, in effetti','2019-01-31 22:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Ragazzi la festa è domani!!','2019-01-31 08:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,13,'Solo cose biologiche','2019-01-31 04:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Grazie per avermelo ricordato','2019-01-31 16:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (22,5,'Sono intollerante al lattosio, cè altro?','2019-02-01 00:26:37');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,22,'','2019-01-31 17:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,29,'Naturalmente','2019-01-31 16:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,22,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 13:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,29,'Prendiamo anche un po di cose per il bricolage?','2019-01-31 19:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (23,29,'Naturalmente','2019-01-31 07:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,20,'Hai bisogno di altro?','2019-01-31 10:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (24,15,'Non penso ci serva altro','2019-01-31 22:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'My names Jeff','2019-01-31 17:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'Decisamente!','2019-01-31 13:23:44');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,10,'Hai bisogno di altro?','2019-01-31 16:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'Spero tu abbia a mente cosa ci serve','2019-01-31 13:25:11');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,19,'Non saprei...','2019-02-01 01:28:03');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,10,'Cè bisogno di altro?','2019-01-31 17:22:18');
INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) VALUES (25,10,'No','2019-01-31 22:28:03');




INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,21,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,14,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,12,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,6,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(1,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,24,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(2,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,25,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(3,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,16,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(4,15,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,9,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(5,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(7,15,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,22,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,4,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(8,6,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,24,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,20,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(9,7,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,14,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,26,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(10,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,6,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,25,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(11,27,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,5,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,24,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,22,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(12,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,12,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(13,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,17,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,28,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,15,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,12,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(14,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,24,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,10,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,11,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,11,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(15,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,23,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,20,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,15,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,15,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,21,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(16,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,9,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,11,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,27,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,4,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,23,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(17,5,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,14,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(18,22,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,26,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(19,19,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,17,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,13,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(20,5,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,10,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,23,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,7,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,9,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,11,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(21,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,8,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,14,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,28,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,20,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,18,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(22,19,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,17,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,27,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(24,13,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,8,0);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,23,1);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,16,2);
INSERT INTO APP.INVITES (LIST,INVITED,ACCESS) VALUES(25,5,2);




