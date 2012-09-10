function varargout = view(varargin)
% VIEW M-file for view.fig
%
%       The function name should be dcfView, but the wrong name is
%       historically settled and can't be changed back.
%       Files needed: readDcf.m, 
%
%      H = VIEW returns the handle to a new VIEW or the handle to
%      the existing singleton*.
%
%      VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW.M with the given input arguments.
%
%      VIEW('Property','Value',...) creates a new VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_OpeningFcn via varargin.

% Last Modified by GUIDE v2.5 21-Jan-2009 21:13:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @view_OpeningFcn, ...
    'gui_OutputFcn',  @view_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before view is made visible.
function view_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view (see VARARGIN)


% Choose default command line output for view
handles.output = hObject;

% Wangcf:
% handles.path = pwd; % For keeping trace of previously opened directory.
handles.path='.';
if exist('dcfView.ini','file')
    fid=fopen('dcfView.ini','r');
    handles.path=fgetl(fid);
    fclose(fid);
    if ~isdir(handles.path)
        handles.path='.';
        movefile('dcfViewer.ini','dcfViewer.ini~');
    end
end
legend('boxoff');
handles.legendS1='RedLine';
handles.legendS2='GreenLine';
handles.legendS3='BlueLine';
handles.line1h=line('XData',0,'YData',0,'Color','r','Visible','off');
handles.line2h=line('XData',0,'YData',0,'Color','g','Visible','off');
handles.line3h=line('XData',0,'YData',0,'Color','b','Visible','off');
legend([handles.line1h handles.line2h handles.line3h],handles.legendS1,handles.legendS2,handles.legendS3);

% hold(handles.axes1);
axes(handles.axes1);
hold on;
title('Dcf data overlap together');
xlabel('Time(s)');
ylabel('Intensity(AU)');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function cf1_Callback(hObject, eventdata, handles)
[file1, path1] = uigetfile([handles.path filesep '*.dcf'], 'Pick a DCF-file');
if isequal(file1,0) || isequal(path1,0)
    disp('User pressed cancel.');
    return
end
handles.path=path1;
data1 = readDcf(fullfile(path1, file1));
if ~isfield(handles,'line1h') || ~ishandle(handles.line1h)
    throw(ME('cf1_Callback Error','line1h is broken.'));
end

set(handles.line1h,'XData',data1(:,1),'YData',data1(:,2),'Color','r','Visible','on');

set(handles.filename1, 'String', file1);
set(handles.checkbox1, 'Value', get(handles.checkbox1,'Max'));

handles.legendS1=file1;
legend([handles.line1h handles.line2h handles.line3h],handles.legendS1,handles.legendS2,handles.legendS3);

% save path to ini file.
fid=fopen('dcfView.ini','w');
fprintf(fid,'%s',handles.path);
fclose(fid);

guidata(hObject, handles);

function cf2_Callback(hObject, eventdata, handles)
[file2, path2] = uigetfile([handles.path filesep '*.dcf'], 'Pick a DCF-file');
if isequal(file2,0) || isequal(path2,0)
    disp('User pressed cancel.');
    return
end
handles.path=path2;
data2 = readDcf(fullfile(path2, file2));
if ~isfield(handles,'line2h') || ~ishandle(handles.line2h)
    throw(ME('cf1_Callback Error','line1h is broken.'));
end

set(handles.line2h,'XData',data2(:,1),'YData',data2(:,2),'Color','g','Visible','on');

set(handles.filename2, 'String', file2);
set(handles.checkbox2, 'Value', get(handles.checkbox2,'Max'));

handles.legendS2=file2;
legend([handles.line1h handles.line2h handles.line3h],handles.legendS1,handles.legendS2,handles.legendS3);

% save path to ini file.
fid=fopen('dcfView.ini','w');
fprintf(fid,'%s',handles.path);
fclose(fid);

guidata(hObject, handles);

function cf3_Callback(hObject, eventdata, handles)
[file3, path3] = uigetfile([handles.path filesep '*.dcf'], 'Pick a DCF-file');
if isequal(file3,0) && isequal(path3,0)
    disp('User pressed cancel.');
    return
end
handles.path=path3;
data3 = readDcf(fullfile(path3, file3));
if ~isfield(handles,'line3h') || ~ishandle(handles.line3h)
    throw(ME('cf1_Callback Error','line1h is broken.'));
end

set(handles.line3h,'XData',data3(:,1),'YData',data3(:,2),'Color','b','Visible','on');

set(handles.filename3, 'String', file3);
set(handles.checkbox3, 'Value', get(handles.checkbox3,'Max'));

handles.legendS3=file3;
legend([handles.line1h handles.line2h handles.line3h],handles.legendS1,handles.legendS2,handles.legendS3);

% save path to ini file.
fid=fopen('dcfView.ini','w');
fprintf(fid,'%s',handles.path);
fclose(fid);

guidata(hObject, handles);

function checkbox1_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max')) % Checked.
    if isfield(handles,'line1h')
        set(handles.line1h, 'Visible', 'on');
    end
else
    if isfield(handles,'line1h')
        set(handles.line1h, 'Visible', 'off');
    end
end

function checkbox2_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max')) % Checked.
    if isfield(handles,'line2h')
        set(handles.line2h, 'Visible', 'on');
    end
else
    if isfield(handles,'line2h')
        set(handles.line2h, 'Visible', 'off');
    end
end

function checkbox3_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max')) % Checked.
    if isfield(handles,'line3h')
        set(handles.line3h, 'Visible', 'on');
    end
else
    if isfield(handles,'line3h')
        set(handles.line3h, 'Visible', 'off');
    end
end
