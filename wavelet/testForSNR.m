function testForSNR
% This is function for SNR test.

% gendataFlag=1;

%% Generate data.
addpath(genpath('util'));

% debugFlag=0;

% snrvr=0.1:0.1:1; % SNR in Ratio.
snrvr=[1e-5 1e-4 0.001 0.01 0.1 0.5 1]; % SNR in Ratio.
snrV=10*log10(snrvr); % Convert in dB.
l=length(snrV);

close all;
testTime=10;

tpm=zeros(testTime,l); % Matrix.
fpm=zeros(testTime,l);
fnm=zeros(testTime,l);

for i=1:testTime
	[tpm(i,:),fpm(i,:),fnm(i,:)]=testOnce(snrV);
end
tpm=tpm';
fpm=fpm';
fnm=fnm';

figure;
plot(tpm./(tpm+fnm),'-k');
hold on;
plot(tpm./(tpm+fnm),'ok','MarkerFaceColor','k','MarkerEdgeColor','r');
set(gca,'XTickLabel',snrV);
% title('Ture Positive');
xlabel('SNR(dB)');
ylabel('TPR');
xl=xlim;
xlim([xl(1)-0.1 xl(2)+0.1]);
yl=ylim;
ylim([yl(1)-0.1 yl(2)+0.1]);
saveas(gca,'tprWaveSnr.eps','epsc');

figure;
plot(fpm,'-k');
hold on;
plot(fpm,'ok','MarkerFaceColor','k','MarkerEdgeColor','r');
set(gca,'XTickLabel',snrV);
% title('False Positive');
xlabel('SNR(dB)');
ylabel('FP Number');
xl=xlim;
xlim([xl(1)-0.2 xl(2)+0.2]);
yl=ylim;
ylim([yl(1)-0.2 yl(2)+0.2]);
saveas(gca,'fpnWaveSnr.eps','epsc');

end

%%
function [tpv,fpv,fnv]=testOnce(snrV)
% tpv, fpv and fnv are all vectors.

l=length(snrV);
tpv=zeros(1,l);
fpv=zeros(1,l);
fnv=zeros(1,l);

for i=1:l
	fprintf(1,'Generating dcf %d of %d.\n',i,l);
	[data GT]=simuData(snrV(i));
%		 writeDcf(data,['data/snr' num2str(snrvr(i)) '.dcf']);
%		 save(['data/snr' num2str(snrvr(i)) '_gt.mat'],'GT'); % Ground Truth.
% 	[pidx, tpv(i), fpv(i), fnv(i)] = staThre(data,2,0,GT);
    peaks=wavePick(data);
    [tpv(i), fpv(i), fnv(i)]=getRoc(peaks,GT);
% 	sprintf(num2str(size(peaks,1)));
end
% disp('Generate dcfs finished.');

%%

% for i=1:l
%	data=readDcf(['data/snr' num2str(snrvr(i)) '.dcf']);
%	load(['data/snr' num2str(snrvr(i)) '_gt.mat'],'GT');
% end


end