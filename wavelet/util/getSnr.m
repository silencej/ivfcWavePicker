function snr=getSnr(data,pidx,winLen)
% Get an estimate of SNR from the intensity vector data2 and the picked
% peaks' index pidx.
% The pidx and its neighborhood bounded by winLen are considered signals
% and the rest regarded as noise.
% The winLen defaults to 31.
% data is 1-dimensional.

<<<<<<< HEAD
debugFlag=1;
=======
debugFlag=0;
>>>>>>> origin/master

if nargin<3
    winLen=31;
end

if ~mod(winLen,2)
    winLen=winLen+1;
end

halfLen=(winLen-1)/2;
dataLen=length(data);
signal=zeros(dataLen,1);
for i=1:length(pidx)
    if pidx(i)-halfLen<=0
        signal(1:pidx(i)+halfLen)=data(1:pidx(i)+halfLen);
    elseif pidx(i)+halfLen>dataLen
        signal(pidx(i)-halfLen:end)=data(pidx(i)-halfLen:end);
    else
        signal(pidx(i)-halfLen:pidx(i)+halfLen)=data(pidx(i)-halfLen:pidx(i)+halfLen);
    end
end

noise=data-signal;

if debugFlag
    figure,plot(data,'-k');
    hold on;
    plot(signal,'-r');
    plot(noise,'-b');
    hold off;
end

snr=10*log10(sum(signal.^2)/sum(noise.^2));
end