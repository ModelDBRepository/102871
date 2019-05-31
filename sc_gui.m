function varargout = sc_gui(varargin)
% sc_gui is a gui that lets you change various model parameters and then
% plot the results in comparison to the actual data. There is also an
% option to "save". It allows you to choose the file to save to and then
% outputs the data as ascii text files in that folder.

% SC_GUI M-file for sc_gui.fig
%      SC_GUI, by itself, creates a new SC_GUI or raises the existing
%      singleton*.
%
%      H = SC_GUI returns the handle to a new SC_GUI or the handle to
%      the existing singleton*.
%
%      SC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SC_GUI.M with the given input arguments.
%
%      SC_GUI('Property','Value',...) creates a new SC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sc_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sc_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sc_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sc_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before sc_gui is made visible.
function sc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sc_gui (see VARARGIN)


%%%%%% initialization %%%%%%%%%%%%


% Choose default command line output for sc_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sc_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.figure1,'Color',[.15 .25 .5])

figx = figure;
set(figx,'Position',[3 263 1277 685])
handles.figx = figx;
guidata(hObject, handles);


% initialization of rate constants
x = [0.025 1.5 1.12 3.7 0.4375 2.6 0.05 2.16 1.12 3.7 0.88 1.6 6 0.01 1 2.16 2.2 .01];

set(handles.x1,'string',x(1)); % C1 -> C2
set(handles.x2,'string',x(2)); % C2 -> C3
set(handles.x3,'string',x(3)); % C3 -> C4
set(handles.x4,'string',x(4)); % C4 -> C3
set(handles.x5,'string',x(5)); % C4 -> O1
set(handles.x6,'string',x(6)); % O1 -> C4
set(handles.x7,'string',x(7)); % C5 -> C6
set(handles.x8,'string',x(8)); % C6 -> C7
set(handles.x9,'string',x(9)); % C7 -> C8
set(handles.x10,'string',x(10)); % C8 -> C7
set(handles.x11,'string',x(11)); % C8 -> O2
set(handles.x12,'string',x(12)); % O2 -> C8
set(handles.x13,'string',x(13)); % O1 -> O2
set(handles.x14,'string',x(14)); % inactivation
set(handles.x15,'string',x(15)); % C1 -> C2 for EFa Ca
set(handles.x16,'string',x(16)); % C2 -> C3 for EFa Ca
% transition rates that govern O1 -> O2 transition
set(handles.alpha,'string',x(17));
set(handles.beta,'string',x(18));


c2f = .85; % percent of channels starting in the second closed state for EFa and EFb Ca
hpof = .35; % percent of Ca in high Po mode for EFa Ca
c2fba = .8; % percent of channels starting in the second closed state for Ba
pocfba = .932; % P(o) correction factor for EFa Ba++ (based on FL @ 100 msec)
flcfba = .988; % FL correction factor for EFa Ba++ (based on FL @ 150 msec)
pocfca = .916; % P(o) correction factor for EFa Ca++ (based on FL @ 100 msec)
flcfca = .931; % FL correction factor for EFa Ca++ (based on FL @ 150 msec)
pocfbca = .984; % P(o) correction factor for EFb Ca++ (based on FL @ 100 msec)
flcfbca = .998; % FL correction factor for EFb Ca++ (based on FL @ 150 msec)

set(handles.c2f,'string',c2f);
set(handles.hpof,'string',hpof);
set(handles.c2fba,'string',c2fba);
set(handles.pocfba,'string',pocfba);
set(handles.flcfba,'string',flcfba);
set(handles.pocfca,'string',pocfca);
set(handles.flcfca,'string',flcfca);
set(handles.pocfbca,'string',pocfbca);
set(handles.flcfbca,'string',flcfbca);

set(handles.r,'string',1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%% Generate & plot data

x = [str2num(get(handles.x1,'string'))      str2num(get(handles.x2,'string')) ...
        str2num(get(handles.x3,'string'))   str2num(get(handles.x4,'string')) ...
        str2num(get(handles.x5,'string'))   str2num(get(handles.x6,'string')) ...
        str2num(get(handles.x7,'string'))   str2num(get(handles.x8,'string')) ...
        str2num(get(handles.x9,'string'))   str2num(get(handles.x10,'string')) ...
        str2num(get(handles.x11,'string'))   str2num(get(handles.x12,'string')) ...
        str2num(get(handles.x13,'string'))    str2num(get(handles.x14,'string')) ...
        str2num(get(handles.x15,'string'))    str2num(get(handles.x16,'string')) ...
        str2num(get(handles.alpha,'string'))    str2num(get(handles.beta,'string'))];
disp(x);

x1 = x(1:6);
x2 = x([7:14 17:18]);
x1cdf = [x(15:16) x(3:6)];

sf =[];
[sf.c2f,sf.hpof,sf.c2fba,sf.pocfba,sf.flcfba,sf.pocfca,sf.flcfca,sf.pocfbca,sf.flcfbca] = deal( ...
    str2num(get(handles.c2f,'string')),str2num(get(handles.hpof,'string')),str2num(get(handles.c2fba,'string')), ...
    str2num(get(handles.pocfba,'string')),str2num(get(handles.flcfba,'string')),str2num(get(handles.pocfca,'string')), ...
    str2num(get(handles.flcfca,'string')),str2num(get(handles.pocfbca,'string')),str2num(get(handles.flcfbca,'string')));
disp(sf);

r = str2num(get(handles.r,'string'));

figure(handles.figx);

set(handles.percent_complete,'string','0%');
subplot(6,3,1); cla; [po_model,tspan] = setup_sc(x1,'ba','po','nopre',x2,1,sf,r);
subplot(6,3,4); cla; [po_model,tspan] = setup_sc(x1,'ba','po','pre',x2,1,sf,r);
set(handles.percent_complete,'string','11%');
subplot(6,3,2); cla; [po_model,tspan] = setup_sc(x1,'ba','poo','nopre',x2,1,sf,r);
subplot(6,3,5); cla; [po_model,tspan] = setup_sc(x1,'ba','poo','pre',x2,1,sf,r);
set(handles.percent_complete,'string','22%');
subplot(6,3,3); cla; [po_model,tspan] = setup_sc(x1,'ba','fl','nopre',x2,1,sf,r);
subplot(6,3,6); cla; [po_model,tspan] = setup_sc(x1,'ba','fl','pre',x2,1,sf,r);
set(handles.percent_complete,'string','33%');
subplot(6,3,7); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','po','nopre',x2,1,sf,r);
subplot(6,3,10); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','po','pre',x2,1,sf,r);
set(handles.percent_complete,'string','44%');
subplot(6,3,8); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','poo','nopre',x2,1,sf,r);
subplot(6,3,11); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','poo','pre',x2,1,sf,r);
set(handles.percent_complete,'string','56%');
subplot(6,3,9); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','fl','nopre',x2,1,sf,r);
subplot(6,3,12); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','fl','pre',x2,1,sf,r);
set(handles.percent_complete,'string','67%');
subplot(6,3,13); cla; [po_model,tspan] = setup_sc(x2,'ca','po','nopre',x1cdf,1,sf,r);
subplot(6,3,16); cla; [po_model,tspan] = setup_sc(x2,'ca','po','pre',x1cdf,1,sf,r);
set(handles.percent_complete,'string','78%');
subplot(6,3,14); cla; [po_model,tspan] = setup_sc(x2,'ca','poo','nopre',x1cdf,1,sf,r);
subplot(6,3,17); cla; [po_model,tspan] = setup_sc(x2,'ca','poo','pre',x1cdf,1,sf,r);
set(handles.percent_complete,'string','89%');
subplot(6,3,15); cla; [po_model,tspan] = setup_sc(x2,'ca','fl','nopre',x1cdf,1,sf,r);
subplot(6,3,18); cla; [po_model,tspan] = setup_sc(x2,'ca','fl','pre',x1cdf,1,sf,r);
set(handles.percent_complete,'string','100%');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% Plot open times

x = [str2num(get(handles.x1,'string'))      str2num(get(handles.x2,'string')) ...
        str2num(get(handles.x3,'string'))   str2num(get(handles.x4,'string')) ...
        str2num(get(handles.x5,'string'))   str2num(get(handles.x6,'string')) ...
        str2num(get(handles.x7,'string'))   str2num(get(handles.x8,'string')) ...
        str2num(get(handles.x9,'string'))   str2num(get(handles.x10,'string')) ...
        str2num(get(handles.x11,'string'))   str2num(get(handles.x12,'string')) ...
        str2num(get(handles.x13,'string'))   str2num(get(handles.x14,'string')) ...
        str2num(get(handles.x15,'string'))    str2num(get(handles.x16,'string')) ...
        str2num(get(handles.alpha,'string'))    str2num(get(handles.beta,'string'))];
disp(x);

x1 = x(1:6);
x2 = x([7:14 17:18]);
x1cdf = [x(15:16) x(3:6)];

sf =[];
[sf.c2f,sf.hpof,sf.c2fba,sf.pocfba,sf.flcfba,sf.pocfca,sf.flcfca,sf.pocfbca,sf.flcfbca] = deal( ...
    str2num(get(handles.c2f,'string')),str2num(get(handles.hpof,'string')),str2num(get(handles.c2fba,'string')), ...
    str2num(get(handles.pocfba,'string')),str2num(get(handles.flcfba,'string')),str2num(get(handles.pocfca,'string')), ...
    str2num(get(handles.flcfca,'string')),str2num(get(handles.pocfbca,'string')),str2num(get(handles.flcfbca,'string')));
disp(sf);

r = str2num(get(handles.r,'string'));

figure
subplot(2,1,1); cla; [po_model,tspan] = setup_sc(x1,'ba','ot','nopre',x2,1,sf,r);
subplot(2,1,2); cla; [po_model,tspan] = setup_sc(x2,'ca','ot','nopre',x1cdf,1,sf,r);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%% generate & SAVE DATA

dirname = uigetdir('c:','Choose a destination folder for dumping of the files');

x = [str2num(get(handles.x1,'string'))      str2num(get(handles.x2,'string')) ...
        str2num(get(handles.x3,'string'))   str2num(get(handles.x4,'string')) ...
        str2num(get(handles.x5,'string'))   str2num(get(handles.x6,'string')) ...
        str2num(get(handles.x7,'string'))   str2num(get(handles.x8,'string')) ...
        str2num(get(handles.x9,'string'))   str2num(get(handles.x10,'string')) ...
        str2num(get(handles.x11,'string'))   str2num(get(handles.x12,'string')) ...
        str2num(get(handles.x13,'string'))    str2num(get(handles.x14,'string')) ...
        str2num(get(handles.x15,'string'))    str2num(get(handles.x16,'string')) ...
        str2num(get(handles.alpha,'string'))    str2num(get(handles.beta,'string'))];
disp(x);

x1 = x(1:6);
x2 = x([7:14 17:18]);
x1cdf = [x(15:16) x(3:6)];

sf =[];
[sf.c2f,sf.hpof,sf.c2fba,sf.pocfba,sf.flcfba,sf.pocfca,sf.flcfca,sf.pocfbca,sf.flcfbca] = deal( ...
    str2num(get(handles.c2f,'string')),str2num(get(handles.hpof,'string')),str2num(get(handles.c2fba,'string')), ...
    str2num(get(handles.pocfba,'string')),str2num(get(handles.flcfba,'string')),str2num(get(handles.pocfca,'string')), ...
    str2num(get(handles.flcfca,'string')),str2num(get(handles.pocfbca,'string')),str2num(get(handles.flcfbca,'string')));
disp(sf);

r = str2num(get(handles.r,'string'));

figure(handles.figx);

set(handles.percent_complete,'string','0%');
subplot(6,3,1); cla; [po_model,tspan] = setup_sc(x1,'ba','po','nopre',x2,1,sf,r);
poAll = zeros(length(po_model),7);
poAll(:,1) = tspan;
poAll(:,2) = po_model(:,5)+po_model(:,10);

subplot(6,3,4); cla; [po_model,tspan] = setup_sc(x1,'ba','po','pre',x2,1,sf,r);
poAll(:,3) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','11%');
subplot(6,3,2); cla; [po_model,tspan] = setup_sc(x1,'ba','poo','nopre',x2,1,sf,r);
pooAll = zeros(length(po_model),7);
pooAll(:,1) = tspan;
pooAll(:,2) = po_model(:,5)+po_model(:,10);

subplot(6,3,5); cla; [po_model,tspan] = setup_sc(x1,'ba','poo','pre',x2,1,sf,r);
pooAll(:,3) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','22%');
subplot(6,3,3); cla; [po_model,tspan] = setup_sc(x1,'ba','fl','nopre',x2,1,sf,r);
flAll = zeros(length(po_model),7);
flAll(:,1) = tspan;
flAll(:,2) = po_model(:,5)+po_model(:,10);

subplot(6,3,6); cla; [po_model,tspan] = setup_sc(x1,'ba','fl','pre',x2,1,sf,r);
flAll(:,3) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','33%');
subplot(6,3,7); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','po','nopre',x2,1,sf,r);
poAll(:,4) = po_model(:,5)+po_model(:,10);

subplot(6,3,10); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','po','pre',x2,1,sf,r);
poAll(:,5) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','44%');
subplot(6,3,8); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','poo','nopre',x2,1,sf,r);
pooAll(:,4) = po_model(:,5)+po_model(:,10);

subplot(6,3,11); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','poo','pre',x2,1,sf,r);
pooAll(:,5) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','56%');
subplot(6,3,9); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','fl','nopre',x2,1,sf,r);
flAll(:,4) = po_model(:,5)+po_model(:,10);

subplot(6,3,12); cla; [po_model,tspan] = setup_sc(x1,'ca_efb','fl','pre',x2,1,sf,r);
flAll(:,5) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','67%');
subplot(6,3,13); cla; [po_model,tspan] = setup_sc(x2,'ca','po','nopre',x1cdf,1,sf,r);
poAll(:,6) = po_model(:,5)+po_model(:,10);

subplot(6,3,16); cla; [po_model,tspan] = setup_sc(x2,'ca','po','pre',x1cdf,1,sf,r);
poAll(:,7) = po_model(:,5)+po_model(:,10);


set(handles.percent_complete,'string','78%');
subplot(6,3,14); cla; [po_model,tspan] = setup_sc(x2,'ca','poo','nopre',x1cdf,1,sf,r);
pooAll(:,6) = po_model(:,5)+po_model(:,10);

subplot(6,3,17); cla; [po_model,tspan] = setup_sc(x2,'ca','poo','pre',x1cdf,1,sf,r);
pooAll(:,7) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','89%');
subplot(6,3,15); cla; [po_model,tspan] = setup_sc(x2,'ca','fl','nopre',x1cdf,1,sf,r);
flAll(:,6) = po_model(:,5)+po_model(:,10);

subplot(6,3,18); cla; [po_model,tspan] = setup_sc(x2,'ca','fl','pre',x1cdf,1,sf,r);
flAll(:,7) = po_model(:,5)+po_model(:,10);

figure
subplot(2,1,1); cla; [po_model,tspan] = setup_sc(x1,'ba','ot','nopre',x2,1,sf,r);
otAll = zeros(length(po_model),3);
otAll(:,1) = tspan;
otAll(:,2) = po_model(:,5)+po_model(:,10);

subplot(2,1,2); cla; [po_model,tspan] = setup_sc(x2,'ca','ot','nopre',x1cdf,1,sf,r);
otAll(:,3) = po_model(:,5)+po_model(:,10);

set(handles.percent_complete,'string','100%');

% x
% sf
% poAll
% pooAll
% flAll
% otAll

save([dirname '\x.txt'],'x','-ascii')
sfvalues = [sf.c2f,sf.hpof,sf.c2fba,sf.pocfba,sf.flcfba,sf.pocfca,sf.flcfca,sf.pocfbca,sf.flcfbca];
save([dirname '\sf.txt'],'sfvalues','-ascii')
save([dirname '\po.txt'],'poAll','-ascii')
save([dirname '\poo.txt'],'pooAll','-ascii')
save([dirname '\fl.txt'],'flAll','-ascii')
save([dirname '\opentimes.txt'],'otAll','-ascii')


disp(sprintf(['The following files have been successfully saved:\n   x.txt: the model parameters\n   sf.txt: various starting fractions\n' ...
        '   po.txt: model p(open)\n   poo.txt: model p(o|o)\n   fl.txt: model first latencies\n   opentimes.txt: model open times\n' ...
        '\nFor po, poo, and fl, the text document contains 7 columns. Column 1 is the time matrix, columns 2&3 are EFa Ba nopre/+pre,\n' ...
        'columns 4&5 are EFb Ca nopre/+pre, and columns 6&7 are EFa Ca nopre/+pre.\n' ...
        'For open times, the text file has 3 columns. Column 1 is time, 2 is w/o CDF, and 3 is w/CDF.']));



































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   THE REST ISN'T MODIFIED   %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Outputs from this function are returned to the command line.
function varargout = sc_gui_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function x1_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x1 as text
%        str2double(get(hObject,'String')) returns contents of x1 as a double


% --- Executes during object creation, after setting all properties.
function x2_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x2_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x2 as text
%        str2double(get(hObject,'String')) returns contents of x2 as a double


% --- Executes during object creation, after setting all properties.
function x3_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x3_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x3 as text
%        str2double(get(hObject,'String')) returns contents of x3 as a double


% --- Executes during object creation, after setting all properties.
function x4_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x4_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x4 as text
%        str2double(get(hObject,'String')) returns contents of x4 as a double


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function x5_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x5_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x5 as text
%        str2double(get(hObject,'String')) returns contents of x5 as a double


% --- Executes during object creation, after setting all properties.
function x6_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x6_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x6 as text
%        str2double(get(hObject,'String')) returns contents of x6 as a double


% --- Executes during object creation, after setting all properties.
function x7_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x7_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x7 as text
%        str2double(get(hObject,'String')) returns contents of x7 as a double


% --- Executes during object creation, after setting all properties.
function x8_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x8_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x8 as text
%        str2double(get(hObject,'String')) returns contents of x8 as a double


% --- Executes during object creation, after setting all properties.
function x9_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x9_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x9 as text
%        str2double(get(hObject,'String')) returns contents of x9 as a double


% --- Executes during object creation, after setting all properties.
function x10_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x10_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x10 as text
%        str2double(get(hObject,'String')) returns contents of x10 as a double


% --- Executes during object creation, after setting all properties.
function x11_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function x11_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x11 as text
%        str2double(get(hObject,'String')) returns contents of x11 as a double


% --- Executes during object creation, after setting all properties.
function x12_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x12_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x12 as text
%        str2double(get(hObject,'String')) returns contents of x12 as a double


% --- Executes during object creation, after setting all properties.
function x13_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x13_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x13 as text
%        str2double(get(hObject,'String')) returns contents of x13 as a double


% --- Executes during object creation, after setting all properties.
function c2f_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function c2f_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of c2f as text
%        str2double(get(hObject,'String')) returns contents of c2f as a double


% --- Executes during object creation, after setting all properties.
function hpof_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function hpof_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of hpof as text
%        str2double(get(hObject,'String')) returns contents of hpof as a double


% --- Executes during object creation, after setting all properties.
function c2fba_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function c2fba_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of c2fba as text
%        str2double(get(hObject,'String')) returns contents of c2fba as a double


% --- Executes during object creation, after setting all properties.
function pocfba_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function pocfba_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of pocfba as text
%        str2double(get(hObject,'String')) returns contents of pocfba as a double


% --- Executes during object creation, after setting all properties.
function pocfca_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function pocfca_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of pocfca as text
%        str2double(get(hObject,'String')) returns contents of pocfca as a double


% --- Executes during object creation, after setting all properties.
function pocfbca_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function pocfbca_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of pocfbca as text
%        str2double(get(hObject,'String')) returns contents of pocfbca as a double


% --- Executes during object creation, after setting all properties.
function flcfba_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function flcfba_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of flcfba as text
%        str2double(get(hObject,'String')) returns contents of flcfba as a double


% --- Executes during object creation, after setting all properties.
function flcfca_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function flcfca_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of flcfca as text
%        str2double(get(hObject,'String')) returns contents of flcfca as a double


% --- Executes during object creation, after setting all properties.
function flcfbca_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function flcfbca_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of flcfbca as text
%        str2double(get(hObject,'String')) returns contents of flcfbca as a double


% --- Executes during object creation, after setting all properties.
function x15_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x15_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x15 as text
%        str2double(get(hObject,'String')) returns contents of x15 as a double


% --- Executes during object creation, after setting all properties.
function x16_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function x16_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x16 as text
%        str2double(get(hObject,'String')) returns contents of x16 as a double


function x14_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of x14 as text
%        str2double(get(hObject,'String')) returns contents of x14 as a double


% --- Executes during object creation, after setting all properties.
function x14_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function alpha_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function beta_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of beta as text
%        str2double(get(hObject,'String')) returns contents of beta as a double


% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function r_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of r as text
%        str2double(get(hObject,'String')) returns contents of r as a double


% --- Executes during object creation, after setting all properties.
function r_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


