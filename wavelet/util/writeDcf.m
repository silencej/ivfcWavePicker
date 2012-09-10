function writeDcf(data,outputFile)
%writeDcf(data), write data in DCF file.
%
%   data should have 2 columns [time peakHeight].
%   For faking DCF data, timeIncrement is suggested to be 0.0002.
%   User will be promoted to input saveout filename.

%   Author: Wang Chaofeng @PICB, Axel Mosig @PICB.
%   Website: http://www.picb.ac.cn/~axel

if size(data,2)~=2
    disp('The input data should have strictly 2 columns.');
    return;
end
TimeIncrement=data(2,1)-data(1,1); % TimeIncrement.
if data(3,1)-data(2,1)~=TimeIncrement
    disp('The first column of data should be equally spaced time.');
    return;
end

Length=double(data(end,1)-data(1,1))/double(TimeIncrement) + 1.0; % Length.

% [filestr, pathstr] = uiputfile('*.dcf', 'Save data in ...');
% outputFile=[pathstr filesep filestr];

outputId = fopen(outputFile,'wb');
if outputId==-1
    disp([outputFile ' can''t be opened.']);
    return;
end

% Write.
fwrite(outputId,1213027399,'int32'); % MagicID_head.
fwrite(outputId,1,'int32'); % Version.
fwrite(outputId,1145918535,'int32'); % MagicID_data.
fwrite(outputId,Length,'int32'); % Length. ~~
fwrite(outputId,5,'int16'); % Datatype = 5, ��double��.
fwrite(outputId,0,'int16'); % TimeAxis.
fwrite(outputId,-1,'int32'); % AssignedTimeAxis.
fwrite(outputId,data(1,1),'double'); % StartTime. ~~
fwrite(outputId,TimeIncrement,'double'); % TimeIncrement. ~~
fwrite(outputId,1,'double'); % Scale.
fwrite(outputId,0,'double'); % Offset.
fwrite(outputId,-10,'double'); % EngRangeMin.
fwrite(outputId,10,'double'); % EngRangeMax.
fwrite(outputId,'V@     |�� ?@ 	','15*char'); % EngUnit
fwrite(outputId,'Channel 0  ����                  ','31*char'); % Description

fseek(outputId,112,'bof');
fwrite(outputId,data(:,2),'double');

end