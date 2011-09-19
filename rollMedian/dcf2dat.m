function dcf2dat(dcfpathname)

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

[path file]=fileparts(dcfpathname);

fs = 1 / (t(2) - t(1));
mm_time = .25;%.05;%.25; % Seconds
mm_points = floor(fs * mm_time);
% mm_points must be odd now. Not even any more.
if mod(mm_points, 2) == 0
	mm_points = mm_points + 1;
end
halfLen=(mm_points-1)/2;
dataLen=length(x);

if ~exist('temp','dir')
	mkdir('temp');
end

fid=fopen(['temp/' file '.dat'],'wb');
%fid=fopen(['toRollMedian.dat'],'wb');
fwrite(fid, halfLen, 'uint32', 'l');
fwrite(fid, dataLen, 'uint32', 'l');
fwrite(fid, x_in, 'double', 'l'); % Little-endian.
fclose(fid);

