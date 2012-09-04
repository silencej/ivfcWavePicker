function wavePickGui

debugFlag=1;

files=getDcfFilenames;
% files=getFilelist;

if files{1}==0
    return;
end

fprintf(1,'===========\nWavePickGui runs...\n');

dateStr=date; % dd-mmm-yyyy
dateStr=dateStr(1:6); % dd-mmm
dateStr(3)=[]; % ddmmm
fid=fopen(['waveRes' dateStr '.txt'],'wt');
fprintf(fid,'Wavelet pick result\n\n');
fprintf(fid,'Filename\t\tCountNum\t\tSNR(dB)\n');

for i=1:length(files)
    [peaks snr]=wavePick(files{i},debugFlag);
    matFile=strrep(files{i},'.dcf','.peaks.mat');
    save(matFile,'peaks');
    fprintf(fid,'%s\t\t\t%d\t\t%.5f\n',files{i},length(peaks),snr);
    fprintf(1,'%s: %d.\n',files{i},size(peaks,2));
end