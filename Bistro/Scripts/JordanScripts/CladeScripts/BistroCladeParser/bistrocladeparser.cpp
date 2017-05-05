#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <cstdlib>
#include "split.h"

using namespace std;

int main(int argc, char *argv[])
{
	if (argc != 3) {
		cout <<  "Usage: <nopars.smap file> <outputfilename>\n";
		exit(0);
	}
	
	ifstream infile(argv[1]);
	ofstream outfile;
	outfile.open(argv[2]);

	if (infile.is_open()) {
		string line;
		
		//loops over smap file to get only the clades and their probabilities
		getline(infile, line);
		while (getline(infile, line)) {
			vector<string> splitline = split(line);
					
			if (splitline.size() > 2 && splitline.back() != "," && splitline.back() != ";") 
				outfile << splitline[2] << string(5, ' ') << splitline[0] << endl;
		}
	}
	else {
		cout << "Unable to open input file\n";
		exit(0);
	}

	return 0;


}
