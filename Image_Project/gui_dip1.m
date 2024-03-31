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
imshow(image);
axes(handles.axes2)


[row,column] = size(image);


gray = rgb2gray(image);
% eşik değeri kullanarak pikselleri 0 veya 1 değerlerine dönüştürerek bir eşikleme işlemi gerçekleştirir
gray = imbinarize(gray);
% görüntüyü tersine çevir, siyah pikseller beyaz, beyaz pikseller siyah 
gray = ~gray;

% Canny kenar tespiti algoritması ile ikili görüntü üzerinde kenarları
% belirledik
BW=edge(gray,'canny',[0.04 0.1],4);

% Hough dönüşümü uygularak kenarların bulunduğu çizgileri tespit ettik
[H,theta,rho] = hough(BW);

% Hough dönüşümü sonucunda elde edilen matristeki tepe noktalarını belirler.
P = houghpeaks(H,7);
x = theta(P(:,2)); y = rho(P(:,1));

% Belirli bir boşluk ve uzunluktaki çizgileri çıkarır.
LinesIm = houghlines(BW,theta,rho,P,'FillGap',3000,'MinLength',100);

% Input1 : tum noktalari iceresinde tutan degisken
% PointsGroup : Noktaları eslestirmek icin gerekli olan degisken

% noktalari gruplayan algoritma :

% Çizgi segmentlerinin uç noktalarını ve nokta gruplarını saklamak için boş matrisler oluşturur.
Input1 = [];
PointsGroup = [];


% Çizgi segmentlerinin uç noktalarını alır ve Input1 ve PointsGroup matrislerini oluşturur.
for f = 1:length(LinesIm)
        
    
        xy = [LinesIm(f).point1; LinesIm(f).point2];
        ab = [xy(1,1) xy(1,2)]; % baslangic noktasi
        cd = [xy(2,1) xy(2,2)]; % bitis noktasi
        Input1 = [Input1 ;ab ;cd]; 
        PointsGroup = [PointsGroup ;ab,2*f;cd,2*f-1]; 
      
              
end


%Houghline sonucu olusan cizgileri cizer
[row,col] = size(Input1);

% Noktalar arasindaki farklari bulan algoritma :

%Noktalar arasındaki farkları saklamak için gerekli değişkenleri oluşturur.
pad = zeros(row-1,1);

% Noktalar arasındaki farkları hesaplar ve DifferenceArray matrisine kaydeder.
for Index = 1:row
    
    ColIndex = 1;
    
    for increase = 1:row-Index
        
            difference = sqrt(abs(Input1(Index,1)-Input1(Index+increase,1))^2 + abs(Input1(Index,2)-Input1(Index+increase,2))^2);
            DifferenceArray(Index,ColIndex+Index-1) = difference;
            ColIndex = ColIndex + 1;
            
    end
    
end
DifferenceArray = [pad DifferenceArray];


% Ayni oldugu dusunulen noktalari gruplayan algoritma :

% Benzer noktaları belirlemek için bir matrisi başlatır.
[row1,col1] = size(DifferenceArray);

% Belirli bir eşik değerine göre benzer noktaları belirler.
for DifferenceIndex_1 = 1:row1
    
    for DifferenceIndex_2 = 1:col1
        
        if (DifferenceArray(DifferenceIndex_1,DifferenceIndex_2) < 70 && DifferenceArray(DifferenceIndex_1,DifferenceIndex_2) ~= 0)    
            SamePoint(DifferenceIndex_1,DifferenceIndex_2) = 1;  
        else
            SamePoint(DifferenceIndex_1,DifferenceIndex_2) = 0;
        end
        
    end
    
end

% Benzer noktaların indislerini içeren bir matris oluşturur.
Input2=[];

for DifferenceIndex_1 = 1:ceil(row1/2)
    
    k = 1;
    
    for DifferenceIndex_2 = 1:col1
        
        if(SamePoint(DifferenceIndex_1,DifferenceIndex_2) == 1)
            
                Input2(DifferenceIndex_1,k) = DifferenceIndex_1;
                Input2(DifferenceIndex_1,k+1) = DifferenceIndex_2;
                k = k + 2;
                
        end
        
    end
    
end


% - Fazlaliklari ve tekrarlari siler

% Daha fazla işlem için gerekli değişkenleri başlatır.
[row2,col2] = size(Input2);
flag = 0;
B_Input2 = Input2;

% Input2 matrisinden fazla elemanları ve tekrarları kaldırır.
for  Temp= 2:col2/2+1
    
    if(mod(Temp,2) == 1 && flag == 0)
       B_Input2(:,Temp) = [];
       flag = 1;
    end
    
    if(mod(Temp,2) == 0  && flag == 1)
        flag = 0;
        B_Input2(:,Temp) = [];
    end
    
end

% Daha fazla işlem için gerekli değişkenleri başlatır.
[row3,col3] = size(B_Input2);
a = 1;
DelNum = [];

% Silinecek indisleri belirler ve DelNum matrisine kaydeder.
for DifferenceIndex_1 = 1:row3
    
    for DifferenceIndex_2 = 1:col3
        
        b = B_Input2(DifferenceIndex_1,DifferenceIndex_2);
        
        if (b < ceil(row1/2) && b ~= DifferenceIndex_1 && b ~= 0)
            DelNum(a) = b;
            a = a + 1;
        end
        
    end
    
end

% Belirlenen indisleri B_Input2_2 matrisinden çıkarır.
B_Input2_2 = B_Input2;
DelRow=0;
[row4,col4] = size(DelNum);

for DelIndex = 1:col4
    B_Input2_2(DelNum(DelIndex)-DelRow,:) = [];
    DelRow=DelRow+1;
end

% Kordinatlarin eslesmesi icin

% basic_a2 : tertemiz-pak matrix

%Daha fazla işlem için gerekli değişkenleri başlatır.
[row5 , col5] = size(B_Input2_2);
B_Input2_3 = B_Input2_2;
B_Input2_3(:,col5+1) = -1; % ayrac

% Daha fazla işlem için B_Input2_2 matrisini transpoze eder.
B_Input2Transpose_2 = B_Input2_2';

% Karşılık gelen noktaları bulur ve B_Input2_3 matrisini günceller.
for row_i = 1:row5
    
    for col_i = 1:col5
        
            if(B_Input2_2(row_i,col_i) ~= 0)
            
                BuffFounder = floor((find(B_Input2Transpose_2==PointsGroup(B_Input2_2(row_i,col_i),3)))/col5+1); % hangi satir'da oldugu bulunur
            
            if(BuffFounder ~= 0)    
                BuffPointChosen = B_Input2_2(BuffFounder,1);
                B_Input2_3(row_i,col5+1+col_i)=BuffPointChosen;
            end
            
        end
        
    end
    
end


%Orijinal resmi ekranda gösterir.
imshow(image+255);
hold on ;

% Belirlenen noktaları birleştiren mavi renkte çizgileri çizer.
[row6 , col6]=size(B_Input2_3);

for r_o = 1:row5
    
    for c_o = col5+2:col6
        
        if(B_Input2_3(r_o,c_o) ~= 0)
            Output1_x = Input1(B_Input2_2(r_o,1),1);
            Output1_y = Input1(B_Input2_2(r_o,1),2);
            Output2_x = Input1(B_Input2_3(r_o,c_o),1);
            Output2_y = Input1(B_Input2_3(r_o,c_o),2);
            drawline('Position',[Output1_x,Output1_y;Output2_x,Output2_y],'Color','blue');
        end
        
    end
    hold on;
end

% Mevcut figürü bir görüntü olarak yakalar.
fig = getframe(gcf);
[X, Map] = frame2im(fig);



% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image
global filename
global pathname
global path

% Eksen içeriğini yakalama ve görüntü alma işlemi
frame = getframe(handles.axes2); % Eksen içeriğini yakalama
img = frame2im(frame); % Görüntüyü al

imwrite(img,path); 

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global path
path=get(handles.edit1,'String');



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
