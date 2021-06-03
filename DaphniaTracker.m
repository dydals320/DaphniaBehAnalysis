% Track Daphnia from video file (AVI, uncompressed or Indeo5 compressed). 
% Requires user input:
%   (1) Tracking options: range of video frames to track, fragments to
%   divide up the movie, video framerate, and arena size.
%   (2) Arena bounds: Draw a box.
%   (3) Vertical arena dimensions. Click upper and lower positions that
%   correspond to arena size.
% Saves track data to a file.
%

function File = DaphniaTracker(FileName,PathName, Settings) % moviefile,blankrect);

%% Define Constants & Intialize variables
close(findobj('type','figure'));    % close all figures

arena = Settings.arena;                 % mm arena width
FrameRate = Settings.FrameRate;              % Framerate (Hz)
DefaultFragmentLength = Settings.DefaultFragmentLength; % frames
ColorImage = Settings.ColorImage;
progenycounting = Settings.progenycounting;
lifespan = Settings.lifespan;

bs = 5;                     % pixels for background and dye levels
UsingSettingMode = 0;
CollectTrackingSettings=0;

%% Set screen info
WTFigH = findobj('Tag', 'WTFIG');
if isempty(WTFigH)
    WTFigH = figure('NumberTitle', 'off', 'Tag', 'WTFIG');
else
    figure(WTFigH);
end
scrsz = get(0,'ScreenSize');
  
%% Get File info 
MovieNum = 1;
% UserPrompt = ['Select AVI File For Analysis:'];
% [FileName, PathName] = uigetfile('*.avi', UserPrompt);
cd(PathName);
Name(MovieNum).MovieFile = fullfile(PathName,FileName);
Name(MovieNum).TrackFile = strrep(Name(MovieNum).MovieFile,'.avi','.mat');
MovieName = Name(MovieNum).MovieFile;
[p,ShortMovieName] = fileparts(MovieName);
%% Get User Input 
if UsingSettingMode == 1

    TrackSettingsName = fullfile(p,[ShortMovieName,'_TrackSettings.mat']);
    CollectTrackingSettings = true;
    if exist(TrackSettingsName) == 2
        ButtonName = questdlg('Use existing tracking settings?','','Yes', 'No', 'Yes');
        if strcmp(ButtonName,'Yes')
            try
                load(TrackSettingsName);
                File = FileSettings;

                % check filenames
                [pn1,fn1] = fileparts(Name(MovieNum).MovieFile); % chosen
                [pn2,fn2] = fileparts(File(MovieNum).MovieFile); % from settings file
                if strcmp(fn1,fn2) % if filenames match
                    if ~strcmp(pn1,pn2) % if pathnames don't match
                        File(MovieNum).MovieFile = Name(MovieNum).MovieFile;
                        File(MovieNum).TrackFile = Name(MovieNum).TrackFile;
                    end
                    CollectTrackingSettings = false;
                else
                    disp('Filenames don''t match... reselect manually.');
                end

            catch
                disp('Error loading settings.  Select manually...');
            end
        end
    end
end
if CollectTrackingSettings

    % show first frame
    Mov = VideoReader(MovieName);
    Mov1 = read(Mov,1);
    Mov1flat = imflatten(Mov1);
    MovSize = size(Mov);
    figure(WTFigH); 
    clf; 
    imshow(imadjust(Mov1flat,[],[],1)); % imshow(imadjust(Mov1flat,[],[],2));
    set(gcf,'MenuBar','none');
    set(gcf,'Toolbar','none');
    % set(gcf,'Position',[150 100 1020 900]);
    set(gcf,'Position',[50 0 1020 900]);
end

%% Get information
buttony = 10;

FileInfo2 = VideoReader(MovieName); % aviinfo(MovieName,'Robust');
FrameNum = FileInfo2.NumberOfFrames; % FileInfo2.VideoStreamHeader.Length;
FrameRate = FileInfo2.FrameRate;
Duration = FileInfo2.Duration;
FrameStart = 1;
NumFragments = max(round(FrameNum/DefaultFragmentLength),1);
MovSize=size(FileInfo2);

uicontrol('Style','text','Position',[50 buttony 40 20],'String','Frames');
h2a = uicontrol('style','edit','Position',[100 buttony 50 20],'String',num2str(FrameStart));
h2 = uicontrol('style','edit','Position',[150 buttony 50 20],'String',num2str(FrameNum));
h2b = uicontrol('style','edit','Position',[200 buttony 20 20],'String',num2str(NumFragments));
uicontrol('Style','text','Position',[250 buttony 60 20],'String','Arena(mm)');
h4 = uicontrol('style','edit','Position',[320 buttony 40 20],'String',num2str(arena));
uicontrol('Style','text','Position',[400 buttony 60 20],'String','FrameRate');
h5 = uicontrol('style','edit','Position',[460 buttony 50 20],'String',num2str(FrameRate));

 %% User input
if UsingSettingMode == 1
    set(WTFigH,'Name',['Movie ',num2str(MovieNum),': ',ShortMovieName]);
    txt = 'Click background'; title(txt);
    % label = text(MovSize(2)/2,MovSize(1)*0.4,txt,'FontSize',18,'HorizontalAlignment','center');
    [X,Y] = ginput(1); File(MovieNum).BgBox = [X-bs Y-bs 2*bs 2*bs]; 
    rectangle('Position',File(MovieNum).BgBox); text(X+10,Y,'background');

    ar = 1; a = 1;
    % get tracking regions
    txt = 'SELECT TRACKING AREA: Drawing mouse cursor';
    title(txt); % set(label,'String',txt);
    success = 0; while success == 0
        box = getrect(WTFigH); 
        box = box+(box==0); 
        h = rectangle('Position',box); set(h,'EdgeColor',[1,0,0]);
        txt = 'Click inside to confirm, outside to redo.';
        title(txt);
        [X,Y,button] = ginput(1); 
        if button == 1 & (X-box(1) >= 0 & X-box(1) <= box(3) & Y-box(2) >= 0 & Y-box(2) <= box(4))
            File(MovieNum).Arena(ar).TrackBox = box+(box==0);
            set(h,'EdgeColor',[0,0,1]); 
            success = true;
        end
    end

    File(MovieNum).NumArenas = ar;

    TrackDye = get(h3,'Value');
    % get scale info
    txt = ['GET SCALING: pick points on left and right arena edges = ',get(h4,'String'),'mm'];
    title(txt); % set(label,'String',txt);
    [X,Y] = ginput(2); 
    arenapix = abs(X(2)-X(1)); 
end
%% Save information
File(MovieNum).MovieFile = Name(MovieNum).MovieFile;
File(MovieNum).TrackFile = Name(MovieNum).TrackFile;
File(MovieNum).TrackFrames = str2num(get(h2,'String'));
File(MovieNum).StartFrame = str2num(get(h2a,'String'));
File(MovieNum).ArenaSize = str2num(get(h4,'String'));
File(MovieNum).PixelSize = FileInfo2.Width / File(MovieNum).ArenaSize;
File(MovieNum).ImageSize = MovSize;
File(MovieNum).FrameRate = str2num(get(h5,'String'));
File(MovieNum).Fragments = str2num(get(h2b,'String'));
File(MovieNum).StartFragment = 1;
File(MovieNum).CompletedFragments = zeros(1,File(MovieNum).Fragments);
File(MovieNum).ClaimedFragments = zeros(1,File(MovieNum).Fragments);
File(MovieNum).Stitched = 0;
File(MovieNum).Duration = Duration;
File(MovieNum).ForceSize = Settings.ForceSize;
File(MovieNum).ForceSizePix = Settings.ForceSizePix;

hi = File(MovieNum).TrackFrames;
lo = File(MovieNum).StartFrame;
NumFragments = File(MovieNum).Fragments;
perfrag = round((hi-lo)/NumFragments/60)*60;
frfr = [lo+(0:(NumFragments-1))*perfrag]';
frfr = [frfr, [frfr(2:NumFragments)-1; hi]];

File(MovieNum).FragmentFrames = frfr;

disp([datestr(now),' Image Data Collected ']);
FileSettings = File(MovieNum);
partsfolder = '\QuantAnalyzed\';
savedir = [p partsfolder];
if ~exist(savedir)
    mkdir(savedir)
end

TrackSettingsName = [savedir,ShortMovieName,'_TrackSettings.mat'];
save(TrackSettingsName,'FileSettings');

% if progenycounting == 1
%     partsfolder = '\Analyzed\Progeny\';
%     savedir = [p partsfolder];
%     if ~exist(savedir)
%         mkdir(savedir)
%     end 
%     save(TrackSettingsName,'FileSettings');
% else
%     save(TrackSettingsName,'FileSettings');
% end
%% Start Tracker
FrameNum = File(MovieNum).TrackFrames;
Start = File(MovieNum).StartFrame;
ImageSize = File(MovieNum).ImageSize;
FrameRate = File(MovieNum).FrameRate;
PixelSize = File(MovieNum).PixelSize;
FragmentFrames = File(MovieNum).FragmentFrames;
NumFragments = File(MovieNum).Fragments;

Tracks = [];
AllData = [];
ExpData = [];
    
%Mov = VideoReader(MovieName); 
Mov1 = read(FileInfo2,1);
if ColorImage == 1
    Mov1 = rgb2gray(Mov1);
end
Mov1flat = imflatten(Mov1);

%Video Mask:  remove bright or dim pixels (deals with timer)
MovData = Mov1flat;
MaskPix = 10; MaskBorder = 20;
Mask = (MovData <= MaskPix | MovData >= 255-MaskPix);
Mask = imdilate(Mask,strel('square',3));
Mask(MaskBorder:ImageSize(1)-MaskBorder, MaskBorder:ImageSize(2)-MaskBorder) = 0;


if Settings.getMask == 1
   load([PathName '\TankMask.mat']);
   Mask = TankMask;    
end
tic;

%% Analyze video
% set save file name
TrackName = File(MovieNum).TrackFile;
[pathname,filename,ext] = fileparts(TrackName);
partsfolder = '\QuantAnalyzed\';
FileSaveNames = [{[pathname,partsfolder,filename,ext]}]; 

FragmentTracker(File,FileSaveNames,Mask,Settings,WTFigH); 

%% Save Combined File
StitchTracks(FileSaveNames,TrackName);

% Copy files back to original location
disp([datestr(now),': Copying tracks file from local directory']);
[s,mess,messid] = copyfile(TrackName,File(MovieNum).TrackFile);
disp([datestr(now),': Complete... ',mess]);

disp([datestr(now),': Copying avi.mat file(s) from local directory']);
[s,mess,messid] = copyfile([MovieName,'*.mat'],fileparts(File(MovieNum).TrackFile));
disp([datestr(now),': Complete... ',mess]);