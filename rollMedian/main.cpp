#include "rollMedian.h"
#include "debugMode.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;

bool littleEndian();
int procOneFile(const string&);

// http://www.cplusplus.com/forum/general/6347/
// The following template is contributed by helios.
template <typename T>
T invert(T val){
	size_t size=sizeof(T);
	T res=0;
	char *src=((char *)&val)+size-1,
		*dst=(char *)&res;
	for (size_t a=size;a;a--)
		*dst++=*src--;
	return res;
}

// Invert only if the system is big endian. Then the input file and output file are both little endian, say, platform-independent.
template <typename T>
T invertIfBig(T val)
{
	// Determine Endianness.
	if (!isLittleEndian)
	{
//		cout<<"The machine is Big Endian, while data is little endian!"<<endl;
		return invert<T> (val);
	}
	else
		return val;
}

bool isLittleEndian(littleEndian());

int main(int argc, char** argv)
{

	// Make sure the input and output binary are all little endian.

	cout<<"getRollMedian runs..."<<endl;

	fstream tests("E:/works/ivfcWavePicker/rollMedian/a.txt",ios::in);
	if (!tests)
		cout<<"Test fail!!!"<<endl;
	string aa;
	getline(tests,aa);
	cout<<aa<<endl;

//	fstream fs("../0-15min_clip0-300.dat", ios::in | ios::binary);
	fstream fs(argv[1], ios::in);
//	fstream fs("../toRollMedian.dat", ios::in | ios::binary);
	if (!fs)
	{
		cout<<"Can't open file: "<<argv[1]<<endl;
		return 1;
	}
	string filename;
	do {
		getline(fs,filename,'\n');
		cout<<"Read filename: "<<filename.c_str()<<endl;
		if (!filename.empty())
			procOneFile(filename);
	} while (!fs.eof());

	fs.close();
	cout<<"Finished."<<endl;
	return 0;

}

int procOneFile(const string& filenameIn)
{
//	cout<<"Process "<<filenameIn.c_str()<<endl;

	string datFile(filenameIn);
	string::iterator datFileIt=datFile.end();
	datFile.replace(datFileIt-4,datFileIt,".dat");
	// Backslashes \ in windows path should be replaced by /.
	// Also, the char '\' should be also be escaped as '\\'.
	 replace(datFile.begin(),datFile.end(),'\\','/');

	//stringstream ss;
 // for (int i = 0; i < datFile.length(); ++i) {
 //    if (datFile[i] == '\\') {
 //      ss<<"\\\\";
 //    }
 //    else {
 //      ss<<datFile[i];
 //    }
 // }
 // datFile=ss.str();

	cout<<"Process "<<datFile<<endl;
	fstream fs(datFile.c_str(), ios::in | ios::binary);
//	fstream fs("../toRollMedian.dat", ios::in | ios::binary);
	if (!fs)
	{
		cout<<"Can't open file: "<<datFile<<endl;
		return 1;
	}

//	fs.seekg(0,ios::end);
//	unsigned int length (fs.tellg());
//	fs.seekg(0,ios::beg);

	// Read in halfLen.
	unsigned long halfLen(0);
	fs.read( reinterpret_cast<char*>(&halfLen), 4);
	halfLen=invertIfBig<unsigned long> (halfLen);
	cout<<"halfLen = "<<halfLen<<endl;
	unsigned long dataLen(0);
	fs.read( reinterpret_cast<char*>(&dataLen), 4);
	dataLen=invertIfBig<unsigned long> (dataLen);
	cout<<"dataLen = "<<dataLen<<endl;

	vector<double> input (dataLen,0);

	for (unsigned int i=0; i!=dataLen; i++)
	{
		double a(0.0);
		fs.read( reinterpret_cast<char*>(&a), sizeof(double));
		a=invertIfBig<double> (a);
		input[i]=a;
	}

	fs.close();
	cout<<dataLen<<" datapoints are read. Processing..."<<endl;

	// Debug
#ifdef debugMode
//	input.erase(input.begin()+30,input.end());
//	halfLen=5;
	cout<<"Debug mode on, dataLen: "<<input.size()<<", halfLen="<<halfLen<<endl;
#endif
#ifdef debugModeGetMad
	input.erase(input.begin()+10,input.end());
	halfLen=3;
	cout<<"Debug mode on, dataLen: "<<input.size()<<endl;
#endif

	rollMedian rollMedObj(input, halfLen);
	vector<double> medianVec (rollMedObj.getMedian());
	vector<double> madVec (rollMedObj.getMad());

// Debug mode does not produce .mead files.
#ifdef debugMode
	return 0;
#endif

	string filename(datFile);
	string::iterator fileIt=datFile.end();
	filename.replace(fileIt-4,fileIt,".mead"); // median and mad output file.
//	filename.append(".mead"); // median and mad output file.
//	fs.open("../toWavePick.dat", ios::binary | ios::out);
//	fs.open("../relay.data", ios::out);
	fs.open(filename.c_str(), ios::binary | ios::out);
	if (!fs)
	{
		cout<<"Unable to open file for writing: "<<filename<<endl;
		return 1;
	}
	unsigned long dataLenOut(invertIfBig<unsigned long> (dataLen));
	fs.write( reinterpret_cast<char*>(&dataLenOut), 8);
	for (vector<double>::iterator i=medianVec.begin(); i!=medianVec.end(); i++)
	{
		double a(*i);
		a=invertIfBig<double> (a);
//		fs<<a<<endl;
		fs.write( reinterpret_cast<char*>(&a), sizeof(double));
	}

	for (vector<double>::iterator i=madVec.begin(); i!=madVec.end(); i++)
	{
		double a(*i);
		a=invertIfBig<double> (a);
//		fs<<a<<endl;
		fs.write( reinterpret_cast<char*>(&a), sizeof(double));
	}

	fs.close();

//	cout<<"../toWavePick.dat is produced."<<endl;
	cout<<filename<<" is produced."<<endl;

	return 1;
}

bool littleEndian()
{
	int i=1;
	char *p=(char *)&i;
	if (p[0]==1)
		return 1; // Little endian.
	else
		return 0;
}
