#include <fstream>
#include <iostream>
#include <string>
#include <unordered_set>
#include <unordered_map>
#include <vector>
#include "db_structure.h"
#include <time.h>

using namespace std;

string toString(vector<char> vec) {
	string s = "";
	for (char c : vec) {
		s += c;
	}
	return s;
}

typedef vector<string> Product;
typedef string Category;

int main() {
	srand(time(0));
	ifstream input("Prodotti.txt");
	ofstream output("generator.sql");

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	printStructure(output);
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	unordered_map<string, string> logos;
	addlogos(logos);





	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	output << "\n\n\n\n\n";
	output << logos["users"];
	output << "INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN,AVATAR) VALUES ('andrea.matte@studenti.unitn.it','$2a$10$zmo44mIGrEzF.2flUu13SOatFYW8LHaRoxSGPJeRRM.fe6IBfddCS','andrea','matto',true,NULL);\n";
	output << "INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN,AVATAR) VALUES ('andrei.diaconu@studenti.unitn.it','$2a$10$bek3pnCbDuA7YfLXHDpVi./CPITBTv.nPud1Q63WukdgtKsrr.NCe','andrei','kontorto',true,NULL);\n";
	output << "INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN,AVATAR) VALUES ('andrea.iossa@studenti.unitn.it','$2a$10$N9qdvU/PSaRyeaQbq8L7N.dOoZARRBCNmJc0puH3amiteKiuI7U9y','andrea','ioza',true,NULL);\n";
	// altri utenti random
	vector<string> names = {"andrea", "matteo", "edoardo", "anna", "fabrizia", "gianmaria", "mattea", "dora"};
	vector<string> lastnames = {"bini", "chi", "amadori", "castellaneta", "chiocco", "toldo"};
	vector<string> avatars = {"avatar1", "avatar2", "avatar3", "avatar4"};
	vector<string> domains = {"@gmail.com", "@yahoo.it", "@alice.it", "@hotmail.com"};
	int TOT_USERS = 20;
	for(int i=3; i<TOT_USERS; i++){
		string name = names[rand()%names.size()];
		string lastname = lastnames[rand()%lastnames.size()];
		string avatar = avatars[rand()%avatars.size()];
		string domain = domains[rand()%domains.size()];
		output << "INSERT INTO APP.USERS (EMAIL,PASSWORD,FIRSTNAME,LASTNAME,IS_ADMIN,AVATAR) VALUES ('" << name << "." << lastname << (31*i) << domain << "','$2y$10$4g/8zymTLbHTZJYT.44EDuMqAgDi.0v1/mjCLPABn1WakOUIfz.Ee','" << name << "','" << lastname << "',false,NULL);\n";
	}
	output << "\n\n\n\n\n";
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	unordered_set<Category> categories;
	vector<Product> products;
	char t;
	vector<char> temp;
	int state = 0;
	while (input.get(t)) {
		if (t == '\t') {
			if (state == 0) {
				vector<string> prod = {toString(temp)};
				products.push_back(prod);
				temp.clear();
				temp.resize(0);
				state++;
			} else if (state == 1) {
				products[products.size() - 1].push_back(toString(temp));
				temp.clear();
				temp.resize(0);
				state++;
			} else if (state == 2) {
			}
		} else if (t != '\n') {
			temp.push_back(t);
		} else {
			products[products.size() - 1].push_back(toString(temp));
			categories.insert(toString(temp));
			temp.clear();
			temp.resize(0);
			state = 0;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	vector<pair<Category,vector<Product>>> categ_prod;
	for(Category cat : categories){
		vector<Product> t_prods;
		for(Product prod : products){
			if(cat.compare(prod[2])==0){
				t_prods.push_back(prod);
			}
		}
		categ_prod.push_back({cat, t_prods});
	}
	output << logos["product categories"];
	for(Category cat : categories){
		output << "INSERT INTO APP.PRODUCTS_CATEGORIES (NAME,DESCRIPTION,LOGO) VALUES ('" << cat << "','nodesc',NULL);\n";
	}
	output << "\n\n\n\n\n";
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	output << logos["products"];

	for(pair<Category, vector<Product>> c_vp : categ_prod){
		//cout << c_vp.first << endl << endl;
		for(Product p : c_vp.second){
			int c = rand()%2==0 ? rand()%4 : rand()%(TOT_USERS-10) +4;
			//cout << "Name: " << p[0] << "\nDescription:\n" << p[1] << endl << endl;
			output << "INSERT INTO APP.PRODUCTS (NAME,DESCRIPTION,CATEGORY,CREATOR,IS_PUBLIC,LOGO,PHOTO) VALUES (";
			output << "'" << p[0] << "','" << p[1] << "','" << p[2] << "'," << c << ",NULL,NULL);\n";
		}
		output << endl;
	}
	output << "\n\n\n";
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	output << logos["list categories"];
	vector<string> list_categories = {"Regali di natale", "Fai da te", "Lista della spesa", "Informatica"};
	for(string s : list_categories){
		output << "INSERT INTO APP.LISTS_CATEGORIES (NAME,DESCRIPTION,LOGO) VALUES ('" << s << "','nodesc',NULL);\n";
	}
	output << "\n\n\n\n";
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	int LIST_NUM = list_categories.size()*20;
	output << logos["lists"];
	for(int i=1; i<=LIST_NUM; i++){
		int lists_perCat = LIST_NUM/list_categories.size();
		string cat = list_categories[(i-1)/lists_perCat];
		output << "INSERT INTO APP.LISTS (NAME,DESCRIPTION,CATEGORY,OWNER,LOGO) VALUES ('lista" << i << "','nodesc','" << cat << "', " << (rand()%TOT_USERS +1) << ",'list1');\n";
	}
	output << "\n\n\n\n";
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	output << logos["list has products"];
	for(int i=1; i<=LIST_NUM; i++){
		//int lists_perCat = LIST_NUM/list_categories.size();
		//int cat = (i-1)/lists_perCat;
		int amount = 10 + rand()%15;
		for(int p=0; p<amount; p++){
			output << "INSERT INTO APP.LISTS_PRODUCTS (LIST,PRODUCT,PURCHASED) VALUES (" << (rand()%LIST_NUM +1) << "," << (rand()%products.size() +1) << "," << ((rand()%100) > 80 ? "TRUE" : "FALSE") << ");\n";
		}
	}
	output << "\n\n\n\n";
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	output << logos["list sharing"];
	for(int i=1; i<=LIST_NUM; i++){
		int amount = rand()%3;
		for(int u=1; u<=amount; u++){
			output << "INSERT INTO APP.LISTS_SHARING (LIST,USER) VALUES (" << i << "," << (rand()%TOT_USERS +1) << ");\n";
		}
	}
	output << "\n\n\n\n";


	return 0;
}