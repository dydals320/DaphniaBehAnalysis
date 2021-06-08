function varargout = counter(varargin)
% COUNTER MATLAB code for counter.fig
%      COUNTER, by itself, creates a new COUNTER or raises the existing
%      singleton*.
%
%      H = COUNTER returns the handle to a new COUNTER or the handle to
%      the existing singleton*.
%
%      COUNTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COUNTER.M with the given input arguments.
%
%      COUNTER('Property','Value',...) creates a new COUNTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before counter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to counter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help counter

% Last Modified by GUIDE v2.5 09-Oct-2019 19:05:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @counter_OpeningFcn, ...
                   'gui_OutputFcn',  @counter_OutputFcn, ...
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

%% INITIALIZE THE FIGURE AND OBJECTS
function counter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to counter (see VARARGIN)

% Choose default command line output for counter
handles.output = hObject;
counter_ResizeFcn(hObject, eventdata, handles)
set(handles.counter,'PaperPositionMode','auto')
guidata(hObject, handles);

function varargout = counter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate display
    set(hObject,'Visible','off')

function counter_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to counter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    figpos = get(handles.counter,'Position');
    bottom = 20;
    %set(handles.display,'Position',[1 bottom+1 figpos(3)-1 figpos(4)-bottom-1]);
    %set(handles.cell_count_string,'Position',[0 0 figpos(3) bottom]);    

function display_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if strcmp(get(handles.toolbar_red,'State'),'on')
        this_plot = 1;
    elseif strcmp(get(handles.toolbar_green,'State'),'on')
        this_plot = 2;
    elseif strcmp(get(handles.toolbar_blue,'State'),'on')
        this_plot = 3;
    else
        return
    end

    point = get(handles.display,'CurrentPoint');
    point = point(1,1:2);
    xl = get(handles.display,'XLim');
    yl = get(handles.display,'YLim');
    if point(1) < xl(1) || point(1) > xl(2) || point(2) < yl(1) || point(2) > yl(2) 
        return
    end
    point_x = get(handles.scatter(this_plot),'XData');
    point_y = get(handles.scatter(this_plot),'YData');  

    point_x = [point_x point(1)];
    point_y = [point_y point(2)];
    
    set(handles.scatter(this_plot),'XData',point_x);
    set(handles.scatter(this_plot),'YData',point_y);
    update_count_string(handles);
    guidata(hObject, handles);
    
function update_count_string(handles)
    for j = 1:3
        npoints(j) = length(get(handles.scatter(j),'XData'))-1;
    end

    % set(handles.cell_count_string,'String',sprintf('%d marked red | %d marked green | %d marked blue',npoints(1),npoints(2),npoints(3)));
    set(handles.edit4, 'string', npoints(1));
    set(handles.edit5, 'string', npoints(2));
    set(handles.edit6, 'string', npoints(3));
 %% MANAGE THE MENUS
function menu_open_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [fname,pathname] = uigetfile({'*.tiff';'*.jpg';'*.png'},'Open an image file for marking');
    if fname == 0
        return
    end
    fname = fullfile(pathname,fname);
    
    handles.image = imshow(fname,'Parent',handles.display);
    xsize = get(handles.image,'XData');
    ysize = get(handles.image,'YData');
    grid_size = diff(ysize)/10; % 10 ticks
    set(handles.display,'XTick',xsize(1):grid_size:xsize(2),'YTick',ysize(1):grid_size:ysize(2),'XTickLabel',[],'YTickLabel',[],'TickLength',[0 0]);
    grid(handles.display,'on');
    hold(handles.display,'on');
    handles.scatter(1) = scatter (NaN,NaN,100,'ro','Parent',handles.display,'HitTest','off','XLimInclude','off','YLimInclude','off');
    handles.scatter(2) = scatter (NaN,NaN,100,'go','Parent',handles.display,'HitTest','off','XLimInclude','off','YLimInclude','off');
    handles.scatter(3) = scatter (NaN,NaN,100,'bo','Parent',handles.display,'HitTest','off','XLimInclude','off','YLimInclude','off');

    % Matlab R2014b and later needs an extra fix
    if isa(handles.output,'matlab.ui.Figure')
        set(handles.scatter,'PickableParts','none')
    end

    hold(handles.display,'off');
    set(handles.image,'ButtonDownFcn',{@display_ButtonDownFcn,handles});
    handles.current_fname = fname;
    set(handles.counter,'Name',fname);
    if strcmp(get(handles.toolbar_grid,'State'),'on')
        set(handles.display,'Visible','on');
    end
    
    % Make sure some of the toolbar buttons are enabled
    set(handles.menu_open_points,'Enable','on');
    set(handles.menu_save_points,'Enable','on');
    set(handles.menu_save_image,'Enable','on');
    set(handles.toolbar_grid,'Enable','on');
    
    update_count_string(handles);
    guidata(hObject, handles);

function menu_save_points_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [fname,pathname] = uiputfile('*.txt','Save marked points',sprintf('%s.txt',strtok(handles.current_fname,'.')));
    if fname == 0
        return
    end
    fname = fullfile(pathname,fname);
    
    fid = fopen(fname,'w');
    colours = {'Red','Green','Blue'};
    for j = 1:3
        x = get(handles.scatter(j),'XData');
        y = get(handles.scatter(j),'YData');
        fprintf(fid,'%s: %d\r\n',colours{j},length(x)-1);
        if length(x)-1 > 0
            for k = 2:length(x)
                fprintf(fid,'%.2f %.2f\r\n',x(k),y(k));
            end
        end
    end
    fclose(fid);
 
function menu_open_points_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [fname,pathname] = uigetfile('*.txt','Save marked points',sprintf('%s.txt',strtok(handles.current_fname,'.')));
    if fname == 0
        return
    end
    fname = fullfile(pathname,fname);
    
    try
        fid = fopen(fname);
        colours = {'Red','Green','Blue'};
        for j = 1:3
            npoints = textscan(fid,sprintf('%s: %%d\n',colours{j}));
            p = textscan(fid,'%f',npoints{1}*2);
            data = reshape(p{1},2,[])';
            set(handles.scatter(j),'XData',[NaN; data(:,1)]);
            set(handles.scatter(j),'YData',[NaN; data(:,2)]);
        end
        update_count_string(handles);
        fclose(fid);
    catch
        fclose(fid);
        errordlg('Error reading input file! :(')
    end
function menu_save_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [fname,pathname] = uiputfile('*.png','Save image points',sprintf('%s_marked.png',strtok(handles.current_fname,'.')));
    if fname == 0
        return
    end
    fname = fullfile(pathname,fname);

    % Quick hack to make the user wait while image is saved
    h=msgbox('Saving image...','modal');
    set(findobj(h,'Style','pushbutton'),'Visible','off') % Hide the 'OK' button
    try
        print(handles.counter,'-r75','-dpng',fname)
        delete(h);
    catch
        delete(h);
        errordlg('An error occurred while saving the image!');
    end
     
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    delete(handles.counter);
    
 %% IMPLEMENT THE TOOLBAR BUTTONS
function toolbar_manager(hObject, eventdata, handles)
    for j =[handles.toolbar_zoomin,handles.toolbar_zoomout,handles.toolbar_pan,handles.toolbar_red,handles.toolbar_green,handles.toolbar_blue]
        if j ~= hObject
            set(j,'State','off');
        end
    end

function toolbar_mark_OffCallback(hObject, eventdata, handles)
% hObject    handle to toolbar_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    enterFcn = @(figHandle, currentPoint) set(figHandle, 'Pointer', 'arrow');
    iptSetPointerBehavior(handles.display, enterFcn);
    iptPointerManager(handles.counter,'disable');

function toolbar_mark_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to toolbar_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if strcmp(get(hObject,'State'),'on')
        pan(handles.display,'off');
        zoom(handles.display,'off');
        enterFcn = @(figHandle, currentPoint) set(figHandle, 'Pointer', 'circle');
        iptSetPointerBehavior(handles.display, enterFcn);
        iptPointerManager(handles.counter,'enable');
    end

function toolbar_grid_OnCallback(hObject, eventdata, handles)
    set(handles.display,'Visible','on');
    
function toolbar_grid_OffCallback(hObject, eventdata, handles)
    set(handles.display,'Visible','off');

%% 
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[sVidName, sDirName] = uigetfile('N:\KIRSCHNER LAB\Yongmin\DaphniaBehaviorTracking\CohortLifespan_Round2\*.avi');
objReader = VideoReader([sDirName sVidName]);
iNumFiles = objReader.NumberOfFrames;
iFile = 1;
set(handles.text2, 'string', [sDirName sVidName]);
    
file = dir([sDirName sVidName]);
day = file.date;
date = day(1:11);
time = day(13:end);

HatchDate = importdata([sDirName 'BirthDate.txt']);
%HatchDate = cell2mat(HatchDate);

Age = datenum(date) - datenum(HatchDate);
handles.Age = Age;
handles.date = date;
handles.time = time;
if exist('Age')
    set(handles.edit8, 'string', Age);
end
% end
LoadMat = [sDirName 'QuantAnalyzed\' sVidName(1:end-4) '.mat'];
load(LoadMat)
FrameInd = find(Daphniapopulation == max(Daphniapopulation));

FrameIndex = FrameInd(1);


LoadFile = [sDirName 'QuantAnalyzed\' sVidName(1:end-4) '_beh.mat'];
load(LoadFile);

rgImage = read(objReader,FrameIndex);
vFiles = []; 
%     axes(handles.display)
%     imshow(rgImage,[])
handles.image = imshow(rgImage,'Parent',handles.display);

xsize = get(handles.image,'XData');
ysize = get(handles.image,'YData');
grid_size = diff(ysize)/10; % 10 ticks
set(handles.display,'XTick',xsize(1):grid_size:xsize(2),'YTick',ysize(1):grid_size:ysize(2),'XTickLabel',[],'YTickLabel',[],'TickLength',[0 0]);
grid(handles.display,'on');
hold(handles.display,'on');
handles.scatter(1) = scatter (NaN,NaN,100,'ro','Parent',handles.display,'HitTest','off','XLimInclude','off','YLimInclude','off');
handles.scatter(2) = scatter (NaN,NaN,100,'go','Parent',handles.display,'HitTest','off','XLimInclude','off','YLimInclude','off');
handles.scatter(3) = scatter (NaN,NaN,100,'bo','Parent',handles.display,'HitTest','off','XLimInclude','off','YLimInclude','off');

set(handles.frame_slider, 'Min', 1);
set(handles.frame_slider, 'Max', iNumFiles);
set(handles.frame_slider, 'Value', FrameIndex);
set(handles.frame_number, 'string', FrameIndex);
set(handles.edit7, 'string', sprintf('Analyzing Image %i out of %i '...
    , FrameIndex, iNumFiles))


    for i = 1:length(Tracks)
        try
            a(i) = Tracks(i).OriginalTrack;
        catch
            a(i) = NaN; 
        end
    end
    
    numframes = ExpData.TrackedFrames;
    ssTracks=NaN(numframes,2,length(Tracks));
    
    for i = 1:length(Tracks)
        valind = find(a==i);

        for j = 1:length(valind)

            ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),1,i) = Tracks(valind(j)).X; 
            ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),2,i) = Tracks(valind(j)).Y; 
   
        end
    end
    
    allTheFrames = cell(objReader.numberOfFrames,1);
    allTheFrames(:) = {zeros(objReader.Height, objReader.Width, 3, 'uint8')};
    recalledMovie = struct('cdata', allTheFrames);
    
    
    NumAnimals = sum(~isnan(ssTracks(FrameIndex,1,:)));
    NumIndex = [1:NumAnimals+1];
    %hg = figure('units','normalized','outerposition',[0 0 1 1]);
    %set(hg, 'Visible','off');
    %cla(handles.display,'reset')
    %axes(handles.display)
    %imshow(rgImage,[])
    title(sprintf('Original (Image %i out of %i)',FrameIndex,iNumFiles))
    axis image
    hold on
    k = 1;
     for j = 1:max(a) %
        viscircles([ssTracks(FrameIndex,1,j),ssTracks(FrameIndex,2,j)],10,'DrawBackgroundCircle',false,...
        'color',[1 1 1], 'linewidth',1);
        text(ssTracks(FrameIndex,1,j)+20, ssTracks(FrameIndex,2,j), sprintf('%s', num2str(NumIndex(k))), 'Color', [1 1 1]);
        Coordinate(j,1) = ssTracks(FrameIndex,1,j);
        Coordinate(j,2) = ssTracks(FrameIndex,1,j);
        if ~isnan(ssTracks(FrameIndex,1,j))
            k = k+1;
        end
     end
    

set(handles.edit3, 'string', NumAnimals)
%Set up output struct
vFound = NaN(1,iNumFiles);
vAllPoints = NaN(2,iNumFiles);

handles = setfield(handles, 'sDirName', sDirName);
handles = setfield(handles, 'vFiles', vFiles);
handles = setfield(handles, 'iNumFiles', iNumFiles);
handles = setfield(handles, 'iFile', FrameIndex);
handles = setfield(handles, 'vPoint', []);
handles = setfield(handles, 'vAllPoints', vAllPoints);
handles = setfield(handles, 'rgImage', rgImage);
handles = setfield(handles, 'objReader', objReader);
handles = setfield(handles, 'sVidName', sVidName);

handles = setfield(handles, 'setFrame', FrameIndex);
handles = setfield(handles, 'MaxNumAnimal', NumAnimals);
handles = setfield(handles, 'ssTracks', ssTracks);
handles = setfield(handles, 'a', a);
handles = setfield(handles, 'Coordinate', Coordinate);
% 
fname = fullfile(sDirName,sVidName);


hold(handles.display,'off');
set(handles.image,'ButtonDownFcn',{@display_ButtonDownFcn,handles});
handles.current_fname = fname;
set(handles.counter,'Name',fname);
if strcmp(get(handles.toolbar_grid,'State'),'on')
    set(handles.display,'Visible','on');
end

% Make sure some of the toolbar buttons are enabled
set(handles.menu_open_points,'Enable','on');
set(handles.menu_save_points,'Enable','on');
set(handles.menu_save_image,'Enable','on');
set(handles.toolbar_grid,'Enable','on');

update_count_string(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.iFile >1
    handles.iFile = handles.iFile - 1;
    set(handles.frame_number, 'String', sprintf('%i',handles.iFile));
    set(handles.frame_slider, 'Value', handles.iFile);
    set(handles.edit7, 'string', sprintf('Analyzing Image %i out of %i '...
        , handles.iFile, handles.iNumFiles));
    
    rgImage = read(handles.objReader,handles.iFile);
    
    handles.image.CData = rgImage;    
    title(sprintf('Original (Image %i out of %i)',handles.iFile,handles.iNumFiles))
%     axis image  
%     hold on
    
%     a = handles.a;    
%     ssTracks = handles.ssTracks;
%     setFrame = handles.setFrame;
%      for j = 1:max(a) %
%         viscircles([ssTracks(setFrame,1,j),ssTracks(setFrame,2,j)],10,'DrawBackgroundCircle',false,...
%         'linewidth',1);
%         text(ssTracks(setFrame,1,j)+20, ssTracks(setFrame,2,j), sprintf('%s', num2str(j)), 'Color', [0 1 1]);
%      end
    
else
    fprintf('Already at first frame \n');
end

% set(handles.image,'ButtonDownFcn',{@display_ButtonDownFcn,handles});

guidata(hObject, handles)


function frame_number_Callback(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_number as text
%        str2double(get(hObject,'String')) returns contents of frame_number as a double
iFile = str2double(get(hObject,'String'));
if iFile < 1 || iFile > handles.iNumFiles
    fprintf('Slider Frame Value Out of Range \n');
else
    handles.iFile = iFile;
    set(handles.frame_number, 'String', sprintf('%i',iFile));
    set(handles.frame_slider, 'Value', handles.iFile);
    
    % Show worm image
    
    rgImage = read(handles.objReader,handles.iFile);

    
    handles.image.CData = rgImage;


    title(sprintf('Original (Image %i out of %i)',handles.iFile,handles.iNumFiles))
    axis image    
end

% set(handles.image,'ButtonDownFcn',{@display_ButtonDownFcn,handles});

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function frame_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
iFile = round(get(hObject,'Value'));
if iFile < 1 || iFile > handles.iNumFiles
    fprintf('Slider Frame Value Out of Range \n');
else
    handles.iFile = iFile;
    set(handles.frame_number, 'String', sprintf('%i',iFile));
    set(handles.frame_slider, 'Value', handles.iFile);
    
    % Show worm image
    
    rgImage = read(handles.objReader,handles.iFile);
    handles.image.CData = rgImage;
    title(sprintf('Original (Image %i out of %i)',handles.iFile,handles.iNumFiles))
    axis image
       
end

set(handles.image,'ButtonDownFcn',{@display_ButtonDownFcn,handles});

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.iFile < handles.iNumFiles
    handles.iFile = handles.iFile + 1;
    set(handles.frame_number, 'String', sprintf('%i',handles.iFile));
    set(handles.frame_slider, 'Value', handles.iFile);
    set(handles.edit7, 'string', sprintf('Analyzing Image %i out of %i '...
        , handles.iFile, handles.iNumFiles));

    rgImage = read(handles.objReader, handles.iFile);

    handles.image.CData = rgImage;
    title(sprintf('Original (Image %i out of %i)',handles.iFile,handles.iNumFiles))
%     axis image  
%     hold on
%     
%     a = handles.a;    
%     ssTracks = handles.ssTracks;
%     setFrame = handles.setFrame;
%      for j = 1:max(a) %
%         viscircles([ssTracks(setFrame,1,j),ssTracks(setFrame,2,j)],10,'DrawBackgroundCircle',false,...
%         'linewidth',1);
%         text(ssTracks(setFrame,1,j)+20, ssTracks(setFrame,2,j), sprintf('%s', num2str(j)), 'Color', [0 1 1]);
%      end
%     
   
else
    fprintf('Already looking at last image \n');
end

set(handles.image,'ButtonDownFcn',{@display_ButtonDownFcn,handles});

guidata(hObject, handles)



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
 str2double(get(handles.MaxNumAnimal,'string'));
 guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.iFile = handles.setFrame;
set(handles.frame_number, 'String', sprintf('%i',handles.iFile));
set(handles.frame_slider, 'Value', handles.iFile);
set(handles.edit7, 'string', sprintf('Analyzing Image %i out of %i '...
    , handles.iFile, handles.iNumFiles));

    rgImage = read(handles.objReader, handles.iFile);


handles.image.CData = rgImage;
title(sprintf('Original (Image %i out of %i)',handles.iFile,handles.iNumFiles))

  
guidata(hObject, handles)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % [fname,pathname] = uiputfile('*.txt','Save marked points',sprintf('%s.txt',strtok(handles.current_fname,'.')));
    
    SaveDir = [handles.sDirName,'QuantAnalyzed\Lifespan\'];
    fname = [SaveDir, handles.sVidName(1:end-4), '_lifespan'];
    
    if ~exist(SaveDir)
        mkdir(SaveDir)
    end
        
    DetectedAnimals = str2num(handles.edit3.String);
    NewAnimals = str2num(handles.edit4.String);
    DeadAnimals = str2num(handles.edit5.String);
    Mislabeled = str2num(handles.edit6.String);
    TotalAnimals = DetectedAnimals + NewAnimals - Mislabeled;
    
    Age = handles.Age;
    date = handles.date;
    time = handles.time;
    
    XYPoint = handles.Coordinate;
    XYPoint(~any(~isnan(XYPoint), 2),:)=[];
    LiveX = handles.scatter(1).XData';
    LiveY = handles.scatter(1).YData';   
    Live = [LiveX LiveY];
    XYPoint = [XYPoint; Live];
    
    DeadX = handles.scatter(2).XData';
    DeadY = handles.scatter(2).XData';
    Dead = [DeadX DeadY];
    
    MissX = handles.scatter(3).XData';
    MissY = handles.scatter(3).XData';
    Miss = [MissX MissY];
    
    Coordinate.Live = XYPoint;
    Coordinate.Dead = Dead;
    Coordinate.Miss = Miss;
    save([fname, 'mat'], 'Age','date', 'time', 'DetectedAnimals','NewAnimals',...
        'DeadAnimals','Mislabeled','TotalAnimals', 'Coordinate');
    saveas(gcf, [fname, '.png'], 'png');
    
    
    fid = fopen([fname '.txt'], 'w');
    fprintf(fid, 'date: %s, time: %s \n', date, time);
    fprintf(fid, 'Ages: %d\n', Age);
    fprintf(fid, 'DetectedAnimals: %d, NewAnimals: %d, DeadAnimals: %d, Mislabeled: %d \n',...
        DetectedAnimals, NewAnimals, DeadAnimals, Mislabeled);
    fprintf(fid, 'TotalAnimals: %d', TotalAnimals);
    fclose(fid);
    
    

    
    
