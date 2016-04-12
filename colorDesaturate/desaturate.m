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

% Last Modified by GUIDE v2.5 31-Mar-2016 14:35:06

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

handles.imgs = loadImages('./photos', 900);

% image = (imread('./photos/nature.jpg'));
% [R,C,d] = size(image);
% maxSize = max(R,C);
% aspect = maxSize / 500;
% handles.image = imresize(image, 1/ aspect);

%%
handles.currentImage = 1;

colors = mainColors(handles.imgs{handles.currentImage});

handles.current_data = desaturateForAngle(handles.imgs{handles.currentImage}, colors(1,1), colors(1,2));
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

handles.current_data = desaturateForAngle(handles.image, currentVal - 30,currentVal + 30);
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

function[output] = desaturateForAngle(img,sHue, eHue)
hsvImage = rgb2hsv(img);         %# Convert the image to HSV space
h = hsvImage(:,:,1)*360;     %# Get the hue plane scaled from 0 to 360
sPlane = hsvImage(:,:,2);
nonRedIndex = 0;
sHue = sHue - 15 - 10;
if (sHue < 1)
    sHue = 360 + sHue;
end
eHue = eHue - 15 + 10;
if (eHue < 1)
    eHue = 360 + eHue;
end
if (sHue > eHue)sHue
    nonRedIndex = (h >= sHue | h <= eHue);
else
    nonRedIndex = (h >= sHue & h <= eHue);
end
% if (val == 1)
%     nonRedIndex = ((h > .75 | h <= .051) & h ~= -1);
% elseif (val == 2)
%     nonRedIndex = (h > .041 & h <= .18);
% elseif (val == 3)
%     nonRedIndex = (h > .18 & h <= .4167);
%
% elseif (val == 4)
%     nonRedIndex = (h > .4167 & h <= .75);
%
%     % elseif(val == 5)
%     %     nonRedIndex = (h > .5833 & h <= .75);
%     %
%     % elseif(val == 6)
%     %     nonRedIndex = (h > .75 & h <= .9167);
% end
sPlane(~nonRedIndex) = 0;           %# Set the selected pixel saturations to 0
hsvImage(:,:,2) = sPlane;          %# Update the saturation plane
output = hsv2rgb(hsvImage);      %# Convert the image back to RGB space


function[peaks] = mainColors(img,quant)
hsvImage = rgb2hsv(img);         %# Convert the image to HSV space
h = hsvImage(:,:,1);     %# Get the hue plane scaled from 0 to 360
[r, c, d] = size(img);

pixels = r*c;
h = histogram(h, 360)
values = circshift(h.Values',15)';
peaks = zeros(8,3);
peakIndex = 1;
for i = 2 : 359
    if(values(i) > values(i-1) && values(i) > values(i+1) && values(i) > pixels / 150)
        biggestPeak = 0;
        sIndex = 1;
        if (i > 40)
            sIndex = 40;
        else
            sIndex = i - 1;
        end
        eIndex = 360;
        if (i < 320)
            eIndex = i + 40;
        else
            eIndex = 360;
        end
        for j = i - sIndex + 5 : eIndex - 5
            if(values(j) > values(i))
                biggestPeak = 1;
                break;
            end
        end
        if (biggestPeak == 0)
            
            peaks(peakIndex,1) = i;
            for j = 1 : sIndex
                if(values(i - j) < values(i)*0.05)
                    peaks(peakIndex,2) = i - j;
                    break;
                end
            end
            if (peaks(peakIndex,2) == 0)
                peaks(peakIndex,2) = i - sIndex;
            end
            for j = i : eIndex
                if(values(j) < values(i)*0.05)
                    peaks(peakIndex,3) = j;
                    break;
                end
            end
            if (peaks(peakIndex,3) == 0)
                peaks(peakIndex,3) = eIndex;
            end
            peakIndex = peakIndex+1;
        end
    end
end

% figure; plot(values);
% hold on;
% for k = 1 : peakIndex - 1
%     plot(peaks(k,1),values(peaks(k,1)),'r*')
%     plot([peaks(k,2) peaks(k,3)],[values(peaks(k,2)) values(peaks(k,3))],'--or')
% end
% hold off;
peaks = peaks(1:peakIndex-1,2:3);
a = 2;


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
[numOfOptions , c] = size(handles.colors);
if (handles.currentColor > numOfOptions )
    handles.currentColor = 1;
end
guidata(hObject,handles);

handles.current_data = ...
    desaturateForAngle(handles.imgs{handles.currentImage}, handles.colors(handles.currentColor, 1),  handles.colors(handles.currentColor, 2));
imshow(handles.current_data);


% % --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
%hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentImage = handles.currentImage + 1;
if (handles.currentImage > length(handles.imgs) )
    handles.currentImage = 1;
end

colors = mainColors(handles.imgs{handles.currentImage});
handles.current_data = desaturateForAngle(handles.imgs{handles.currentImage}, handles.colors(handles.currentColor, 1),  handles.colors(handles.currentColor, 2));
handles.colors = colors;
handles.currentColor = 1;
guidata(hObject,handles);

imshow(handles.current_data);
