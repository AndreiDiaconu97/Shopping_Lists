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
	AMOUNT INTEGER NOT NULL DEFAULT 1,
	PURCHASED INTEGER NOT NULL DEFAULT 0,
	LAST_PURCHASE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT lists_products__amount CHECK(AMOUNT >= 1),
	CONSTRAINT lists_products__purchased CHECK(PURCHASED <= AMOUNT),
	PRIMARY KEY (LIST,PRODUCT)
);

CREATE TABLE APP.LISTS_ANONYMOUS_PRODUCTS (
	LIST_ANONYMOUS VARCHAR(100) NOT NULL CONSTRAINT lists_anonymous_products__list_anonymous REFERENCES APP.LISTS_ANONYMOUS (ID) ON DELETE CASCADE,
	PRODUCT INTEGER NOT NULL CONSTRAINT lists_anonymous_products__product REFERENCES APP.PRODUCTS (ID) ON DELETE CASCADE,
	AMOUNT INTEGER NOT NULL DEFAULT 1,
	PURCHASED INTEGER NOT NULL DEFAULT 0,
	LAST_PURCHASE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT lists_anonymous_products__amount CHECK(AMOUNT >= 1),
	CONSTRAINT lists_anonymous_products__purchased CHECK(PURCHASED <= AMOUNT),
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
