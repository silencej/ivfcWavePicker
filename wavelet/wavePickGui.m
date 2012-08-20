function wavePickGui

debugFlag=1;

files=getDcfFilenames;
% files=getFilelist;

if files{1}==0
    return;
end

fprintf(1,'===========\nWavePickGui runs...\n');
for i=1:length(files)
    [peaks]=wavePick(files{i},debugFlag);
    matFile=strrep(files{i},'.dcf','.peaks.mat');
    save(matFile,'peaks');
    fprintf(1,'%s: %d.\n',files{i},size(peaks,2));
end