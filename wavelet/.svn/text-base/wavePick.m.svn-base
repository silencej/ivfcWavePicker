function [peaks]=wavePick(dcfpathname,debugFlag)
%[peaks]=wavePick(dcfpathname,debugFlag)
% The main wavelet peak picking function for IVFC.

% Initialized by David Damm.
% Modified and mantained by Chaofeng Wang.
% Updated 2011.

%% Settings.
devCoef=1; % Used in thresholding. seekthresh_pos = x_out_med + devCoef * x_out_dev.

% Added for comparison.
if nargin<2
	debugFlag=true;
end
if nargin<1
	dcfpathname='../../data/testData/0-15min_clip0-300.dcf';
end

dcf=readDcf(dcfpathname);
t = dcf(:, 1);
x = dcf(:, 2);

%% Preprocessing, unbiasing.
% bias = median(abs(x));
bias = median(x);
x = x - bias;
% x_max=max(abs(x));
% x = x / x_max;
x = x ./ max(x);
clear dcf;
x_in = x;

if debugFlag
    close all;
	figure;
	title(dcfpathname);
%     plot(t,x_in, 'Color', [.075 .125 .075]);
	plot(t,x_in,'-k');
end

%% Wavelet-based Denoising.
wname = 'sym7';%'coif3';%'sym4';%'db4';
wlevel = 3;
[c, l] = wavedec(x_in, wlevel, wname);

d_1=detcoef(c,l,1);
% d_1 = c(l(length(l) - 1) : l(length(l))); % get largest details coeffs range
% The original d_1 calculation is wrong. See a test like below.
% x=1:100;
% y=sin(x);
% [c l]=wavedec(y,3,'sym7');
% d_1=detcoef(c,l,1);
% length(d_1)
% length(c(l(length(l) - 1) : l(length(l))))

% delta_mad = median(abs(d_1)) / .6745;     % correct median by a factor, recommended by D. Donoho for white noise
    % alternativ mit standardabweichung
% korrektur von delta_mad bzw finden der schranke tau
% delta_mad is an estimate of the std (or say sigma) of noise.
delta_mad = mad(d_1,1) / .6745; % mad(x,1) for median absolute value. mad(x,0) for mean absolute value.

% From Matlab Doc of mad function:
% different scale estimates: std < mean absolute < median absolute (< stands for worse than in robustness).
% For normally distributed data, multiply mad by one of the following factors to obtain an estimate of the normal scale parameter σ, e.g. std:
% sigma = 1.253*mad(X,0) — For mean absolute deviation
% sigma = 1.4826*mad(X,1) — For median absolute deviation
% 1.4826*0.6745=1

% The threshold is different from Dohono1995's - thre = delta * sqrt(2*logn/n). But the original is thre = delta * sqrt(logn). I think it's wrong.
% While in matlab wavelet Fixed Form thresholding, t=s*sqrt(2log(n)).
% Use Donoho's formula will get a threshold near 0! So use matlab formula instead.
% tau = delta_mad * sqrt(log(length(x_in))); % estimated noise boundary.
n=length(x_in);
% tau = delta_mad * sqrt(2*log(n)/n);
tau = delta_mad * sqrt(2*log(n));
threshtype = 's';
% Apply the same threshold on all 3 scale details.
nc = wthresh(c, threshtype, tau);
% Stretch to keep the height unchanged after soft-thresholding.
if threshtype == 's'
	x_out = (1 + tau) * waverec(nc, l, wname);
else
	x_out = waverec(nc, l, wname);
end
if debugFlag
	hold on;
	plot(t,x_out, 'g'); % green.
	hold off;
end

%% Show the effect of soft thresholding.
% figure, plot(nc,'-b');
% hold on;
% plot(c,'-k');
% xl=xlim;
% plot(xl,[tau tau],'--r');
% plot(xl,[-tau -tau],'--r');
% hold off;

% %
% % smooth signal
% %
% 
% ma_time = .0025; % Seconds
% ma_points = floor(fs * ma_time);
% if mod(ma_points, 2) ~= 0
%     ma_points = ma_points + 1;
% end
% ma_win = gausswin(ma_points);
% x_out = conv(abs(x_out), ma_win / sum(ma_win));
% x_out = x_out(ma_points / 2 + 1 : end - ma_points / 2 + 1); % shift
% plot(x_out, 'Color', [0 1 0]);

% zum vergleich tidos methode
% P = peaks(x_out);
% plot(P, x_out(P), '*', 'Color', 'y');

%
% look at the median +- standard deviation in the nearest past and future
%

%% Peak detection.

%	fs = 1 / (t(2) - t(1));
%	mm_time = .25;%.05;%.25; % Seconds
%	mm_points = floor(fs * mm_time);
%	% mm_points must be odd now. Not even any more.
%	if mod(mm_points, 2) == 0
%		mm_points = mm_points + 1;
%	end
%	% x_out_med = zeros(length(x_out), 1);
%	% x_out_dev = zeros(length(x_out), 1);
%	%% The David's code is shifted version.
%	% for k = 1 : length(x_out) - mm_points
%	% 	x_out_med(k) = median(x_in(k : k + mm_points));
%	% 	x_out_dev(k) = std(x_in(k : k + mm_points));
%	% end
%	halfLen=(mm_points-1)/2;

[path file]=fileparts(dcfpathname);
fid=fopen(['../rollMedian/temp/' file '.dat.mead'],'rb');
% dataLenOut=fread(fid,1,'uint64','l');
x_out_med=fread(fid,length(x_in),'double','l');
% x_out_med=fscanf(fid,'%f',length(x_in));
x_out_mad=fread(fid,length(x_in),'double','l');
fclose(fid);

x_out_dev=1.4826 * x_out_mad;

clear x_out_mad;

% Here threshold are caled based on x_in not x_out, since threshold is an estimate on noise.
% x_out_med=rollMedian(x_in,halfLen);
% x_out_dev=1.4826 * rollMad(x_in,halfLen,x_out_med);


%
% look at slope changes
%

dx = diff(x_out);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wcf's code.

dx=reshape(dx,length(dx),1);
dx=[0; dx];

seekthresh_pos = x_out_med + devCoef * x_out_dev;
% seekthresh_neg = x_out_med - x_out_dev;
seekthresh_neg = -1 .* seekthresh_pos;
clear x_out_med;
clear x_out_dev;

% Variables;
as=0; % ascent
ds=0; % descent
% state enums: 1-a1, 2-a2, 3-a3, 4-p1, 5-d1, 6-d2.
state=1;
candidate=0;
peaks=[0 0];
peakNum=0;
	
for i=1:length(dx)
	if dx(i)<=0
		ds=ds+dx(i);
		switch state
			case 1
                state=1; as=0; ds=0;
			case 2
                state=3;
			case 3
                state=1; as=0; ds=0;
			case 4
                state=5;
			case 5
			  if (ds<=seekthresh_neg(i))
				state=6; peakNum=peakNum+1; peaks(peakNum)=candidate;
			  else
				state=5;
			  end
			case 6
                state=1; as=0; ds=0;
            otherwise
                fprintf(0,'Unknown state in %d: %s\n', i,state);
		end
	else % dx >0.
		as=as+dx(i);
		switch state
			case 1
                state=2;
			case 2
			  if (as>=seekthresh_pos(i))
				state=4; candidate=i; as=0; ds=0;
			  else
				state=2;
			  end
			case 3
                state=2;
			case 4
                state=4; candidate=i; as=0; ds=0;
			case 5
                state=5;
                % Modify the bug in previous version of FSA in conference paper.
                if x_out(i)>x_out(candidate)
                    candidate=i;
                end
			case 6
                state=2;
            otherwise
                fprintf(0,'Unknown state in %d: %s\n', i,state);
		end
	end
end

% Delurring.
% compare peak_i and peak_i+1, move the higher one to peak_i+1 and put
% peak_i quenched to 0.

deblurWinLen=25; % unit: points.
for i=1:length(peaks)-1
    if peaks(i+1)-peaks(i)<deblurWinLen
        if x_out(peaks(i+1))>x_out(peaks(i))
            peaks(i)=0;
        else
            peaks(i+1)=peaks(i);
            peaks(i)=0;
        end
        peakNum=peakNum-1;
    end
end
peaks=peaks(peaks~=0);

% if debugFlag
%     plot(t,dx, ':', 'Color', [.25 .25 .25]);
% end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%			ascent = 0;
%			ascent_old = 0;
%			descent = 0;
%			descent_old = 0;
%			candidates = [];
%			check_candidates = false;
%			seekmode = false;
%			seekthresh_pos = x_out_med + devCoef * x_out_dev;
%			% seekthresh_neg = x_out_med - x_out_dev;
%			clear x_out_med;
%			clear x_out_dev;
%			minPeakHeight = 0;
%			
%			
%			peaks0 = zeros(1, 1000000);
%			numPeaks = 0;
%			
%			for k = 2 : length(dx)
%			
%			%		if debugFlag
%			%		hold on;
%			%	%     plot(k, ascent, 'wx');
%			%	%     plot(k, descent, 'yx');
%			%		plot(t(k), ascent, 'x','Color',[0.5 0 0]);
%			%		plot(t(k), descent, 'x', 'Color',[0 0.5 0]);
%			%		hold off;
%			%		end
%			    
%			    if dx(k) >= 0
%			        ascent = ascent + dx(k);
%			    else % dx(k) < 0
%			        descent = descent + dx(k);
%			    end
%			
%			    if ascent >= seekthresh_pos(k) || ascent_old >= seekthresh_pos(k)
%			        seekmode = true;
%			    else
%			        seekmode = false;
%			    end
%			
%			    if -descent >= ascent_old
%			        check_candidates = true;
%			        ascent_old = 0;
%			    end
%			
%			    if dx(k - 1) >= 0
%			        if dx(k) < 0 % slope change pos->neg
%			            if seekmode
%			                candidates = [candidates k];
%			                if debugFlag
%			                    hold on;
%			                    plot(t(candidates), x_out(candidates), '.r');
%			                    hold off;
%			                end
%			                check_candidates = true;
%			            end
%			
%			            ascent_old = ascent;
%			            ascent = 0;
%			        else % still ascending
%			        end
%			    else % dx(k - 1) < 0
%			        if dx(k) >= 0 % slope change neg->pos
%			            if seekmode
%			                ascent = ascent_old + descent;
%			            end
%			            
%			%             if ~seekmode && check_candidates
%			%                 [maxval, maxidx] = max(x_out(candidates));
%			%                 stem(candidates(maxidx), maxval, 'or');
%			%                 check_candidates = false;
%			%                 candidates = [];
%			%             end
%			
%			            ascent_old = 0;
%			            descent = 0;
%			        else % still descending
%			            % TODO:
%			            % nach n konsekutiven abstiegen (abh. zu vorherigen anstiegen)
%			            % kann man den letzten kandidaten als peak erachten (?)
%			% %             ascent = 0;
%			        end
%			    end
%			
%			    if ~seekmode && check_candidates
%			        [maxval, maxidx] = max(x_in(candidates));
%			        if maxval >= minPeakHeight 
%			            numPeaks = numPeaks + 1;
%			            peaks0(numPeaks) = candidates(maxidx);
%			%             stem(candidates(maxidx), maxval, 'or');
%			%             minPeakHeight = .05 * mean(x_in(peaks0));
%			        end
%			        check_candidates = false;
%			        candidates = [];
%			   end
%			end
%			
%			% peaks is the peak index vector.
%			peaks = peaks0(1 : numPeaks);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if debugFlag
    hold on;
%     plot(t,x_out_med, '-', 'Color', [0 .25 .5]);
    plot(t,seekthresh_pos, '-b');
%     plot(t,x_out_med - x_out_dev, '--', 'Color', [0 0 .25]);
    hold off;
    hold on;
    stem(t(peaks), x_in(peaks), 'or');
    hold off;

	saveas(gcf,['./temp/' file '_wavelet.fig']);

end


%	spm=60/(t(2)-t(1)); % samples per minute.
%	% len=int32(t(end)/60);
%	len=floor(t(end)/60);
%	if len==0
%	    peaksPerMin=0;
%	    return;
%	end
%	peaksPerMin=zeros(len,1);
%	for i=1:len
%	    peaksPerMin(i)=length(find((i-1)*spm+1<=peaks & peaks<=i*spm));
%	end

%	if debugFlag
%	    hold on;
%	medianPeakHeight = median(x_in(peaks));
%	% plot([1 length(x_in)], [medianPeakHeight medianPeakHeight], '--', 'Color', [.25 0 0]);
%	plot(t, [medianPeakHeight medianPeakHeight], '--', 'Color', [.5 0 0]);
%	stdDeviationPeakHeight = std(x_in(peaks));
%	plot(t, [medianPeakHeight + stdDeviationPeakHeight medianPeakHeight + stdDeviationPeakHeight], ':', 'Color', [.5 0 0]);
%	plot(t, [medianPeakHeight - stdDeviationPeakHeight medianPeakHeight - stdDeviationPeakHeight], ':', 'Color', [.5 0 0]);
%	hold off;
%	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tau = delta_mad * sqrt(2*log(n)/n);
%numPeaks

% function xMad=rollMad(x,halfLen,xMed)
% if nargin==2
% 	xMed=rollMedian(x,halfLen);
% end
% xMad=zeros(length(x),1);
% for k = 2+halfLen : length(x)-halfLen
% 	xSet=x(k-halfLen:k+halfLen);
% 	xMad(k)=median(abs(xSet-xMed(k)));
% % 	x_out_med(k) = median(x(k-halfLen : k+halfLen));
% %     % Better to use mad to estimate the scale.
% % % 	x_out_dev(k) = std(x_in(k-halfLen : k + halfLen));
% %     x_out_dev(k) = 1.4826*mad(x_in(k-halfLen : k+halfLen),1);
% end
% 
% % x_out_med(k + 1 : k + mm_points) = x_out_med(k);
% % x_out_dev(k + 1 : k + mm_points) = x_out_dev(k);
% % x_out_med = [ones(mm_points / 2, 1) * x_out_med(1); x_out_med(1 : end - mm_points / 2)];
% % x_out_dev = [ones(mm_points / 2, 1) * x_out_dev(1); x_out_dev(1 : end - mm_points / 2)];
% % x_out_med(1:halfLen)=ones(halfLen,1) * x_out_med(1+halfLen);
% % x_out_dev(1:halfLen)=ones(halfLen,1) * x_out_dev(1+halfLen);
% % x_out_med(length(x_out)-halfLen+1 : length(x_out))=ones(halfLen,1) * x_out_med(length(x_out)-halfLen);
% % x_out_dev(length(x_out)-halfLen+1 : length(x_out))=ones(halfLen,1) * x_out_dev(length(x_out)-halfLen);
% xMad(1:halfLen)=ones(halfLen,1) * xMad(1+halfLen);
% xMad(length(x)-halfLen+1 : length(x))=ones(halfLen,1) * xMad(length(x)-halfLen);
% 
% 
% function xMed=rollMedian(x,halfLen)
% % Input vector x, and halfLen. Output rAnswer=Sequence1;olling median in xMed.
% % 2*halfLen+1 is the length of the roling window.
% 
% sortSeq=x(1:1+2*halfLen);
% sortSeq=sort(sortSeq);
% xMed=zeros(length(x),1);
% xMed(1+halfLen)=sortSeq(1+halfLen);
% sortSeq=reshape(sortSeq,1,length(sortSeq));
% for k = 2+halfLen : length(x)-halfLen
% 	[minV,minIdx]=min(abs(sortSeq-x(k-1-halfLen)));
%     sortSeq=[x(k+halfLen) sortSeq(1:minIdx-1) sortSeq(minIdx+1:end)];
% %	sortSeq(find(sortSeq==x(k-1-halfLen)),1)=x(k+halfLen); % delete and insert.
% 	sortSeq=insertFirstSort(sortSeq);
% 	xMed(k)=sortSeq(1+halfLen);
% % 	x_out_med(k) = median(x(k-halfLen : k+halfLen));
% %     % Better to use mad to estimate the scale.
% % % 	x_out_dev(k) = std(x_in(k-halfLen : k + halfLen));
% %     x_out_dev(k) = 1.4826*mad(x_in(k-halfLen : k+halfLen),1);
% end
% 
% % x_out_med(k + 1 : k + mm_points) = x_out_med(k);
% % x_out_dev(k + 1 : k + mm_points) = x_out_dev(k);
% % x_out_med = [ones(mm_points / 2, 1) * x_out_med(1); x_out_med(1 : end - mm_points / 2)];
% % x_out_dev = [ones(mm_points / 2, 1) * x_out_dev(1); x_out_dev(1 : end - mm_points / 2)];
% % x_out_med(1:halfLen)=ones(halfLen,1) * x_out_med(1+halfLen);
% % x_out_dev(1:halfLen)=ones(halfLen,1) * x_out_dev(1+halfLen);
% % x_out_med(length(x_out)-halfLen+1 : length(x_out))=ones(halfLen,1) * x_out_med(length(x_out)-halfLen);
% % x_out_dev(length(x_out)-halfLen+1 : length(x_out))=ones(halfLen,1) * x_out_dev(length(x_out)-halfLen);
% xMed(1:halfLen)=ones(halfLen,1) * xMed(1+halfLen);
% xMed(length(x)-halfLen+1 : length(x))=ones(halfLen,1) * xMed(length(x)-halfLen);
% 
% function x=insertFirstSort(x)
% % x is a ascend-sorted sequence except for the first element. The function sort the first one into x.
% % Iterative version insertion based on 1binary search.
% %stackX=[2 length(x)];
% 
% x=reshape(x,1,length(x));
% minX=2;
% maxX=length(x);
% pos=0;
% while true
% 	mid=floor((minX+maxX)/2);
% 	if x(1)>=x(mid) && ( mid==length(x) || x(1)<=x(mid+1) )
% 		pos=mid;
% 		break;
% 	elseif x(1)>x(mid)
% 		minX=mid+1;
% 	else
% 		maxX=mid-1;
%     end
% end
% x=[x(2:pos) x(1) x(pos+1:end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fout = fopen(strcat('../Output of auto-processed Standard Data/',dcfname,'-peak_times.txt'),'w');
% fprintf(fout,'peaks = [%8.6E %8.6E %8.6E]\n', peaks)
% fclose(fout);
%save(strcat('../Output of auto-processed Standard Data/',dcfname,'-peak_times.txt'), 'peaks', '-ASCII');
%xlswrite(strcat('../Output of auto-processed Standard Data/',dcfname,'-peak_times.xls'), peaks);


% load testDDvsJN_gt;
% flags=round(5000*peaks_export);
% stem(flags, -.25*ones(1, length(flags)), 'g');
% 
% length(peaks_export)
% length(peaks)
