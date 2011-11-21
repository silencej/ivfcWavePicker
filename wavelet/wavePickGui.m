function wavePickGui

debugFlag=1;

files=getDcfFilenames;
if files{1}==0
    return;
end

for i=1:length(files)
    [peaks]=wavePick(files{i},debugFlag);
    matFile=strrep(files{i},'.dcf','.peaks.mat');
    save(matFile,peaks);
end