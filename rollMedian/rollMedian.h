#pragma once
#ifndef ROLLMEDIAN_H
#define ROLLMEDIAN_H

#include <vector>
#include <list>
#include <algorithm>
//#include <assert.h>
#include <cmath>
//#include <climits>
using namespace std;
 
class rollMedian
{
		vector<double> medianVec;
		const vector<double> *inputData;
		int halfLen;
	public:
		rollMedian(const vector<double>& inputDataTmp, int halfLenTmp);
		vector<double> getMad();
		inline const vector<double> getMedian() {return medianVec;};
};
 
#endif


