function [data, data_type, StartTime, TimeIncrement] = readDcf(filename)
%[data, data_type, StartTime, TimeIncrement] = readDcf(filename)
% data: [time peakHeight].
% data_type: string. StartTime and TimeIncrement: double, its unit is second.
%
% readDcf will not smooth read-in data any more.

% Author: Wang Chaofeng @PICB, Axel Mosig @PICB.
% Website: http://www.picb.ac.cn/~axel

fid = fopen(filename,'rb');

% header chunk
MagicID_head = fread(fid,1,'int32');
Version = fread(fid,1,'int32');

% data chunk
MagicID_data = fread(fid,1,'int32');
Length = fread(fid,1,'int32');
Datatype = fread(fid,1,'int16');
TimeAxis = fread(fid,1,'int16');
AssignedTimeAxis = fread(fid,1,'int32'); % int (32? 16?)
StartTime = fread(fid,1,'double'); % double
TimeIncrement = fread(fid,1,'double'); % double
Scale = fread(fid,1,'double'); % double
Offset= fread(fid,1,'double');  % double
EngRangeMin = fread(fid,1,'double'); % double
EngRangeMax = fread(fid,1,'double'); % double
%EngUnitLength = fread(fid,1,'uint8'); % byte
%EngUnit = fread(fid,EngUnitLength,'*char'); % for new.
EngUnit = fread(fid,15,'*char'); % char[] for old.
%DescriptionLength = fread(fid,1,'uint8'); % byte
%Description = fread(fid,DescriptionLength,'*char'); % for new.
%Description = fread(fid,31,'*char'); % char[] (char[31]?) for old.
Description = fread(fid,31,'*char');
% data % byte[]

% dataNum = Length-sizeof()

% sprintf('magic ID: %x; Version: %d',MagicID_head,Version);
% sprintf('magic ID: %x; Length: %d',MagicID_data,Length);
% sprintf('Datatype = %d',Datatype);
% sprintf('TimeAxis = %d',TimeAxis);
% sprintf('AssignedTimeAxis = %d',AssignedTimeAxis); % int (32? 16?)
% sprintf('StartTime = %f',StartTime); % double
% sprintf('TimeIncrement = %f',TimeIncrement); % double
% sprintf('Scale = %f',Scale); % double
% sprintf('Offset = %f',Offset);  % double
% sprintf('EngRangeMin = %f',EngRangeMin); % double
% sprintf('EngRangeMax = %f',EngRangeMax); % double
% %sprintf('EngUnitLength = %u',EngUnitLength) % byte
% sprintf('EngUnit = %s',EngUnit); % char[15]
% %sprintf('DescriptionLength = %u',DescriptionLength) % byte
% sprintf('Description = %s',Description); % char[] (char[31]?)

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
        sprintf('unknown Datatype, check the endianness issue.')
        return;
end
% sprintf('type=%s; width=%d ',data_type,data_width);
fseek(fid,112,'bof');
data=fread(fid,inf,data_type);
time=zeros(length(data), 1);
time(1)=StartTime;
for i=2:length(data)
    time(i)=time(i-1) + TimeIncrement;
end
data=[time data];
%     data(:,2)=filter(ones(1,16)/16,1,data(:,2));
end
