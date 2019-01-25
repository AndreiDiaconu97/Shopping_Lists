const XLSX = require('xlsx');
const bcrypt = require('bcrypt');
const fs = require('fs');

const saltRounds = 10;
const possible_messages = [
	"Sì",
	"No",
	"Sto andando a fare la spesa",
	"Buongiornissimo kkafffèèè ?!?? :))"
];
const hour = 1000 * 3600;
const day = 3600 * 24;

Array.prototype.unique = function () {
	var a = this.concat();
	for (var i = 0; i < a.length; ++i) {
		for (var j = i + 1; j < a.length; ++j) {
			if (a[i] === a[j])
				a.splice(j--, 1);
		}
	}
	return a;
};

Array.prototype.randomItem = function () {
	return this[Math.floor(Math.random() * this.length)];
};

let book = XLSX.readFile('Database ShoppingList.xlsx');

let names = ["michele", "matteo", "giovanni", "anna", "fabrizia", "gianmaria", "mattea", "dora"];
let lastnames = ["bini", "trump", "amadori", "castellaneta", "chiocco", "toldo"];
let domains = ["@gmail.com", "@yahoo.it", "@alice.it", "@hotmail.com"];
const TOT_USERS = 20;
let users = [];
for (let i = 4; i < TOT_USERS; i++) {
	let firstname = names.randomItem();
	let lastname = lastnames.randomItem();
	let domain = domains.randomItem();
	let password = '$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS';//bcrypt.hashSync("1234", saltRounds);
	users.push({ email: firstname + '.' + lastname + i + domain, firstname, lastname, password, is_admin: false });
}

//console.log(users);



let sheet_cat = XLSX.utils.sheet_to_json(book.Sheets[book.SheetNames[0]]);

// load list_cats and prod_cats
let list_cats = sheet_cat.map(x => {
	let i = 1;
	let c = 'cat. ' + i;
	let r = [];
	while (x[c]) {
		r.push([x[c], x['rinnovo ' + i] || 0]);
		i++;
		c = 'cat. ' + i;
	}
	return { l_c: x['Cat liste'], p_c: r };
});
let prod_cats = list_cats.map(x => x.p_c).reduce((acc, v) => acc.concat(v)).unique();
list_cats = list_cats.map(x => {
	x.p_c = x.p_c.map(i => prod_cats.findIndex(z => z == i));
	return x;
});
//console.log(list_cats);
//console.log(prod_cats);


let sheet_prods = XLSX.utils.sheet_to_json(book.Sheets[book.SheetNames[1]]);
let prods = sheet_prods.map(function (x) {
	return {
		Name: x.Name,
		Category: (prod_cats.findIndex(p_cat => x['Cat prodotto'] == p_cat[0])),
		Description: x.Description,
		Creator: Math.random() > 0.2 ? [0, 1, 2, 3].randomItem() : Math.floor(Math.random() * (TOT_USERS / 2))
	};
}).filter(x => x.Name && x.Description);

//console.log(prods);



// LISTEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
let lists = [];
let TOT_LISTS = 20;
let min_items = 4, max_items = 7;//20;
for (let i = 1; i <= TOT_LISTS; i++) {
	let l_cat = 0;//list_cats.indexOf(list_cats.randomItem());
	let n_items = Math.floor(Math.random() * (max_items - min_items)) + min_items;
	let items = [];

	while (items.length < n_items) {
		let p_cat = list_cats[l_cat].p_c.randomItem();
		let item = (prods.filter(x => x['Category'] == p_cat));
		if (item.length > 0) {
			item = prods.indexOf(item.randomItem());
			items.push(item);
			items = items.unique();
		}
	}
	let owner = Math.floor(Math.random() * (TOT_USERS / 2)) + 4;
	let shared = [];
	for (let s = 0; s < 5; s++) {
		let sh = Math.random() > 0.6 ? [4, 5].randomItem() : Math.floor(Math.random() * (TOT_USERS / 2));
		if (sh != s) shared.push(sh);
	}
	let msgs = [];
	let msg_am = 2 + Math.floor(Math.random() * 10);
	for (let s = 0; s < msg_am; s++) {
		msgs.push({
			list: i,
			user: shared.concat(owner).randomItem(),
			text: possible_messages.randomItem(),
			time: (new Date()) - day * Math.floor(Math.random() * 5) - hour * Math.floor(Math.random() * 24)
		});
	}
	lists.push({
		Id: i,
		Name: "list" + i,
		Category: l_cat,
		Description: "desc",
		Products: items,
		Owner: owner,
		SharedWith: shared.unique(),
		Messages: msgs
	});
}

//console.log(lists);





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const filename = "../../../../generatedDB.sql";

try {
	fs.unlinkSync(filename);
} catch (error) {
	console.log('Cannot delete, maybe not present\n');
}
fs.writeFileSync(filename, fs.readFileSync("../../../../structure.sql"));


let query = `
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrea.matte@studenti.unitn.it', '$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS', 'andrea', 'matto', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrei.diaconu@studenti.unitn.it', '$2a$10$bek3pnCbDuA7YfLXHDpVi./CPITBTv.nPud1Q63WukdgtKsrr.NCe', 'andrei', 'kontorto', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('andrea.iossa@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'andrea', 'ioza', true);
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('edoardo.meneghini@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'edoardo', 'meneghini', true);\n
INSERT INTO APP.USERS(EMAIL, PASSWORD, FIRSTNAME, LASTNAME, IS_ADMIN) VALUES('matteo.bini@studenti.unitn.it', '$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y', 'matteo', 'bini', false);\n
`;
for (u of users) {
	query += `INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN) `;
	query += `VALUES ('${u.email}','${u.password}','${u.firstname.replace(/['"]+/g, '')}','${u.lastname.replace(/['"]+/g, '')}',FALSE);\n`;
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (p_c of prod_cats) {
	query += `INSERT INTO APP.PRODUCTS_CATEGORIES ("NAME", DESCRIPTION, RENEW_TIME) `;
	query += `VALUES ('${p_c[0].replace(/['"]+/g, '')}','desc',${p_c[1]});\n`;
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (l_c of list_cats) {
	query += `INSERT INTO APP.LISTS_CATEGORIES ("NAME", DESCRIPTION) `;
	query += `VALUES ('${l_c.l_c.replace(/['"]+/g, '')}','desc');\n`;
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (l_c of list_cats) {
	for (p_c of l_c.p_c) {
		query += `INSERT INTO APP.LISTS_PRODUCTS_CATEGORIES (LIST_CAT,PRODUCT_CAT) `;
		query += `VALUES (${list_cats.indexOf(l_c) + 1},${p_c + 1});\n`; // +1 essential for [0, 1, 2] => [1, 2, 3]
	}
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (p of prods) {
	query += `INSERT INTO APP.PRODUCTS ("NAME", DESCRIPTION, CATEGORY, CREATOR) `;
	query += `VALUES ('${p.Name.replace(/['"]+/g, '')}','${p.Description.replace(/['"]+/g, '')}',${p.Category + 1},${p.Creator + 1});\n`;
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (l of lists) {
	query += `INSERT INTO APP.LISTS ("NAME", DESCRIPTION, CATEGORY, OWNER) `;
	query += `VALUES ('${l.Name.replace(/['"]+/g, '')}','${l.Description.replace(/['"]+/g, '')}',${l.Category + 1},${l.Owner + 1});\n`;
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (l of lists) {
	for (p of l.Products) {
		query += `INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT) `;
		query += `VALUES (${l.Id},${p + 1});\n`;
	}
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (l of lists) {
	for (u of l.SharedWith) {
		query += `INSERT INTO APP.LISTS_SHARING (LIST,USER_ID,ACCESS) `;
		query += `VALUES (${l.Id},${u + 1},${[0, 1, 2].randomItem()});\n`;
	}
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


query = "";
for (l of lists) {
	for (m of l.Messages) {
		query += `INSERT INTO APP.CHATS (LIST,USER_ID,MESSAGE,TIME) `;
		query += `VALUES (${l.Id},${m.user + 1},'${m.text.replace(/['"]+/g, '')}','${(new Date(m.time)).toISOString().replace('T', ' ').replace(/.[0-9]*Z/g, '')}');\n`;
	}
}
query += "\n\n\n\n";
fs.appendFileSync(filename, query);


