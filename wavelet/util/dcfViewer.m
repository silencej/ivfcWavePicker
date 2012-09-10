function dcfViewer
% dcfViewer
% A GUI for viewing single or multiple dcf files in a window.

oldPath='.';
% dcfViewer.ini is also in user path...
if exist('./dcfViewer.ini','file')
    fid=fopen('./dcfViewer.ini','r');
    oldPath=fgetl(fid);
    fclose(fid);
    if ~isdir(oldPath)
        oldPath='.';
        movefile('dcfViewer.ini','dcfViewer.ini~');
    end
end

[files,paths] = uigetfile([oldPath filesep '*.dcf'],'Pick one or more DCF-file(s)',...
    'MultiSelect','on');
if isequal(files,0) || isequal(paths,0)
    %     disp('User pressed cancel.');
    return;
end

if iscell(files)
    files=files.'; % array transpose.
    paths={paths};
    paths=repmat(paths,length(files),1); % return only 1 path.
else
    files={files};
    paths={paths};
end

pathFile=strcat(paths,files);

figure;
% rand('twister',sum(100*clock));

len=length(pathFile);
axesHVec=zeros(len,1);
minX=0; maxX=0; minY=0; maxY=0;
for i=1:len
    subplot(len,1,i);
    [data Datatype StartTime TimeIncrement]=readDcf(pathFile{i});
%     filtLen=16;
%     data(:,2)=filtfilt(1/filtLen * ones(filtLen,1),1,data(:,2));
    plot(data(:,1),data(:,2));
    axesHVec(i)=gca;
    xl=xlim;
    yl=ylim;
    if maxX<xl(2)
        maxX=xl(2);
    end
    if minX>xl(1)
        minX=xl(1);
    end
    if maxY<yl(2)
        maxY=yl(2);
    end
    if minY>yl(1)
        minY=yl(1);
    end
    title(strrep(files{i},'_','\_'));
    disp(['--- ' pathFile{i} ' ---']);
    disp(['Datatype: ' Datatype '.']);
    disp(['StartTime: ' num2str(StartTime) ' sec.']);
    disp(['TimeIncrement: ' num2str(TimeIncrement) ' secs.']);
    disp('--- end ---');
end

linkaxes(axesHVec);
% axis auto;
xlim([minX maxX]);
ylim([minY maxY]);

% save path to ini file.
fid=fopen('dcfViewer.ini','w');
fprintf(fid,'%s',paths{1});
fclose(fid);
end