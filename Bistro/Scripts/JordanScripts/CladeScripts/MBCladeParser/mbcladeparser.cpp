#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include "split.h"

using namespace std;

int main(int argc, char *argv[]) 
{
	if (argc != 4) {
		cout << "Usage: <partsfile> <tstatfile> <outputfilename>\n";
		exit(0);
	}

	ifstream partsfile(argv[1]);
	ifstream tstatfile(argv[2]);
	ofstream outfile;
	outfile.open(argv[3]);

	vector<string> IDNumbers;
	vector<double> probs;
	vector<string> clades;
	string line;

	//pulls the ID's and probabilites from the tstat file
	if (tstatfile.is_open()) {
		getline(tstatfile, line);
		getline(tstatfile, line);

		while(getline(tstatfile, line)) {
			vector<string> splitline = split(line);

			if (!splitline.empty()) {
				IDNumbers.push_back(splitline[0]);
				probs.push_back(stod(splitline[2].c_str()));
			}
		}
		tstatfile.close();
	}
	else {
		cout << "Unable to open tstat file\n";
		exit(0);
	}

	//matches up ID's with mb clade representation and prints to output file
	if (partsfile.is_open()) {
		getline(partsfile, line);
		getline(partsfile, line);

		int i = 0;
		while(getline(partsfile, line)) {
			vector<string> splitline = split(line);

			if (!splitline.empty()) 
				if (splitline[0] == IDNumbers[i]) {
					outfile << splitline[1] << string(5, ' ') << probs[i] << endl;
					++i;
				}
		}
	}

	return 0;
}
