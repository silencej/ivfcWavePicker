/*************************

% Input vector x, and halfLen. Output rAnswer=Sequence1;olling median in xMed.
% 2*halfLen+1 is the length of the roling window.


************************/

#include "rollMedian.h"
#include "debugMode.h"

#include <iostream>
using namespace std;

// http://realtimecollisiondetection.net/blog/?p=89
// By Christer Ericson, Director of Tools and Technology at Sony Santa Monica.

// inline bool doubleEqual(double a, double b)
// {
// //	return fabs(a-b)<DBL_EPSILON;
// 	return (abs(a-b) <= DBL_EPSILON * max(1.0f, abs(a), abs(b)))
// }

rollMedian::rollMedian(const vector<double>& inputDataTmp, int halfLenTmp) :
	medianVec(inputDataTmp.size(),0), inputData(&inputDataTmp), halfLen(halfLenTmp)
{
	list<double> sortSeq ((*inputData).begin(),(*inputData).begin()+2*halfLen+1); // Due to constructor def, the last iterator content will not be copied.
//	int inputLen=sortSeq.size();
	int inputLen=(*inputData).size();
//	assert(halfLen % 2!=0); // Make sure windowLen is odd.
//	sort(sortSeq.begin(),sortSeq.end());
	sortSeq.sort();

// 	cout<<"inputLen: "<<inputLen<<endl;
// 	cout<<"sortSeq Len: "<<sortSeq.size()<<endl;
// 	list<double>::iterator itT=sortSeq.end();
// 	for (int i=1; i<=10; i++)
// 		cout<<*(--itT)<<endl;

//	vector<double> medianVec ((*inputData).size(),0);
	list<double>::iterator sortSeqIter(sortSeq.begin());
//	medianVec[halfLen]=sortSeq[halfLen];
	advance(sortSeqIter,halfLen);
	medianVec[halfLen]=*sortSeqIter;

	double firstValue ((*inputData)[0]);
	double lastValue ((*inputData)[2*halfLen+1]); // To be inserted.
	list<double>::iterator low;

	for (int i=1+halfLen; i<=inputLen-halfLen-1; i++)
	{
#ifdef debugMode
		cout<<"Sortseq "<<i<<":"<<endl;
		for (list<double>::iterator it=sortSeq.begin(); it!=sortSeq.end(); it++)
			cout<<*it<<endl;
		cout<<"Median in medianVec: "<<medianVec[i-1]<<endl;
#endif

		low=lower_bound(sortSeq.begin(),sortSeq.end(), firstValue);
#ifdef debugMode
		cout<<"firstValue: "<<firstValue<<endl;
		cout<<"Lower_bound to firstValue: "<<*low<<" (Should be equal.)"<<endl;
#endif
//		advance(low,1);
		double rightNeigh(100000000);

		// lower_bound is no less than halfLen.
		// The firstValue is in the last position.
		if ((distance(low,sortSeq.end())==0))
		{
			low--;
			cout<<"lower_bound to the end()???"<<endl;
		} else if (distance(low,sortSeq.end())>1)
		{
			advance(low,1);
			rightNeigh=*low;
			advance(low,-1);
		}

		if( (distance(low,sortSeq.end())>1) && ( abs(*low-firstValue) > abs(rightNeigh-firstValue) ) )
		{
#ifdef debugMode
			cout<<"It Happens!!"<<endl;
			cout<<"firstValue: "<<firstValue<<endl;
			cout<<"low: "<<*low<<endl;
			cout<<"rightNeigh: "<<rightNeigh<<endl;
#endif
			// Nothing Happen.
			// end() returns one more.
			low++;
#ifdef debugMode
			cout<<"low++ same riN?: "<<*low<<endl;
#endif
		}

		sortSeq.erase(low);
		low=lower_bound(sortSeq.begin(),sortSeq.end(),lastValue);
#ifdef debugMode
		cout<<"lastValue: "<<lastValue<<endl;
		cout<<"Find lower_bound to lastValue: "<<*low<<" (To insert before it.)"<<endl;
#endif
		// Insert will insert before the position specified.
//		low++;
		sortSeq.insert(low,lastValue);
//		low--;
		sortSeqIter=sortSeq.begin();
		advance(sortSeqIter,halfLen);
		medianVec[i]=*sortSeqIter;

		//For next round.
		firstValue=(*inputData)[i-halfLen];
		lastValue=(*inputData)[i+halfLen+1];

		if (i%5000==0)
//		if (i==1422)
			cout<<"Iteration i="<<i<<endl;
	}

	vector<double> firstPart (halfLen, medianVec[halfLen]);
	vector<double> lastPart (halfLen, *(medianVec.end()-halfLen-1));
	copy(firstPart.begin(),firstPart.end(),medianVec.begin());
	copy(lastPart.begin(),lastPart.end(),medianVec.end()-halfLen);

//	medianVec(1:halfLen)=ones(halfLen,1) * xMed(1+halfLen);
//	xMed(length(x)-halfLen+1 : length(x))=ones(halfLen,1) * xMed(length(x)-halfLen);

}

vector<double> rollMedian::getMad()
{
	int dataLen(medianVec.size());
	int windowLen(2*halfLen+1);
	vector<double> madVec(dataLen,0);
//	vector<double> winSeq((*inputData).begin(),(*inputData).begin()+2*halfLen+1);
	vector<double> interVec(windowLen,0);
	for (int i=0;i!=windowLen;i++)
//		interVec[i]=abs((*inputData)[i]-medianVec[i]);
		interVec[i]=abs((*inputData)[i]-medianVec[halfLen]);
	sort(interVec.begin(),interVec.end());
	madVec[halfLen]=interVec[halfLen];
#ifdef debugModeGetMad
	cout<<"Sorted interVec:"<<endl;
	for (vector<double>::iterator itr(interVec.begin()); itr!=interVec.end(); itr++)
		cout<<*itr<<endl;
	cout<<"mad: "<<madVec[halfLen]<<endl;
#endif

	for (int i=halfLen+1; i<=dataLen-halfLen-1; i++)
	{
		for (int j=0;j!=windowLen;j++)
//			interVec[j]=abs((*inputData)[i-halfLen+j]-medianVec[i-halfLen+j]);
			interVec[j]=abs((*inputData)[i-halfLen+j]-medianVec[i]);
		sort(interVec.begin(),interVec.end());
		madVec[i]=interVec[halfLen];
#ifdef debugModeGetMad
	cout<<"Sorted interVec:"<<endl;
	for (vector<double>::iterator itr(interVec.begin()); itr!=interVec.end(); itr++)
		cout<<*itr<<endl;
	cout<<"mad: "<<madVec[i]<<endl;
#endif
	}

	vector<double> firstPart (halfLen, madVec[halfLen]);
	vector<double> lastPart (halfLen, *(madVec.end()-halfLen-1));
	copy(firstPart.begin(),firstPart.end(),madVec.begin());
	copy(lastPart.begin(),lastPart.end(),madVec.end()-halfLen);

#ifdef debugModeGetMad

	cout<<"Whole madVec:"<<endl;
	for (vector<double>::iterator itr(madVec.begin()); itr!=madVec.end(); itr++)
		cout<<*itr<<endl;
#endif

	return madVec;
}

