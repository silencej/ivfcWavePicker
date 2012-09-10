function output=smoothWcf(input,windowLen)
% output=smoothWcf(input,windowLen)
% output is a column vector.
% The windowLen should be odd. If it is even, then windowLen = windowLen+1.
% Calculate the smoothed input with rolling median in windowLen. The output will not shift.
% And the first and end (windowLen+1)/2 are the same.


if nargin==0
    data=readDcf('../data/0-15min_clip0-300_clip0-50.dcf');
    input=data(:,2);
    windowLen=1001;
end

if ~mod(windowLen,2)
    windowLen=windowLen+1;
end

% Make sure input is column vector.
if size(input,2)>1
    input=input';
end

% output2=filtfilt(1.0/windowLen*ones(windowLen,1),1,input);

% Border-replication.
rad=radius(windowLen);
temp=[input(rad:-1:1); input; input(length(input)-rad:end)];
output=arrayfun(@avg,rad+1:length(temp)-rad-1);
output=output';

% figure,hold on; plot(input,'-k'); plot(output, '-r'); plot(output2,'-b'); hold off;

function r=radius(l)
% Input window length, and i will give you the radius. Center=1+radius.
r=(l-1)/2;
end

function output=avg(i)
% output=mean(temp(i-rad:i+rad));
output=median(temp(i-rad:i+rad));
end

end