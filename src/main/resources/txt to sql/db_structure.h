#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>

using namespace std;

void printStructure(ofstream &output) {
    ifstream input("structure.txt");
    char t;
    while (input.get(t)) {
        output << t;
    }
}

void addlogos(unordered_map<string, string> &logos) {
    ifstream logos_in("logos.txt");
    string temp;
    string temp_2 = "";
    int status = 0;
    while (getline(logos_in, temp)) {
        // cout << temp << endl;
        if (temp[0] == '-' && temp[1] == '-') {
            switch (status) {
            case 0:
                logos["products"] = temp_2;
                break;
            case 1:
                logos["product categories"] = temp_2;
                break;
            case 2:
                logos["users"] = temp_2;
                break;
            case 3:
                logos["lists"] = temp_2;
                break;
            case 4:
                logos["list categories"] = temp_2;
                break;
            case 5:
                logos["list has products"] = temp_2;
                break;
            case 6:
                logos["list sharing"] = temp_2;
                break;
            case 7:
                logos["list-cat has prod-cat"] = temp_2;
                break;
            case 8:
                logos["chats"] = temp_2;
                break;
            }
            temp_2 = "";
            status++;
        } else {
            temp_2 += "-- " + temp;
        }
    }
}