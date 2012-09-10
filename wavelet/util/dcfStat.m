function dcfStat(dcf)

data=readDcf(dcf);
peaks=getPeaks(0,data); % all dcf treated as control.
figure('Name',dcf);
h1=subplot(3,1,1);
plot(peaks(:,1),peaks(:,2),'.k');
h2=subplot(3,1,2);
hold on;
hist(peaks(:,1),100)
xlabel('peak width histgram');
miu1=mean(peaks(:,1));
plot([miu1 miu1],ylim,'-r');
sigma1=std(peaks(:,1));
ylabel({['mean: ' num2str(miu1)];['std: ' num2str(sigma1)]});
hold off;
h3=subplot(3,1,3);
hold on;
hist(peaks(:,2),100)
xlabel('peak height histgram');
miu2=mean(peaks(:,2));
plot([miu2 miu2],ylim,'-r');
sigma2=std(peaks(:,2));
ylabel({['mean: ' num2str(miu2)];['std: ' num2str(sigma2)]});
hold off;

end