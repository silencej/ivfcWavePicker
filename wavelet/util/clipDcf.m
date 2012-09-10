function clipDcf(headerSrc,startpoint,endpoint)
% clipDcf(src,startpoint,endpoint). src is the name of the original DCF
% file including path, startpoint and endpoint is the time range in
% seconds.
% Read the header information from headerScr (dcf) file, and write the
% [startpoint endpoint] into [headerSrc '_clip' startpoint '-' endpoint
% '.dcf'] afterwards.

headerSrcId = fopen(headerSrc,'rb');

% header chunk
MagicID_head = fread(headerSrcId,1,'int32');
Version = fread(headerSrcId,1,'int32');
% data chunk
MagicID_data = fread(headerSrcId,1,'int32');
Length = fread(headerSrcId,1,'int32');
Datatype = fread(headerSrcId,1,'int16');
TimeAxis = fread(headerSrcId,1,'int16');
AssignedTimeAxis = fread(headerSrcId,1,'int32');
StartTime = fread(headerSrcId,1,'double'); % double
TimeIncrement = fread(headerSrcId,1,'double'); % double
Scale = fread(headerSrcId,1,'double'); % double
Offset= fread(headerSrcId,1,'double');  % double
EngRangeMin = fread(headerSrcId,1,'double'); % double
EngRangeMax = fread(headerSrcId,1,'double'); % double
EngUnit = fread(headerSrcId,15,'*char'); %
Description = fread(headerSrcId,31,'*char');

switch Datatype
    case 2
        % short int data
        data_type='int16';
        data_width=2;
    case 3
        % integer data
        data_type='int32';
        data_width=4;
    case 4
        % single float data
        data_type='float';
        data_width=4;
    case 5
        % double float data
        data_type='double';
        data_width=8;
    case 17
        % single byte data
        data_type='uint8';
        data_width=1;
    otherwise
        sprintf('unknown Datatype')
        return
end

% startpoint and endpoint should be time (unit should be in seconds).
spIdx=startpoint/TimeIncrement + 1;
epIdx=endpoint/TimeIncrement + 1;

data=readDcf(headerSrc);
if startpoint<data(1,1) || endpoint>data(end,1)
    disp('Error: Range reaches out.');
end
dataInten=data(spIdx:epIdx,2);
% dataTime=startpoint:TimeIncrement:endpoint;
% data=[dataTime' dataInten];
data=dataInten;

StartTime=startpoint;

Length=(epIdx-spIdx+1)*data_width;

%% Output
[pathstr, filestr, ext] = fileparts(headerSrc);
if isempty(pathstr)
    outputFile=[filestr '_clip', ...
        num2str(startpoint) '-' num2str(endpoint) ext];
else
    outputFile=[pathstr filesep filestr '_clip', ...
        num2str(startpoint) '-' num2str(endpoint) ext];
end

% outputId = fopen('clip.dcf','wb');
outputId = fopen(outputFile,'wb');
% Write.
fwrite(outputId,MagicID_head,'int32');
fwrite(outputId,Version,'int32');
fwrite(outputId,MagicID_data,'int32');
fwrite(outputId,Length,'int32');
fwrite(outputId,Datatype,'int16');
fwrite(outputId,TimeAxis,'int16');
fwrite(outputId,AssignedTimeAxis,'int32');
fwrite(outputId,StartTime,'double');
fwrite(outputId,TimeIncrement,'double');
fwrite(outputId,Scale,'double');
fwrite(outputId,Offset,'double');
fwrite(outputId,EngRangeMin,'double');
fwrite(outputId,EngRangeMax,'double');
fwrite(outputId,EngUnit,'15*char'); %15
fwrite(outputId,Description,'31*char'); %31

fseek(outputId,112,'bof');
fwrite(outputId,data,data_type);
% time=zeros(length(data), 1);
% time(1)=StartTime;
% for i=2:length(data)
%     time(i)=time(i-1) + TimeIncrement;
% end
% data=[time data];
end
