function figView

[files,paths] = uigetfile('*.fig','Pick one or more FIG-file(s)',...
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

len=length(pathFile);
axesHVec=1;
for i=1:len
    ah=subplot(len,1,i);
    importfig(pathFile{i},ah);
    title(pathFile{i},'Interpreter','none');
    axesHVec(i)=gca;
    yl=ylim;
    if i==1
        yl1=yl(1);
        yl2=yl(2);
    end
    if i~=1 && yl(1)<yl1
        yl1=yl(1);
    end
    if i~=1 && yl(2)>yl2
        yl2=yl(2);
    end
end

linkaxes(axesHVec);
axis auto;
ylim([yl1 yl2]);
% axis auto;

end