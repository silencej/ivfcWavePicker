function [peaks] = getPeaks(flag, data, noiseMean, threshold)
% This is Vectorized Version.
% peaks = [width height time xpos]. xpos is the x index in data.
% Flag indicates whether getPeaks.m is going to process noise data or not.
%  If data is noise, please give flag = 0; Else for signal, give flag ~= 0.

% NOTE: This paragraph may be outdated.
% For Noise background data, set threshold to the highest, like inf.
% For Signal data, set threshold to 2*mean(Noise).

% The thershold is used to screen out the companying subpeaks, e.g. blurs.
% The valleys in peaks' two sides should locate equal to or below the
% threshold line. If there are several locally-highest points between such
% two valleys, the highest point will be chosen as the peak.

% SETTINGS
fwhmFlag=1;
debugPlot = 0;

    if flag==0
        noiseMean=mean(data(:,2)); % for calculation of FWHM.
        threshold=noiseMean;
    end

    len=length(data(:,2));
    
    sig_sign=zeros(len,1);
    sig_sign(2:len)=sign(diff(data(:,2)));
    
    % pick up all the raw-peaks and valleys.
    
    sig_sign(1)=inf;
    fsig_sign=sig_sign(2:len); % fsig_sign: sig_sign shifted forward by 1.
    fsig_sign(len)=inf;
    
    result_sign=3.*sig_sign + fsig_sign;
    
    vallyIndex=find(result_sign == -3 | result_sign == -2 | result_sign == 1);
    dataC2=data(:,2);
    vallyIndex=intersect(vallyIndex, find(dataC2<=threshold));
    peakIndex = find(result_sign == 2 | result_sign == 3);
    if threshold ~= inf % The noise data has threshold == inf, and all its peaks should of course be kept.
        % The peaks below threshold will be erased.
        peakIndex = intersect(peakIndex, find(dataC2>=threshold));
    end
    pvIndex=[vallyIndex ; peakIndex];
    pvIndex=sort(pvIndex);
    plen=length(pvIndex);
    pvs=ones(plen, 3); % Initialize the signs to 1(peak). 3 columns: x, y, sign, pvIndex.
    pvs(:,1)=data(pvIndex,1);
    pvs(:,2)=data(pvIndex,2);
    % !!! NOTE that, all the indices pvIndex are related to data and sig_sign
    % instead of pvs.
    %pvs(belowLineVallyIndex,3)=-1;
    data(:,3)=1; % Useless?
    data(vallyIndex,3)=-1;
    pvs(:,3)=data(pvIndex,3); % Useless?
    pvs(:,4)=pvIndex;
    
    % scan for 'real' peak.
    
    pvSign=pvs(:,3);
    pvSignPost=pvSign(2:end);
    pvSignPost(length(pvSign))=-1; % for the end of pvSign (... 1 -1) should be e site too.
    pvSignPre(2:length(pvSign))=pvSign(1:end-1);
    pvSignPre(1)=-1; % for the beginning of pvSign (-1 1 ...) should be s site too.
    pvSignPre=pvSignPre';
    pvSignResult=2.*pvSignPre + 4.*pvSign + pvSignPost;
%	pvSignResult==-1 denotes a double site. s, e sites will alternate, and
%	d sites scatter between. d is equal to e + s.
    si=find(pvSignResult==-5 | pvSignResult==-1); % si: start site index.
    ei=find(pvSignResult==-3 | pvSignResult==-1); % ei: end site index.
%   The first d site in pvSignResult should be taken care of. It is treated
%   as s but not e. Then endding d site should be e but not s.
    if isempty(ei) % in case ei(end) complains error.
        disp('No peak in data.');
        peaks=[];
        return;
    end
    if pvSignResult(ei(end))==-1
        si=si(1:end-1);
    end
    if pvSignResult(si(1))==-1
        ei=ei(2:end);
    end

    if length(ei) == length(si)+1
        ei=ei(2:end); % In case: (1 -1 -1 , ...) has a surplus end site.
    end
    if length(ei) == length(si)-1
        si=si(1:end-1); % In case: (..., -1 -1 1) has a surplus start site.
    end

    maxrng=@(i) max(pvs(si(i)+1:ei(i)-1,2));
    maxrngi=@(i) maxi(pvs(si(i)+1:ei(i)-1,2));

    all_max=arrayfun(maxrng,1:length(si));
    all_maxi=arrayfun(maxrngi,1:length(si));

    if fwhmFlag==0
        peaks = [(pvs(ei,1)-pvs(si,1))'; all_max; pvs(all_maxi+si',1)'; pvs(all_maxi+si',4)']'; % Bottom Width.
    
    else % FWHM width.
        hm = 1/2*all_max + 1/2*noiseMean; % Normalize to noiseMean. hm: half maximum.
        if debugPlot==1 && threshold~=inf
            figure;
            hold on;
            plot(data(:,1),data(:,2),'-k');
            plot(data(:,1),data(:,2),'dk');
            x=xlim;
            plot([0,x(2)],[noiseMean,noiseMean],'--k');
        end
        all_fwhm=arrayfun(@fwhm, 1:length(si));
        if debugPlot==1 && threshold~=inf
            hold off;
        end
%         peaks = [all_fwhm', all_max', pvs(all_maxi+si',1)];
        peaks = [all_fwhm', all_max', pvs(all_maxi+si',1), pvs(all_maxi+si',4)];
    end

    function [width] = fwhm(i)
        %lrange_old = find( pvs(si(i),1)<=data(:,1) & data(:,1)<pvs(all_maxi(i)+si(i),1) );
        %rrange_old = find( pvs(all_maxi(i)+si(i),1)<data(:,1) & data(:,1)<=pvs(ei(i),1) );
        lrange = (pvs(si(i),4):pvs(si(i)+all_maxi(i),4)-1)';
        rrange = (pvs(si(i)+all_maxi(i),4)+1:pvs(ei(i),4))';

       [V1, J1] = min(abs( data(lrange,2) - hm(i)) ); % range: [valley1, peak-1]. In case there is no subpeaks between.
       [V2, J2] = min(abs( data(rrange,2) - hm(i)) ); % range: [peak+1, vally2]
        width = data(rrange(J2),1) - data(lrange(J1,1));
        %if debugPlot==1 && threshold~=inf
        %    plot(data(rrange(J2),1), data(rrange(J2),2), '*r');
        %    plot(data(lrange(J1),1), data(lrange(J1),2), '*b');
        %    % plot(pvs(si(i):ei(i),1),pvs(si(i):ei(i),2), 'dk');
        %    plot([data(lrange(J1),1), data(rrange(J2),1)], [data(lrange(J1),2), data(rrange(J2),2)], '-g');
        %end
    end

end

function I = maxi(X)
    [V J] = max(X);
    I=J;
end
