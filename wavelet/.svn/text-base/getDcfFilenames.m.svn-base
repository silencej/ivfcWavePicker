function filenames=getDcfFileNames
% filenames will always be a cell array.

[filename,pathname] = uigetfile({'*.dcf;*.DCF;','Dcf Files';'*.*','All'},'Select DCFs','multiselect','on');

if isequal(filename,0)
	exit('User Pressed Cancel.');
end
if ~iscell(filename)
	filenames=fullfile(pathname,filename);
	filenames={filenames};
else
	l=length(filename);
	filenames=cell(l,1);
	for i=1:l
		filenames(i)={[pathname filename{i}]};
	end
end

end
