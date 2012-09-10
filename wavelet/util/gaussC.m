function [y] = gaussC(x,miu,height,width)
% [y] = gaussC(x,miu,height,width), creates the gaussian curve
% on x, which centers at miu, height tall and width of FWHM.
% NOTE: width is FWHM!
% miu, height and width could be vectors, in which case there will be lots
% of gaussian peaks.
% Default value: miu=0, height=1, width=3.
% y will be a column vector.
% 
% For Gaussian function:
% y = height * exp(-(x-miu)^2 / (2*sigma^2)).
% FWHM or width = 2 * sqrt(2*log(2)) * sigma;
% y = height * exp(-4*log(2) * (x-miu).^2 / width^2).

% The following is useless.
% For normal distribution:
% height = 1/(sigma*sqrt(2*pi));
% y = height * exp(-(x-miu).^2 .* (pi*height^2) );
%
% y = 1.0/(sigma*sqrt(2.0*pi)) * exp(-(x-miu).^2 ./ (2*sigma^2) );

% if nargin==1
%     miu=0;
%     sigma=1;
%     amp=1/(sqrt(2*pi));
% elseif nargin==2
%     sigma=1;
%     amp=1/(sqrt(2*pi));
% elseif nargin==3
%     amp=height;
%     sigma=1/(sqrt(2*pi)*amp);
% else
%     amp=height;
%     sigma=width/(2*sqrt(2*log(2)));
% end

if nargin<=1
    miu=0;
end
if nargin<=2
    height=1;
end
if nargin<=3
    width=3;
end

if size(x,2)>1 && size(x,1)==1
    x=x';
elseif size(x,2)>1 && size(x,1)>1
    error('gaussC error: input x is not a vector.');
end
if size(miu,2)>1
    miu=miu';
end
if size(height,2)>1
    height=height';
end
if size(width,2)>1
    width=width';
end

if length(miu)~=length(height) || length(height)~=length(width)
    error('gaussC: miu, height or width is of different length.');
end

l=length(miu);
if l==1
    y = height * exp(-4*log(2) * (x-miu).^2 / width^2);
    return;
end

yt=zeros(length(x),l);
for i=1:length(miu)
    yt(:,i) = height(i) * exp(-4*log(2) * (x-miu(i)).^2 / width(i)^2);
end
y=sum(yt,2); % sum yt into a column.

% y = amp * exp(-(x-miu).^2 ./ (2*sigma^2) );