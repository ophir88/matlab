function varargout = desaturate(varargin)
% DESATURATE MATLAB code for desaturate.fig
%      DESATURATE, by itself, creates a new DESATURATE or raises the existing
%      singleton*.
%
%      H = DESATURATE returns the handle to a new DESATURATE or the handle to
%      the existing singleton*.
%
%      DESATURATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESATURATE.M with the given input arguments.
%
%      DESATURATE('Property','Value',...) creates a new DESATURATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before desaturate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to desaturate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help desaturate

% Last Modified by GUIDE v2.5 16-Feb-2016 20:04:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @desaturate_OpeningFcn, ...
                   'gui_OutputFcn',  @desaturate_OutputFcn, ...
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


% --- Executes just before desaturate is made visible.
function desaturate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% var2rgin   command line arguments to desaturate (see VARARGIN)

image = (imread('./photos/animal.jpg'));
[R,C,d] = size(image);
maxSize = max(R,C);
aspect = maxSize / 500;
handles.image = imresize(image, 1/ aspect);
colors = mainColors(handles.image);

handles.current_data = desaturateForAngle(handles.image, colors(1));
handles.colors = colors;
handles.currentColor = 1;
imshow(handles.current_data);

% Choose default command line output for desaturate
handles.output = hObject;
    
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes desaturate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = desaturate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
currentVal = get(hObject,'Value')*360;

handles.current_data = desaturateForAngle(handles.image, currentVal,handles.width);
imshow(handles.current_data);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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

function[output] = desaturateForAngle(img,val)
hsvImage = rgb2hsv(img);         %# Convert the image to HSV space
h = hsvImage(:,:,1);     %# Get the hue plane scaled from 0 to 360
sPlane = hsvImage(:,:,2);  
nonRedIndex = 0;

if (val == 1)
    nonRedIndex = ((h > .75 | h <= .051) & h ~= -1);
elseif (val == 2)
    nonRedIndex = (h > .041 & h <= .18);
elseif (val == 3)
    nonRedIndex = (h > .18 & h <= .4167);
    
elseif (val == 4)
    nonRedIndex = (h > .4167 & h <= .75);
    
% elseif(val == 5)
%     nonRedIndex = (h > .5833 & h <= .75);
%     
% elseif(val == 6)
%     nonRedIndex = (h > .75 & h <= .9167);
end
sPlane(~nonRedIndex) = 0;           %# Set the selected pixel saturations to 0
hsvImage(:,:,2) = sPlane;          %# Update the saturation plane
output = hsv2rgb(hsvImage);      %# Convert the image back to RGB space


function[finalColors] = mainColors(img,quant)
hsvImage = rgb2hsv(img);         %# Convert the image to HSV space
h = hsvImage(:,:,1);     %# Get the hue plane scaled from 0 to 360

% hHist = hist(hPlane, quant);
% hHist(quant) = hHist(1)+hHist(quant);
% hHist(1) = 0;
% figure; plot(hHist);

[r, c, d] = size(img);

pixels = r*c;
colors = zeros(4,1);
% see http://i.imgur.com/PKjgfFXm.jpg.
colors(1) = length(find((h > .75 | h <= .041) & h ~= -1))/pixels;
colors(2) = length(find(h > .041 & h <= .18))/pixels;
colors(3) = length(find(h > .18 & h <= .4167))/pixels;
colors(4) = length(find(h > .4167 & h <= .75))/pixels;


[ b, ix ] = sort( colors(:), 'descend');
finalColors = ix(b>0.05);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentColor = handles.currentColor + 1;
if (handles.currentColor > length(handles.colors) )
    handles.currentColor = 1;
end
guidata(hObject,handles);

handles.current_data = ...
    desaturateForAngle(handles.image, handles.colors(handles.currentColor));
imshow(handles.current_data);
