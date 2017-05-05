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
		cout << "Usage: <inputfilename> <outputfilename>" << endl;
		exit(0);
	}

	ifstream infile(argv[1]);
	ofstream outfile;
	outfile.open(argv[2]);

	string line;

	if (infile.is_open())	{
		getline(infile, line);
		
		//calculates probabilities based off of weights
		double sum = 0;
			
		while (getline(infile, line)) {
			vector<string> splitline = split(line);
			if(!splitline.empty())
				sum += (stod(splitline[5]));				
		} 
		
		infile.close();

		ifstream infile(argv[1]);

		getline(infile, line);
		while (getline(infile, line)) {
			vector<string> splitline = split(line);
			
			if (!splitline.empty()) {
				//splitline[5] is the weights. can be easily modified to use counts, parsimony, etc
				outfile << splitline[0].substr(0, splitline[0].length()-1)<< string(5, ' ') << stod(splitline[5])/double(sum) << endl;
				cout << stod(splitline[5]) << endl;
			}
		} 
	
	}
	else {
		cout << "Unable to open file\n";
		exit(0);
	}	

	return 0;
}	
