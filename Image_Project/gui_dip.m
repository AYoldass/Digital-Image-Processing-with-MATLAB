function varargout = gui_dip(varargin)
% GUI_DIP MATLAB code for gui_dip.fig
%      GUI_DIP, by itself, creates a new GUI_DIP or raises the existing
%      singleton*.
%
%      H = GUI_DIP returns the handle to a new GUI_DIP or the handle to
%      the existing singleton*.
%
%      GUI_DIP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DIP.M with the given input arguments.
%
%      GUI_DIP('Property','Value',...) creates a new GUI_DIP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_dip_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_dip_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_dip

% Last Modified by GUIDE v2.5 16-Dec-2023 21:25:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_dip_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_dip_OutputFcn, ...
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


% --- Executes just before gui_dip is made visible.
function gui_dip_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_dip (see VARARGIN)

% Choose default command line output for gui_dip
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_dip wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_dip_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exitbutton.
function exitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;

% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image;
global filename
global pathname

[filename,pathname]=uigetfile();

axes(handles.axes1);
image=imread(filename);
imshow(image);

% --- Executes on button press in runbutton.
function runbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
cla(handles.axes1,'reset'); 
cla(handles.axes2,'reset');

global image
global filename
global pathname


axes(handles.axes1)
image=imread(filename);
imshow(image);
axes(handles.axes2)

% mf process - filter
se = strel('line',2,2);
se2 = strel('line',500,500);

f=imread(filename);
[row,column] = size(f);


Img2 = rgb2gray(f);
Img2 = imbinarize(Img2);
Img2 = ~Img2;

BW=edge(Img2,'canny',[0.04 0.1],4);

[H,theta,rho] = hough(BW);


P = houghpeaks(H,7);
x = theta(P(:,2)); y = rho(P(:,1));
%plot(x,y,'s');



% Find lines and plot them
lines = houghlines(BW,theta,rho,P,'FillGap',3000,'MinLength',100);


% t : tum noktalari iceresinde tutan degisken
% pointsGrouped : pointleri eslestirmek icin gerekli olan degisken

% noktalari grupluyan algoritma :

t = [];
pointsGrouped = [];

for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        ab = [xy(1,1) xy(1,2)]; % baslangic noktasi
        cd = [xy(2,1) xy(2,2)]; % bitis noktasi
        t = [t ;ab ;cd]; 
        pointsGrouped = [pointsGrouped ;ab,2*k;cd,2*k-1]; 
        %xy_arr(k) = xy;
              
end


%Houghline sonucu olusan cizgileri cizer
[row,col] = size(t);

% Noktalar arasindaki farklari bulan algoritma :

pad = zeros(row-1,1);

for index = 1:row
    col_index = 1;
    for artis = 1:row-index
            fark = sqrt(abs(t(index,1)-t(index+artis,1))^2 + abs(t(index,2)-t(index+artis,2))^2);
            fark_arr(index,col_index+index-1) = fark;
            col_index = col_index + 1;
    end
end
fark_arr = [pad fark_arr];


% Ayni oldugu dusunulen noktalari gruplayan algoritma :
[row1,col1] = size(fark_arr);
for fark_index1 = 1:row1
    for fark_index2 = 1:col1
        if (fark_arr(fark_index1,fark_index2) < 70 && fark_arr(fark_index1,fark_index2) ~= 0)    
            ayni_nok(fark_index1,fark_index2) = 1;  
        else
            ayni_nok(fark_index1,fark_index2) = 0;
        end
    end
end

a=[];
for fark_index1 = 1:ceil(row1/2)
    s = 1;
    for fark_index2 = 1:col1
        if(ayni_nok(fark_index1,fark_index2) == 1)
            
                a(fark_index1,s) = fark_index1;
                a(fark_index1,s+1) = fark_index2;
                s = s + 2;
        end
    end
end


% - Fazlaliklari ve tekrarlari siler

[row2,col2] = size(a);

flag = 0;
basic_a = a;

for  temp= 2:col2/2+1
    if(mod(temp,2) == 1 && flag == 0)
       basic_a(:,temp) = [];
       flag = 1;
    end
    if(mod(temp,2) == 0  && flag == 1)
        flag = 0;
        basic_a(:,temp) = [];
    end
end

[row3,col3] = size(basic_a);
com = 1;
for fark_index1 = 1:row3
    for fark_index2 = 1:col3
        tel = basic_a(fark_index1,fark_index2);
        if (tel < ceil(row1/2) && tel ~= fark_index1 && tel ~= 0)
            del_num(com) = tel;
            com = com + 1;
        end
    end
end

basic_a2 = basic_a;
del_row=0;
[row4,col4] = size(del_num);
for del_index = 1:col4
    basic_a2(del_num(del_index)-del_row,:) = [];
    del_row=del_row+1;
end

% Kordinatlarin eslesmesi icin

% basic_a2 : tertemiz-pak matrix

[row5 , col5] = size(basic_a2);
basic_a3 = basic_a2;
basic_a3(:,col5+1) = -1; % ayrac


transpose_basic_a2 = basic_a2';

for row_i = 1:row5
    for col_i = 1:col5
        if(basic_a2(row_i,col_i) ~= 0)
            
            bufferFounder = floor((find(transpose_basic_a2==pointsGrouped(basic_a2(row_i,col_i),3)))/col5+1); % hangi satir'da oldugu bulunur
            
            if(bufferFounder ~= 0)    
                bufferPointChosen = basic_a2(bufferFounder,1);
                basic_a3(row_i,col5+1+col_i)=bufferPointChosen;
            end
            
        end
    end
end

%

imshow(f+255);
hold on ;


[row6 , col6]=size(basic_a3);

for bj = 1:row5
    for bi = col5+2:col6
        if(basic_a3(bj,bi) ~= 0)
            n1_x = t(basic_a2(bj,1),1);
            n1_y = t(basic_a2(bj,1),2);
            n2_x = t(basic_a3(bj,bi),1);
            n2_y = t(basic_a3(bj,bi),2);
            drawline('Position',[n1_x,n1_y;n2_x,n2_y],'Color','blue');
        end
    end
    hold on;
end

F = getframe(gcf);
[X, Map] = frame2im(F);


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image
global filename
global pathname
global path
global file

% Eksen içeriğini yakalama ve görüntü alma işlemi
frame = getframe(handles.axes2); % Eksen içeriğini yakalama
img = frame2im(frame); % Görüntüyü al

imwrite(img,path+file); 

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global file
file=get(handles.edit1,'String');



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global path
path=get(handles.edit2,'String');

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
