function f=gaussfirWcf(L)
% Calculate the stardard gaussian coeffients according to the gaussian function.
% Idea: according to the ref, the window size is 3*\sigma+1.
% f=gaussfirWcf(L). L is the window length.

% Reference: http://www.librow.com/articles/article-9

if ~mod(L,2)
	L=L+1;
end

% s is sigma.
s=(L-1)/6.0; % s = (L-1)/(3.0*2)

x=(-3*s:3*s);
f=1/(sqrt(2*pi)*s)*exp(-x.^2/(2*s^2));
f=f/sum(f);
