function noise=awgnWcf(x,snr)
% y=awgnWcf(x,snr)
% Generate additive white gaussian noise depending on signal x and snr.
% snr is defined to be 10log_10(Power_sig/Power_noise), and defaults to 0dB, which indicates an equal power between signal and noise.

% Reference:
% http://www.gaussianwaves.com/2010/02/generating-a-signal-waveform-with-required-snr-in-matlab-2/

% Now the signal is assumed constant.
% The noise is not assumed constant and is generated by randn(length(x)). The noise is scaled according to the snr in dB.

% Ensure colume vector.
if size(x,2)~=1
	x=x';
end

if size(x,2)~=1
	error('awgnWcf: input x is not a vector!');
end

if nargin<2
	snr=0;
end
% if nargin<3
%	 sigPower=1;
% end

% Default parameters.
% imp = 1; % Impedance R of the noise source. P=U^2/R.

%
pr=10^(snr/10);

sigPower = sum(abs(x(:)).^2)/length(x(:));
noisePower = sigPower/pr;

% noise = sqrt(imp*noisePower)*randn(size(x));
noise = sqrt(noisePower)*randn(size(x));

