function [data,GT,f] = simuData(snr,cellPeriod)
% [data,GT,f]=simudataVlGauss(snr,cellPeriod)
% f is the figure handle.
% Generate simulated data for vlGauss.
% To test vlGauss, these features should be in the sumulated data:
% 1. sharp high impulse noise peaks.
% 2. white noise.
% 3. baseline variation.
% 4. multi-scaled gaussian cell peaks.
% 5. multi-scaled near-gaussian cell peaks.

addpath(genpath('util'));

debugFlag=0;
if nargout<2
    f=0;
else
    debugFlag=1;
end

if nargin<1
	snr=1;
end

if nargin<2
%     cellPeriod=5000;
    cellPeriod=5000;
end

% 0-15min_0-300.dcf
% 0.0540
% 0.0125
% 0.0058
% sigmaV(:,:,1) =    0.0461
% sigmaV(:,:,2) =    0.0066
% sigmaV(:,:,3) =    0.0048
% pV =    0.0068    0.1766    0.8166
% a=gaussfirWcf(17), 1/a(9)=6.67.
% So as to gcPeaks, multiplier for mean is 6.67/2=3, for variance is 3^2=9, sigma multiplier is 3.
% lower ipPeaks and gNoises don't change much after gaussfir. so multipliers for mean and sigma are both 2. 

%% Parameters.
dataLen=100000;
deBaselineWindowLen=1001;

% Gaussian random noise ~ normal.
% gNMu=0.05;
% gNSigma=0.03;
% gNMu=0.0058*2;
% gNSigma=0.0048*2;

% Cell peaks
% height ~ lnN.
% width ~ N(14,2) ~ [8 20] (for 3*sigma).
% >=5000

% [0.15 0.6], lnN(log(0.15),0.2)
% gcLMu=log(0.15);
% gcLSigma=0.2;
% Don't change.
% [0.15 0.6]
gcLMu=(log(0.6)+log(0.15))/2;
gcLSigma=0.5;
% gcLSigma=log(0.0461*2);

% % Impurity peaks
% % height ~ N(0.08,0.02) ~ [0.02 0.14].
% % width ~ N(5,0.6) ~ [3 7].
% % 10000 impurity peaks.
% ipPeriod=50;
% [0.05 0.15]
% ipMu=0.05;
% ipSigma=0.02;
% ipMu=0.0125*2;
% ipSigma=0.0066*2;


% sineBasePeriod=100000;
% sineBaseAmp=1;
% pMean=0.01;

% Parameter part ends.

%% Body.

fs=5000;
ts=1.0/fs;
timeV=0:ts:(dataLen-1)*ts;
timeV=timeV';
% timeV=0:0.0002:(dataLen-1)*0.0002;
x=1:dataLen;

% cell peaks. lognormal distribution.
gcPx=(30:cellPeriod:dataLen);
% height: 1~2, fwhm: 5~9. Window width: 11~19.
% height=exp(0.05+0.6*rand(1,length(gcPx)));
% height=exp(gcLMu+gcLSigma*rand(1,length(gcPx)));
% height=gcLow+(gcHigh-gcLow)*rand(1,length(gcPx));
% height=random('logn',ones(length(pcPx),1)*log(gcLMu),ones(length(pcPx),1)*log(gcLSigma));
height=lognrnd(gcLMu,gcLSigma,length(gcPx),1);
width=13+randn(1,length(gcPx));
gcPeaks=gaussC(x,gcPx,height,width);
%gcPeaks=zeros(size(x))+1;

% Gaussian noise.
wNoise=awgnWcf(gcPeaks,snr); % snr=1.
% gNoise=normrnd(gNMu,gNSigma,dataLen,1);

% % Impurity noise. Two groups.
% ipPx=(10:ipPeriod:dataLen);
% iHeight=ipMu+ipSigma*randn(1,length(ipPx));
% % [3 7]
% iWidth=5+0.6*randn(1,length(ipPx));
% % iWidth=3*ones(1,length(ipPx));
% ipPeaks=gaussC(x,ipPx,iHeight,iWidth);
% ipPeaks=normrnd(ipMu,ipSigma);


% % 10000 impurity peaks.
% ipPx2=(15:ceil(ipPeriod/10):dataLen);
% % N(0.013, 0.006)
% iHeight=gNMu+gNSigma*randn(1,length(ipPx2));
% iWidth=3*ones(1,length(ipPx2));
% ipPeaks2=gaussC(x,ipPx2,iHeight,iWidth);
% % ipPeaks=ipPeaks';
% % data=data+ipPeaks';

% Baseline.
% sineBase=sineBaseAmp*sin((2*pi/sineBasePeriod)*x);
% sineBase=sineBase';
% baseline=0.05:0.005/dataLen:0.055;
baseline=0*ones(1,dataLen);
baseline=baseline(1:dataLen);
baseline=baseline';

data=gcPeaks+wNoise+baseline;
% data=gcPeaks+wNoise+ipPeaks+ipPeaks2+baseline+sineBase;
% data=gcPeaks+ipPeaks+baseline+gNoise; % +ipPeaks2
% data=gcPeaks+baseline+ipPeaks+ipPeaks2;

if debugFlag
	dataS=data-smoothWcf(data,deBaselineWindowLen);
	dataS=filtfilt(gaussfirWcf(17),1,dataS);
    close all;
	f=figure;
	hold on;
	plot(timeV,gcPeaks,'-b');
	plot(timeV,data,'-k');
	plot(timeV(gcPx),data(gcPx),'*r');
    plot(timeV,smoothWcf(data,deBaselineWindowLen),'--g');
    plot(timeV,dataS,'--k');
	xlabel('Time');
	ylabel('Intensity');
	title('Simulated Data');
	hold off;

% 	pks=findpeaks(dataS);
% 	binNum = floor(1+log2(length(pks)));
% 	if binNum<100
% 		binNum=100;
% 	end
% 	w=(max(pks)-min(pks))/binNum;
% 	x=min(pks):w:max(pks);
% 	figure;
% 	[p,X]=hist(pks,x);
% 	bar(X,p);

end

GT=gcPx;
data=[timeV data];

end
