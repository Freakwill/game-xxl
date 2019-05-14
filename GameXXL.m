function varargout = GameXXL(varargin)
% GAMEXXL M-file for GameXXL.fig
%      GAMEXXL, by itself, creates a new GAMEXXL or raises the existing
%      singleton*.
%
%      H = GAMEXXL returns the handle to a new GAMEXXL or the handle to
%      the existing singleton*.
%
%      GAMEXXL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMEXXL.M with the given input arguments.
%
%      GAMEXXL('Property','Value',...) creates a new GAMEXXL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GameXXL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GameXXL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GameXXL

% Last Modified by GUIDE v2.5 23-May-2016 18:13:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GameXXL_OpeningFcn, ...
                   'gui_OutputFcn',  @GameXXL_OutputFcn, ...
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


% --- Executes just before GameXXL is made visible.
function GameXXL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GameXXL (see VARARGIN)

% Choose default command line output for GameXXL
handles.output = hObject;
rows=7;
cols=7;
handles.currentData.size=[rows,cols];
g = Game(rows,cols,handles.aGame);
handles.currentData.record=g;
handles.currentData.bg = g.draw_bg();
g=g.init();
handles.currentData.game=g;
handles.currentData.ht=g.draw_text();
handles.currentData.score = 0;
handles.currentData.n=1;
handles.currentData.action=[];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GameXXL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GameXXL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbInit.
function pbInit_Callback(hObject, eventdata, handles)
% hObject    handle to pbInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=handles.currentData.game;
g=g.init();
handles.currentData.game=g;
try
    delete(handles.currentData.ht);
catch
end
handles.currentData.ht=g.draw_text();
handles.currentData.record=[handles.currentData.record, g];
handles.currentData.n = length(handles.currentData.record);
set(handles.pbPrior,'Enable','on');
set(handles.pbStart,'Enable','on');
set(handles.pbExecute,'Enable','off');
set(handles.pbDemo,'Enable','off');
set(handles.eCommand,'Enable','inactive');
set(handles.pbPrompt,'Enable','off');
set(handles.eInformation,'String', '');
guidata(hObject, handles);

% --- Executes on button press in pbStart.
function pbStart_Callback(hObject, eventdata, handles)
% hObject    handle to pbStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=handles.currentData.game;
[g,v] = g.start();
delete(handles.currentData.ht);
handles.currentData.ht = g.draw_text();
handles.currentData.game = g;
handles.currentData.score = v;
set(handles.pbExecute,'Enable','on');
set(handles.pbDemo,'Enable','on');
set(handles.eCommand,'Enable','on');
set(handles.pbPrompt,'Enable','on');
if v>=6
    set(handles.eInformation,'String', sprintf('开局得%d分, 你真幸运',v));
    h=text('Parent',handles.aGame,'Position',handles.currentData.size/2,'HorizontalAlignment','center','String','Perfect','Color','m','FontSize',30);
    pause(.5);
    delete(h);
elseif v==0
    set(handles.eInformation,'String', '开局不利，没有得分');
else
    set(handles.eInformation,'String', sprintf('开局得%d分',v));
    h=text('Parent',handles.aGame,'Position',handles.currentData.size/2,'HorizontalAlignment','center','String','Good','Color','m','FontSize',30);
    pause(.5);
    delete(h);
end
guidata(hObject, handles);

% --- Executes on button press in pbDemo.
function pbDemo_Callback(hObject, eventdata, handles)
% hObject    handle to pbDemo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.eInformation,'String', '思考中...');
g=handles.currentData.game;
ht=handles.currentData.ht;
[v, p]=g.get_value(g.current_node);
for k=1:2:length(p)-2
    delete(ht);
    ht = g.draw_text(p{k});
    set(handles.eInformation, 'String', g.action2str(p{k+1}));
    pause(.6);
    set(handles.eInformation,'String', '思考中...');
    pause(.2)
end
delete(ht);
ht = g.draw_text(p{end});
pause(.8);
handles.currentData.ht=ht;
handles.currentData.game=g;
handles.currentData.score =handles.currentData.score + v;
handles=gameover(handles);
guidata(hObject, handles);

function eInformation_Callback(hObject, eventdata, handles)
% hObject    handle to eInformation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eInformation as text
%        str2double(get(hObject,'String')) returns contents of eInformation as a double


% --- Executes during object creation, after setting all properties.
function eInformation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eInformation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eCommand_Callback(hObject, eventdata, handles)
% hObject    handle to eCommand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eCommand as text
%        str2double(get(hObject,'String')) returns contents of eCommand as a double

% guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eCommand_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eCommand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on eCommand and none of its controls.
function eCommand_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to eCommand (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

a=eventdata.Key;
if strcmpi(a,'return')
    handle.currentData.action = parsemat(get(hObject,'String'));
    handles=execute(handles);
end
guidata(hObject, handles);


% --- Executes on button press in pbPrompt.
function pbPrompt_Callback(hObject, eventdata, handles)
% hObject    handle to pbPrompt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

g=handles.currentData.game;
actions=g.get_actions();
try
    k=randi([1,length(actions)]);
    action=actions{k};
    set(handles.eCommand,'String', mat2str(action));
    set(handles.eInformation,'String', ['select', mat2str(action),sprintf('from %d actions',length(actions))]);
    set(handles.currentData.ht(action(1,1),action(1,2)), 'Color', 'r');
    set(handles.currentData.ht(action(2,1),action(2,2)), 'Color', 'r');
catch
    handles=gameover(handles);
end
guidata(hObject, handles);


% --- Executes on button press in pbExecute.
function pbExecute_Callback(hObject, eventdata, handles)
% hObject    handle to pbExecute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentData.action = parsemat(get(handles.eCommand,'String'));
handles=execute(handles);
guidata(hObject, handles);


% --- Executes on button press in pbPrior.
function pbPrior_Callback(hObject, eventdata, handles)
% hObject    handle to pbPrior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentData.n = handles.currentData.n - 1;
if handles.currentData.n==1
    set(handles.pbPrior,'Enable','off');
end
g=handles.currentData.record(handles.currentData.n);
g=g.init();
handles.currentData.game=g;
delete(handles.currentData.ht);
handles.currentData.ht=g.draw_text();
set(handles.pbStart,'Enable','on');
guidata(hObject, handles);


% --- Executes on button press in pbReset.
function pbReset_Callback(hObject, eventdata, handles)
% hObject    handle to pbReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

g = handles.currentData.game;
g=g.reset();
handles.currentData.game=g;
delete(handles.currentData.ht);
handles.currentData.ht=g.draw_text();
handles.currentData.record=[handles.currentData.record, g];
handles.currentData.n = length(handles.currentData.record);
set(handles.pbStart,'Enable','on');
set(handles.eInformation,'String', '');
set(handles.pbExecute,'Enable','off');
set(handles.pbDemo,'Enable','off');
set(handles.eCommand,'Enable','inactive');
set(handles.pbPrompt,'Enable','off');
set(handles.eInformation,'String', '');
set(handles.pbPrior,'Enable','on');
guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function aGame_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to aGame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

action=ceil(ginput(2));
handles.currentData.action=action(:,[2,1]);
set(handles.eCommand,'String',mat2str(handles.currentData.action));
handles=execute(handles);

guidata(hObject, handles);


function handles=execute(handles)
action=handles.currentData.action;
set(handles.currentData.ht(action(1,1),action(1,2)),'Color','r');
set(handles.currentData.ht(action(2,1),action(2,2)),'Color','r');
pause(0.1)
if all(action(1:2,1)<=handles.currentData.size(1)) && all(action(1:2,2)<=handles.currentData.size(2)) && action(1,1)==action(2,1) || action(1,2)==action(2,2)
    if action(1,1)==action(2,1) && action(1,2)>action(2,2)
        action=action([2,1],:);
    elseif action(1,2)==action(2,2) && action(1,1)>action(2,1)
        action=action([2,1],:);
    end
    g=handles.currentData.game;
    if in(action, g.get_actions())
        [g,v] = g.execute(action);
        delete(handles.currentData.ht); % clear the figure
        handles.currentData.ht = g.draw_text();
        handles.currentData.score = handles.currentData.score + v;
        set(handles.eInformation, 'String', [g.action2str(action), sprintf('\n消掉%d格，得到%d分, 总共%d分',v,v,handles.currentData.score)]);
        handles.currentData.game=g;
        if v>=6
            h=text('Parent',handles.aGame,'Position',handles.currentData.size/2,'HorizontalAlignment','center','String','Perfect','Color','m','FontSize',30);
        else
            h=text('Parent',handles.aGame,'Position',handles.currentData.size/2,'HorizontalAlignment','center','String','Good','Color','m','FontSize',30);
        end
        pause(.5);
        delete(h);
        if g.isterminal()
            handles=gameover(handles);
        end
    else
        set(handles.eInformation, 'String', ['试图', g.action2str(action), ' 操作无效']);
    end
else
    set(handles.eInformation, 'String', '输入无效');
end

function handles=gameover(handles)
set(handles.eInformation,'String', sprintf('Game over, \n得%d分',handles.currentData.score));
set(handles.pbExecute,'Enable','off');
set(handles.pbStart,'Enable','off');
set(handles.pbDemo,'Enable','off');
set(handles.eCommand,'Enable','inactive','String','');
set(handles.pbPrompt,'Enable','off');
