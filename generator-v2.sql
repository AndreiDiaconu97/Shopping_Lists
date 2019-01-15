CREATE TABLE APP.LISTS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL,
	OWNER INTEGER NOT NULL,
	LOGO VARCHAR(100),
	PRIMARY KEY (ID),
	UNIQUE (NAME, CATEGORY, OWNER)
);

CREATE TABLE APP.LISTS_ANONYMOUS (
	ID VARCHAR(100) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL,
	LOGO VARCHAR(100),
	LAST_SEEN TIMESTAMP NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE APP.LISTS_ANONYMOUS_PRODUCTS (
	LIST_ANONYMOUS VARCHAR(100) NOT NULL,
	PRODUCT INTEGER NOT NULL,
	PURCHASED BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY (LIST_ANONYMOUS,PRODUCT)
);

CREATE TABLE APP.LISTS_CATEGORIES (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000) NOT NULL,
	LOGO VARCHAR(100),
	PRIMARY KEY (ID),
	UNIQUE (NAME)
);

CREATE TABLE APP.LISTS_PRODUCTS (
	LIST INTEGER NOT NULL,
	PRODUCT INTEGER NOT NULL,
	AMOUNT INTEGER NOT NULL DEFAULT 1,
	CONSTRAINT amount_ck CHECK(AMOUNT >= 1),
	PURCHASED INTEGER NOT NULL DEFAULT 0,
	CONSTRAINT purchased_ck CHECK(PURCHASED <= AMOUNT),
	PRIMARY KEY (LIST,PRODUCT)
);

CREATE TABLE APP.LISTS_SHARING (
	LIST INTEGER NOT NULL,
	"USER" INTEGER NOT NULL,
	ACCESS INTEGER NOT NULL DEFAULT 0,
	CONSTRAINT access_ck CHECK (ACCESS IN (0, 1, 2)), -- (read, add/rm prods, full(rename, delete, etc))
	PRIMARY KEY (LIST,"USER")
);

CREATE TABLE APP.NV_USERS (
	EMAIL VARCHAR(100) NOT NULL,
	PASSWORD VARCHAR(64) NOT NULL,
	FIRSTNAME VARCHAR(100) NOT NULL,
	LASTNAME VARCHAR(100) NOT NULL,
	AVATAR VARCHAR(100),
	VERIFICATION_CODE VARCHAR(50) NOT NULL UNIQUE,
	PRIMARY KEY (EMAIL)
);

CREATE TABLE APP.PRODUCTS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000),
	CATEGORY INTEGER NOT NULL,
	CREATOR INTEGER NOT NULL,
	IS_PUBLIC BOOLEAN NOT NULL,
	LOGO VARCHAR(120),
	PHOTO VARCHAR(120),
	NUM_VOTES INTEGER NOT NULL DEFAULT 0,
	RATING REAL NOT NULL DEFAULT 0,
	PRIMARY KEY (ID),
	UNIQUE (NAME, CATEGORY, CREATOR)
);

CREATE TABLE APP.PRODUCTS_CATEGORIES (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(1000) NOT NULL,
	LOGO VARCHAR(100),
	PRIMARY KEY (ID),
	UNIQUE (NAME)
);

CREATE TABLE APP.LISTS_PRODUCTS_CATEGORIES (
	LIST_CAT INTEGER NOT NULL,
	PRODUCT_CAT INTEGER NOT NULL,
	UNIQUE (LIST_CAT, PRODUCT_CAT)
);

CREATE TABLE APP.USERS (
	ID INTEGER GENERATED ALWAYS AS IDENTITY(start with 1 increment by 1) NOT NULL,
	EMAIL VARCHAR(100) NOT NULL UNIQUE,
	PASSWORD VARCHAR(64) NOT NULL,
	FIRSTNAME VARCHAR(100) NOT NULL,
	LASTNAME VARCHAR(100) NOT NULL,
	IS_ADMIN BOOLEAN DEFAULT FALSE NOT NULL,
	AVATAR VARCHAR(100),
	PRIMARY KEY (ID)
);

CREATE TABLE APP.CHATS (
	LIST INTEGER NOT NULL,
	"USER" INTEGER NOT NULL,
	"TIME" TIMESTAMP NOT NULL,
	MESSAGE VARCHAR(500)
);


-- lists and products can be deleted
-- categories cannot be deleted
-- users cannot be deleted
--

ALTER TABLE APP.LISTS ADD FOREIGN KEY (CATEGORY) REFERENCES APP.LISTS_CATEGORIES (ID);
ALTER TABLE APP.LISTS ADD FOREIGN KEY (OWNER) REFERENCES APP.USERS (ID);

ALTER TABLE APP.LISTS_ANONYMOUS ADD FOREIGN KEY (CATEGORY) REFERENCES APP.LISTS_CATEGORIES (ID);

ALTER TABLE APP.LISTS_ANONYMOUS_PRODUCTS ADD FOREIGN KEY (LIST_ANONYMOUS) REFERENCES APP.LISTS_ANONYMOUS (ID) ON DELETE CASCADE;
ALTER TABLE APP.LISTS_ANONYMOUS_PRODUCTS ADD FOREIGN KEY (PRODUCT) REFERENCES APP.PRODUCTS (ID) ON DELETE CASCADE;

ALTER TABLE APP.LISTS_PRODUCTS ADD FOREIGN KEY (LIST) REFERENCES APP.LISTS (ID) ON DELETE CASCADE;
ALTER TABLE APP.LISTS_PRODUCTS ADD FOREIGN KEY (PRODUCT) REFERENCES APP.PRODUCTS (ID) ON DELETE CASCADE;

ALTER TABLE APP.LISTS_SHARING ADD FOREIGN KEY (LIST) REFERENCES APP.LISTS (ID) ON DELETE CASCADE;
ALTER TABLE APP.LISTS_SHARING ADD FOREIGN KEY ("USER") REFERENCES APP.USERS (ID);

ALTER TABLE APP.PRODUCTS ADD FOREIGN KEY (CATEGORY) REFERENCES APP.PRODUCTS_CATEGORIES (ID);
ALTER TABLE APP.PRODUCTS ADD FOREIGN KEY (CREATOR) REFERENCES APP.USERS (ID);

ALTER TABLE APP.LISTS_PRODUCTS_CATEGORIES ADD FOREIGN KEY (LIST_CAT) REFERENCES APP.LISTS_CATEGORIES (ID);
ALTER TABLE APP.LISTS_PRODUCTS_CATEGORIES ADD FOREIGN KEY (PRODUCT_CAT) REFERENCES APP.PRODUCTS_CATEGORIES (ID);

ALTER TABLE APP.CHATS ADD FOREIGN KEY (LIST) REFERENCES APP.LISTS (ID) ON DELETE CASCADE;
ALTER TABLE APP.CHATS ADD FOREIGN KEY ("USER") REFERENCES APP.USERS (ID);

